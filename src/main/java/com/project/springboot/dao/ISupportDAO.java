package com.project.springboot.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.project.springboot.dto.InquiryDTO;
import com.project.springboot.dto.NotificationDTO;

@Mapper
public interface ISupportDAO {
    
    // --- [1:1 문의 관련] ---
    
    // 추가: 사용자 문의글 등록 (이게 있어야 저장 에러가 안 납니다)
    int insertInquiry(InquiryDTO inquiry);

    // 관리자: 문의 답변 업데이트 및 상태 변경
    int updateAnswer(InquiryDTO inquiry);
    
    // 사용자: 본인의 1:1 문의 내역 조회
    List<InquiryDTO> getMyInquiryList(@Param("userNo") int userNo);
    
    // --- [알림 관련] ---
    int insertNotification(NotificationDTO notification);
    
    // --- [공지사항] ---
    List<InquiryDTO> getNoticeList(); 
    
    void deleteNotice(@Param("noticeNo") int noticeNo);
    void updateNotice(NotificationDTO dto);
    NotificationDTO getNoticeDetail(@Param("noticeNo") int noticeNo);
    
    void deleteInquiry(int iNo);                   // 문의 삭제
    void updateInquiry(InquiryDTO inquiry);        // 문의 수정
    InquiryDTO getInquiryDetail(int iNo);          // 문의 상세 조회 (수정 폼용)
    
}