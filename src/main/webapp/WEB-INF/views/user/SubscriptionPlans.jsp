<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>이용권 구매 | Music Platform</title>

    
    <!-- 아임포트/포트원 SDK -->
    <script src="https://cdn.iamport.kr/js/iamport.payment-1.2.0.js"></script>
    <style>
        body { background: #0a0a0a; color: #fff; font-family: 'Pretendard', sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .plan-card { background: #151515; border: 2px solid #ff0055; border-radius: 20px; width: 350px; padding: 40px; text-align: center; box-shadow: 0 0 20px rgba(255, 0, 85, 0.2); }
        .plan-title { font-size: 28px; font-weight: 800; color: #ff0055; margin-bottom: 10px; }
        .plan-desc { color: #aaa; font-size: 14px; margin-bottom: 30px; line-height: 1.6; }
        
        .price-box { margin-bottom: 30px; }
        .price { font-size: 36px; font-weight: bold; }
        .period { font-size: 16px; color: #888; }

        .select-group { display: flex; gap: 10px; margin-bottom: 30px; }
        .select-btn { flex: 1; padding: 12px; border: 1px solid #333; background: #222; color: #fff; border-radius: 10px; cursor: pointer; transition: 0.3s; }
        .select-btn.active { border-color: #ff0055; background: rgba(255, 0, 85, 0.1); color: #ff0055; }

        .buy-btn { width: 100%; padding: 18px; background: #ff0055; border: none; border-radius: 10px; color: #fff; font-size: 18px; font-weight: bold; cursor: pointer; box-shadow: 0 4px 15px rgba(255, 0, 85, 0.4); }
        .buy-btn:hover { background: #ff3377; }
    </style>
</head>
<body>
<header>
	<jsp:include page="/WEB-INF/views/common/Header.jsp" />
</header>


<!-- 현재 구독 중인지 여부를 체크 -->
<c:set var="isActive" value="${not empty subscription and subscription.SStatus eq 'ACTIVE'}" />

<div class="plan-card">
    <div class="plan-title">404MUSIC PASS</div>
    <div class="plan-desc">광고 없는 스트리밍<br>그리고 초고음질 음악 감상까지.</div>

    <div class="price-box">
        <span id="display-price" class="price">₩ 7,900</span>
        <span id="display-period" class="period">/ 월</span>
    </div>

    <div class="select-group">
        <button type="button" id="btn-month" class="select-btn active" onclick="selectPlan('MONTH', 7900)">월간 결제</button>
        <button type="button" id="btn-year" class="select-btn" onclick="selectPlan('YEAR', 79000)">연간 결제</button>
    </div>

    <button type="button" class="buy-btn" onclick="requestPay()">지금 구독하기</button>
</div>

<script>
let currentPlan = 'MONTH';
let currentAmount = 7900;

function selectPlan(plan, amount) {
    currentPlan = plan;
    currentAmount = amount;

    // UI 업데이트
    document.getElementById('display-price').innerText = "₩ " + amount.toLocaleString();
    document.getElementById('display-period').innerText = (plan === 'MONTH') ? "/ 월" : "/ 년";
    
    document.getElementById('btn-month').classList.toggle('active', plan === 'MONTH');
    document.getElementById('btn-year').classList.toggle('active', plan === 'YEAR');
}

function requestPay() {
    if (!window.IMP) {
        alert("결제 모듈이 아직 로드되지 않았습니다. 잠시 후 다시 시도해주세요.");
        return;
    }
    
    const IMP = window.IMP;
    IMP.init("imp05802164"); 

    const merchantUid = "ORD-20260123-" + new Date().getTime();

    IMP.request_pay({
        pg: "kakaopay.TCSUBSCRIP", 
        pay_method: "card",
        merchant_uid: merchantUid,
        name: "404MUSIC 패스 (" + (currentPlan === 'MONTH' ? "월간" : "연간") + ")",
        amount: currentAmount,
        buyer_email: "${sessionScope.loginUser.UId}",
        buyer_name: "${sessionScope.loginUser.UNick}"
    }, function (rsp) {
        if (rsp.success) {
            fetch('/api/subscription/complete', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    planType: currentPlan,
                    amount: currentAmount,
                    merchantUid: merchantUid
                })
            }).then(res => {
                if (res.ok) {
                    alert("구독이 시작되었습니다!");
                    location.href = "/user/mypage?tab=sub";
                }
            });
        } else {
            alert("결제 실패: " + rsp.error_msg);
        }
    });
}
</script>

</body>
</html>