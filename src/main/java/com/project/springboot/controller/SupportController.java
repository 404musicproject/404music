package com.project.springboot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.project.springboot.dao.ISupportDAO;
import com.project.springboot.dto.InquiryDTO;
import com.project.springboot.dto.NotificationDTO;
import com.project.springboot.dto.UserDTO;

import jakarta.servlet.http.HttpSession;

@Controller
public class SupportController {
    
	 @Autowired
	    private ISupportDAO supportDao; 

    // 1.support
    @GetMapping("/support")
    public String supportCenter(@RequestParam(value="mode", defaultValue = "notice") String mode, 
                               HttpSession session, Model model) {
        
        model.addAttribute("mode", mode); 
        
        if(mode.equals("notice")) {
            model.addAttribute("list", supportDao.getNoticeList()); 
        } 
        
        else if(mode.equals("inquiry")) {
            UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
            if(loginUser != null) {
                model.addAttribute("list", supportDao.getMyInquiryList(loginUser.getUNo()));
            } else {
                // 로그인 세션이 없는 경우 로그인 모달 유도 또는 로그인 페이지 리다이렉트
            	 return "redirect:/?showLogin=true";  
            }
        }
        return "support/Main";
    }
    
    
 // 공지사항 작성 페이지 이동 (관리자 전용)
    @GetMapping("/support/noticeWrite")
    public String noticeWriteForm(HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null || !"ADMIN".equals(loginUser.getUAuth())) {
            return "redirect:/support?mode=notice"; // 관리자가 아니면 목록으로
        }
        return "support/NoticeForm";
    }

    // 공지사항 DB 저장 처리
    @PostMapping("/support/insertNotice.do")
    public String insertNotice(NotificationDTO notice, 
                               @RequestParam(value="isPopup", defaultValue="N") String isPopup,
                               HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser != null && "ADMIN".equals(loginUser.getUAuth())) {
            
            if("Y".equals(isPopup)) {
                notice.setUserNo(0); // 팝업은 특정 회원이 아닌 전체(0) 대상
                notice.setNType("POPUP"); 
                // nEndDate는 JSP에서 <input type="date">로 받아온다고 가정
            } else {
                notice.setUserNo(loginUser.getUNo());
                notice.setNType("NOTICE");
            }
            
            supportDao.insertNotification(notice);
        }
        return "redirect:/support?mode=notice";
    }
    
    @GetMapping("/api/getPopups")
    @ResponseBody // JSON 데이터를 반환
    public List<NotificationDTO> getActivePopups() {
        // DAO에서 "u_no=0 AND n_type='POPUP' AND SYSDATE <= n_end_date" 조건으로 조회
        return supportDao.getActivePopupList(); 
    }
    
 // 공지 삭제
    @GetMapping("/support/noticeDelete.do")
    public String deleteNotice(@RequestParam("nNo") int nNo, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        
        // 관리자 권한 체크 (보안 강화)
        if (loginUser != null && "ADMIN".equals(loginUser.getUAuth())) {
            supportDao.deleteNotice(nNo); // noticeService -> supportDao로 변경
        }
        
        // 삭제 후 리스트 페이지(support?mode=notice)로 이동
        return "redirect:/support?mode=notice"; 
    }

    // 공지 수정 페이지 이동
    @GetMapping("/support/noticeUpdate")
    public String updatePage(@RequestParam("nNo") int nNo, HttpSession session, Model model) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        
        // 관리자만 수정 페이지 접근 가능
        if (loginUser == null || !"ADMIN".equals(loginUser.getUAuth())) {
            return "redirect:/support?mode=notice";
        }

        NotificationDTO notice = supportDao.getNoticeDetail(nNo); // noticeService -> supportDao로 변경
        model.addAttribute("notice", notice);
        return "support/NoticeUpdate"; // JSP 파일명 (대소문자 주의)
    }

    // 공지 수정 실행 (Post) - 이 메서드도 추가하세요
    @PostMapping("/support/updateNotice.do")
    public String updateNotice(NotificationDTO notice, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        
        if (loginUser != null && "ADMIN".equals(loginUser.getUAuth())) {
            supportDao.updateNotice(notice);
        }
        System.out.println("전달받은 공지번호: " + notice.getNoticeNo()); 
        
        if(notice.getNoticeNo() == 0) {
            System.out.println("에러: 번호가 0입니다. JSP의 input name을 확인하세요.");
        }
        return "redirect:/support?mode=notice";
    }
    
    
    
    // 2. 관리자 답변 등록 및 알림 자동 발송
    @Transactional
    @PostMapping("/admin/answer.do")
    public String answerInquiry(InquiryDTO inquiry) {
        // 1. 기존 문의 데이터를 먼저 가져와서 기존 답변이 있었는지 확인
        InquiryDTO existingInq = supportDao.getInquiryDetail(inquiry.getINo());
        boolean isUpdate = existingInq.getIAnswer() != null; // 기존 답변이 있으면 true

        // 2. 답변 업데이트 실행
        supportDao.updateAnswer(inquiry);

        // 3. 알림(Notification) 생성 및 발송
        NotificationDTO notice = new NotificationDTO();
        notice.setUserNo(inquiry.getUserNo());
        notice.setNType("INQUIRY");
        notice.setNRefNo(inquiry.getINo());

        if (isUpdate) {
            // [수정 알림]
            notice.setNTitle("1:1 문의 답변이 수정되었습니다.");
            notice.setNContent("문의하신 [" + inquiry.getITitle() + "]에 대한 답변 내용이 업데이트되었습니다.");
        } else {
            // [신규 등록 알림]
            notice.setNTitle("문의하신 내용에 답변이 등록되었습니다.");
            notice.setNContent("문의하신 [" + inquiry.getITitle() + "]에 대한 답변이 완료되었습니다.");
        }

        supportDao.insertNotification(notice);
        
        return "redirect:/support?mode=inquiry";
    }
    
    
    @GetMapping("/support/inquiryWrite")
    public String inquiryWriteForm(HttpSession session) {
        // 로그인 체크: 세션에 유저가 없으면 메인으로 리다이렉트 (로그인창 유도)
        if(session.getAttribute("loginUser") == null) {
            return "redirect:/?showLogin=true"; 
        }
        return "support/InquiryForm"; // /WEB-INF/views/support/InquiryForm.jsp
    }

    // 4. 1:1 문의 데이터 DB 저장
    @PostMapping("/support/insertInquiry.do")
    public String insertInquiry(InquiryDTO inquiry, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        
        if(loginUser != null) {
            // 로그인한 유저의 번호를 DTO에 세팅
            inquiry.setUserNo(loginUser.getUNo());
            
            // 비밀글 체크박스 처리 (체크 안하면 null이 들어올 수 있으므로 기본값 N 설정)
            if(inquiry.getIIsSecret() == null) {
                inquiry.setIIsSecret("N");
            }
            
            // DB 저장 실행
            int result = supportDao.insertInquiry(inquiry);
        }
        
        // 작성 후 다시 1:1 문의 목록으로 이동
        return "redirect:/support?mode=inquiry";
    }
    
    
    @GetMapping("/support/inquiryDelete.do")
    public String deleteInquiry(@RequestParam("INo") int iNo, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        InquiryDTO inq = supportDao.getInquiryDetail(iNo);
        
        // 권한 체크: 작성자 본인이거나 관리자일 때만 삭제 가능
        if (loginUser != null && (loginUser.getUNo() == inq.getUserNo() || "ADMIN".equals(loginUser.getUAuth()))) {
            supportDao.deleteInquiry(iNo);
        }
        return "redirect:/support?mode=inquiry";
    }

    // 1:1 문의 수정 페이지 이동
    @GetMapping("/support/inquiryUpdate")
    public String inquiryUpdatePage(@RequestParam("iNo") int iNo, Model model, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        InquiryDTO inq = supportDao.getInquiryDetail(iNo);
        
        // 작성자 본인이 아니면 접근 차단
        if (loginUser == null || loginUser.getUNo() != inq.getUserNo()) {
            return "redirect:/support?mode=inquiry";
        }
        
        model.addAttribute("inq", inq);
        return "support/InquiryUpdate"; // InquiryUpdate.jsp 파일 필요
    }

    // 1:1 문의 수정 실행 (POST)
    @PostMapping("/support/updateInquiry.do")
    public String updateInquiry(InquiryDTO inquiry) {
        // 비밀글 체크박스 미선택 시 null 방지
        if(inquiry.getIIsSecret() == null) {
            inquiry.setIIsSecret("N");
        }
        supportDao.updateInquiry(inquiry);
        return "redirect:/support?mode=inquiry";
    }
}