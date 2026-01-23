package com.project.springboot.dto;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class PaymentLogDTO {
	    private Integer pNo;           // 결제 로그 번호
	    private Integer sNo;           // 연결된 구독 번호
	    private String merchantUid;    // 고유 결제 주문번호 (예: ORD20260123-001)
	    private Long pAmount;          // 결제 금액
	    private LocalDateTime pPaidAt; // 결제 일시
	
}
