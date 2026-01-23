package com.project.springboot.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import com.project.springboot.dao.ISubscriptionDAO;
import com.project.springboot.dto.SubscriptionDTO;
import com.project.springboot.dto.UserDTO;
import com.project.springboot.service.SubscriptionService;

import jakarta.servlet.http.HttpSession;

@Controller
public class SubscriptionController {

    @Autowired
    private SubscriptionService subscriptionService;

    @Autowired
    private ISubscriptionDAO subscriptionDAO;

    /**
     * [API 역할] 결제 완료 시 호출됨
     * @RestController가 아니므로 @ResponseBody를 붙여야 JSON/텍스트 응답이 가능합니다.
     */
    @PostMapping("/api/subscription/complete")
    @ResponseBody
    public String completePurchase(@RequestBody Map<String, Object> payload, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        
        SubscriptionDTO currentSub = subscriptionDAO.findActiveSubscriptionByUNo(loginUser.getUNo());
        if (currentSub != null && "ACTIVE".equals(currentSub.getSStatus())) {
            return "ERROR:ALREADY_SUBSCRIBED"; // 이미 구독 중이면 차단
        }
        
        
        try {
            // 서비스에서 DB 저장 (구독정보 + 결제로그)
            subscriptionService.processPurchase(payload, loginUser);
            return "SUCCESS";
        } catch (Exception e) {
            e.printStackTrace();
            return "ERROR: " + e.getMessage();
        }
    }

    /**
     * [View 역할] 마이페이지 화면 로딩
     */
    @GetMapping("/user/mypage")
    public String myPage(HttpSession session, Model model) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/";

        // DB에서 최신 구독 정보를 직접 조회해서 모델에 담기 (정보 갱신 핵심)
        SubscriptionDTO sub = subscriptionDAO.findActiveSubscriptionByUNo(loginUser.getUNo());
        model.addAttribute("subscription", sub);

        return "user/MyPage"; 
    }
    
    @PostMapping("/api/subscription/cancel")
    @ResponseBody
    public String cancelSubscription(jakarta.servlet.http.HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            // 필요시 HTTP 상태 코드를 반환하거나, 간단한 메시지를 반환합니다.
            return "LOGIN_REQUIRED"; 
        }

        try {
            // 데이터베이스에서 구독 상태 업데이트 (예: s_cancel_reserved를 'T'로 변경)
            int result = subscriptionDAO.updateCancelStatus(loginUser.getUNo()); // 실제 DAO 메서드 이름 사용
            
            return (result > 0) ? "SUCCESS" : "FAIL";
        } catch (Exception e) {
            e.printStackTrace();
            return "ERROR";
        }
    }
    
    
    @PostMapping("/api/subscription/reverseCancel")
    @ResponseBody
    public String reverseCancelSubscription(jakarta.servlet.http.HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "LOGIN_REQUIRED"; 
        }

        try {
            // DB에서 s_cancel_reserved를 'F'로 되돌리는 DAO 메서드 호출
            int result = subscriptionDAO.updateCancelStatusReverse(loginUser.getUNo()); 
            return (result > 0) ? "SUCCESS" : "FAIL";
        } catch (Exception e) {
            e.printStackTrace();
            return "ERROR";
        }
    }
}