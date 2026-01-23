package com.project.springboot.service;

import java.time.LocalDateTime;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.project.springboot.dao.ISubscriptionDAO;
import com.project.springboot.dto.PaymentLogDTO;
import com.project.springboot.dto.SubscriptionDTO;
import com.project.springboot.dto.UserDTO;

@Service // [1] 서비스 어노테이션 필수
public class SubscriptionService {

    @Autowired // [2] DAO 주입
    private ISubscriptionDAO subscriptionDAO;

    @Transactional // [3] 하나라도 실패하면 롤백
    public void processPurchase(Map<String, Object> payload, UserDTO loginUser) {
        
        // 1. 구독 정보(SubscriptionDTO) 생성 및 저장
        String planType = (String) payload.get("planType");
        SubscriptionDTO sub = new SubscriptionDTO();
        sub.setUNo(loginUser.getUNo());
        sub.setSSub(planType.equals("YEAR") ? "연간 프리미엄" : "월간 프리미엄");
        sub.setSStatus("ACTIVE");
        sub.setSCancelReserved("F");
        sub.calculateDates(planType); // 2026-01-23 기준 날짜 자동 계산
        
        // MyBatis의 useGeneratedKeys="true" 설정으로 sub.sNo가 채워져야 함
        subscriptionDAO.insertSubscription(sub); 

        // 2. 결제 로그(PaymentLogDTO) 생성 및 저장
        PaymentLogDTO log = new PaymentLogDTO();
        log.setSNo(sub.getSNo()); 
        log.setMerchantUid((String) payload.get("merchantUid"));
        log.setPAmount(Long.parseLong(payload.get("amount").toString()));
        log.setPPaidAt(LocalDateTime.now());
        
        subscriptionDAO.insertPaymentLog(log);
    }
}