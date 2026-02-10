package com.project.springboot.dao;

import org.apache.ibatis.annotations.Mapper;

import com.project.springboot.dto.PaymentLogDTO;
import com.project.springboot.dto.SubscriptionDTO;

@Mapper
public interface ISubscriptionDAO {
    // 1. 구독 정보 생성 (sNo 자동 생성됨)
    int insertSubscription(SubscriptionDTO subscription);
    
    // 2. 결제 로그 기록
    int insertPaymentLog(PaymentLogDTO paymentLog);
    
    // 3. 현재 활성 구독 조회 (마이페이지용)
    SubscriptionDTO findActiveSubscriptionByUNo(int uNo);
    
 // 4. 구독 해지 예약 상태 업데이트 (T로 변경)
    int updateCancelStatus(int uNo);
    
 // 5. 구독 해지 예약 철회 (F로 변경)
    int updateCancelStatusReverse(int uNo);
 // 반환값이 0보다 크면 구독 중인 사용자
    int checkActiveSubscription(int uNo);
}