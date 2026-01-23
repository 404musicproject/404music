package com.project.springboot.dto;

import java.time.LocalDate;

import lombok.Data;

@Data
public class SubscriptionDTO {

	 private Integer sNo;          // 구독 번호
	    private Integer uNo;          // 사용자 번호
	    private String sSub;          // 구독 상품명 (예: "월간 프리미엄", "연간 패밀리")
	    private String sBillingKey;   // 정기 결제를 위한 빌링키
	    private String sStatus;       // 활성화, 만료, 정지 등
	    private LocalDate sNextSub;   // 다음 결제 예정일
	    private String sCancelReserved; // 해지 예약 여부 (T/F)
	    private LocalDate sStartDate; // 구독 시작일
	    private LocalDate sEndDate;   // 구독 종료일 (이용 가능 기한)

	    // 비즈니스 로직: 요금제 타입에 따른 날짜 계산 메서드
	    public void calculateDates(String planType) {
	        this.sStartDate = LocalDate.now();
	        if ("YEAR".equals(planType)) {
	            this.sNextSub = sStartDate.plusYears(1);
	            this.sEndDate = sStartDate.plusYears(1);
	        } else {
	            this.sNextSub = sStartDate.plusMonths(1);
	            this.sEndDate = sStartDate.plusMonths(1);
	        }
	    }
}
