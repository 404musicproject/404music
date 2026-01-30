<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<style>

 body { background-color: #050505; color: #00f2ff; font-family: 'Courier New', monospace; }
    .main-container { min-height: auto; padding: 40px; max-width: 900px; margin: 0 auto; }
    .glitch-title { text-shadow: 2px 2px #ff0055; border-left: 5px solid #ff0055; padding-left: 15px; margin-bottom: 30px; font-size: 30px; }
    .faq-container { border-top: 1px solid #333; margin-top: 20px; }
    .faq-item { border-bottom: 1px solid #222; }
    .faq-question { 
        padding: 12px 15px; cursor: pointer; display: flex; align-items: center;
        transition: background 0.3s; font-weight: bold; color: #00f2ff; font-size:13px;
    }
    .faq-question:hover { background: rgba(0, 242, 255, 0.05); }
    .faq-question::before { content: 'Q.'; color: #ff0055; margin-right: 12px; font-size: 1.1em; }
    
    .faq-answer { 
        display: none; padding: 18px 20px 18px 45px; 
        background-color: #0a0a0a; color: #ccc; line-height: 1.5;
        border-top: 1px dashed #333; font-size:12px;
    }
    .arrow { margin-left: auto; color: #ff0055; font-size: 0.8em; } 
    
    /* 페이징 컨테이너 */
	.pagination-container {
    text-align: center;
    margin-top: 20px;
    display: flex;
    justify-content: center;
    gap: 8px;
    padding-bottom: 40px; 
}
	
	/* 페이지 번호 버튼 */
	.page-btn {
	    background: transparent;
	    border: 1px solid #00f2ff;
	    color: #00f2ff;
	    padding: 5px 10px;
	    cursor: pointer;
	    font-size: 11px;
	    font-family: inherit;
	    transition: 0.3s;
}
	
	/* 현재 선택된 페이지 버튼 */
	.page-btn.active {
	    background: #00f2ff;
	    color: #000;
	    box-shadow: 0 0 10px #00f2ff;
}
	
	.page-btn:hover:not(.active) {
	    border-color: #ff0055;
	    color: #ff0055;
}
</style>
</head>
<body>
<div class="main-container">
 <h2 class="glitch-title">FAQ</h2>
<div class="faq-container">
    <!-- 항목 1 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(1)">
            결제 수단은 무엇이 있나요? <span class="arrow" id="arrow-1">▼</span>
        </div>
        <div id="answer-1" class="faq-answer">
            현재 카카오페이를 지원하며, 추후 애플페이와 구글페이가 추가될 예정입니다.
        </div>
    </div>

    <!-- 항목 2 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(2)">
            구독 해지는 어디서 하나요? <span class="arrow" id="arrow-2">▼</span>
        </div>
        <div id="answer-2" class="faq-answer">
            마이페이지 > 구독관리에서 해지 예약이 가능합니다. 결제 후 7일 이내에 음원 스트리밍이나 다운로드 기록이 없을 경우 전액 환불받으실 수 있습니다.
        </div>
    </div>

    <!-- 항목 3 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(3)">
            환불 규정이 어떻게 되나요? <span class="arrow" id="arrow-3">▼</span>
        </div>
        <div id="answer-3" class="faq-answer">
            결제 후 7일 이내, 서비스 이용 기록(스트리밍, 다운로드)이 없는 경우 전액 환불됩니다.
        </div>
    </div>

    <!-- 항목 4 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(4)">
            결제가 실패했다고 나옵니다. <span class="arrow" id="arrow-4">▼</span>
        </div>
        <div id="answer-4" class="faq-answer">
            카드 잔액 부족이나 한도 초과, 혹은 브라우저의 팝업 차단 설정을 확인해 주세요.
        </div>
    </div>
    <!-- 항목 5 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(5)">
            정기결제일 변경이 가능한가요? <span class="arrow" id="arrow-5">▼</span>
        </div>
        <div id="answer-5" class="faq-answer">
            정기결제일은 시스템상 첫 결제일을 기준으로 고정되며 변경이 어렵습니다.
        </div>
    </div>
    <!-- 항목 6 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(6)">
            영수증(매출전표)은 어디서 받나요? <span class="arrow" id="arrow-6">▼</span>
        </div>
        <div id="answer-6" class="faq-answer">
            결제 완료 시 이메일로 발송되며, 결제 내역에서도 출력 가능합니다.
        </div>
    </div>
    <!-- 항목 7 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(7)">
            오프라인 재생이 가능한가요? <span class="arrow" id="arrow-7">▼</span>
        </div>
        <div id="answer-7" class="faq-answer">
            본 서비스는 실시간 스트리밍 전용으로, 오프라인 저장 기능은 준비 중입니다.
        </div>
    </div>
    <!-- 항목 8 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(8)">
            음질 설정은 어디서 하나요? <span class="arrow" id="arrow-8">▼</span>
        </div>
        <div id="answer-8" class="faq-answer">
            재생 플레이어 하단의 설정(Gear) 아이콘에서 AAC 128kbps~320kbps를 선택할 수 있습니다.
        </div>
    </div>
    <!-- 항목 9 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(9)">
            가사가 나오지 않는 곡이 있어요. <span class="arrow" id="arrow-9">▼</span>
        </div>
        <div id="answer-9" class="faq-answer">
            일부 권리사의 요청에 따라 가사가 제공되지 않을 수 있습니다. 1:1 문의로 제보해 주세요.
        </div>
    </div>
    <!-- 항목 10 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(10)">
            음악이 자꾸 끊겨요. <span class="arrow" id="arrow-10">▼</span>
        </div>
        <div id="answer-10" class="faq-answer">
            네트워크 환경을 점검하시거나, 앱 설정에서 [캐시 데이터 삭제]를 진행해 보세요.
        </div>
    </div>
    <!-- 항목 11 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(11)">
            멀티 디바이스 동시 접속이 되나요? <span class="arrow" id="arrow-11">▼</span>
        </div>
        <div id="answer-11" class="faq-answer">
            계정당 1대의 기기에서만 재생이 가능하며, 다른 기기 접속 시 기존 연결은 해제됩니다.
        </div>
    </div>
    <!-- 항목 12 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(12)">
            안전모드(Explicit) 해제는 어떻게 하나요? <span class="arrow" id="arrow-12">▼</span>
        </div>
        <div id="answer-12" class="faq-answer">
            성인 인증 완료 후 설정 메뉴에서 '청소년 유해물 콘텐츠 노출'을 활성화하세요.
        </div>
    </div>
    <!-- 항목 13 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(13)">
            비밀번호를 잊어버렸어요. <span class="arrow" id="arrow-13">▼</span>
        </div>
        <div id="answer-13" class="faq-answer">
            로그인 페이지의 [비밀번호 찾기]를 통해 등록된 이메일로 임시 번호를 발송해 드립니다.
        </div>
    </div>
    <!-- 항목 14 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(14)">
            회원 탈퇴는 어떻게 하나요? <span class="arrow" id="arrow-14">▼</span>
        </div>
        <div id="answer-14" class="faq-answer">
            [마이페이지 > 계정 관리] 하단에서 가능하며, 탈퇴 시 모든 데이터는 복구 불가합니다.
        </div>
    </div>
    <!-- 항목 15 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(15)">
            개인정보 수정은 어디서 하나요? <span class="arrow" id="arrow-	15">▼</span>
        </div>
        <div id="answer-15" class="faq-answer">
            닉네임, 프로필 사진 등은 계정 설정 메뉴에서 상시 변경 가능합니다.
        </div>
    </div>
    <!-- 항목 16 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(16)">
            SNS 계정 연동을 해제하고 싶어요. <span class="arrow" id="arrow-16">▼</span>
        </div>
        <div id="answer-16" class="faq-answer">
            설정 내 [연동 관리]에서 카카오, 네이버 등의 연결을 관리할 수 있습니다.
        </div>
    </div>
    <!-- 항목 17 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(17)">
            장기 미접속 시 계정이 휴면 처리되나요? <span class="arrow" id="arrow-17">▼</span>
        </div>
        <div id="answer-17" class="faq-answer">
            1년 이상 미접속 시 개인정보 보호를 위해 휴면 계정으로 전환됩니다.
        </div>
    </div>
    <!-- 항목 18 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(18)">
            아이디를 변경할 수 있나요? <span class="arrow" id="arrow-18">▼</span>
        </div>
        <div id="answer-18" class="faq-answer">
            한번 생성된 아이디는 변경이 불가능하오니 신중하게 생성해 주세요.
        </div>
    </div>
    <!-- 항목 19 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(19)">
            내가 만든 플레이리스트를 공유하고 싶어요. <span class="arrow" id="arrow-19">▼</span>
        </div>
        <div id="answer-19" class="faq-answer">
            플레이리스트 설정에서 '공개'로 전환한 뒤 링크를 복사하여 공유할 수 있습니다.
        </div>
    </div>
    <!-- 항목 20 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(20)">
            좋아요(하트)한 곡은 어디서 보나요? <span class="arrow" id="arrow-20">▼</span>
        </div>
        <div id="answer-20" class="faq-answer">
            보관함의 [좋아요 표시한 곡] 폴더에서 모아볼 수 있습니다.
        </div>
    </div>
    <!-- 항목 21 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(21)">
            음악 데이터 정보가 틀려요. <span class="arrow" id="arrow-21">▼</span>
        </div>
        <div id="answer-21" class="faq-answer">
            곡명, 가수명 오류는 1:1 문의로 제보해 주시면 24시간 이내에 수정됩니다.
        </div>
    </div>
    <!-- 항목 22 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(22)">
            플레이리스트 최대 저장 곡수는 몇 개인가요? <span class="arrow" id="arrow-22">▼</span>
        </div>
        <div id="answer-22" class="faq-answer">
            리스트당 최대 1,000곡까지 저장이 가능합니다.
        </div>
    </div>
    <!-- 항목 23 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(23)">
            최근 감상 히스토리를 삭제하고 싶어요. <span class="arrow" id="arrow-23">▼</span>
        </div>
        <div id="answer-23" class="faq-answer">
            보관함 내 [최근 감상 곡] 메뉴에서 개별 혹은 전체 삭제가 가능합니다.
        </div>
    </div>
    <!-- 항목 24 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(24)">
            권장 브라우저 환경이 어떻게 되나요? <span class="arrow" id="arrow-24">▼</span>
        </div>
        <div id="answer-24" class="faq-answer">
            크롬(Chrome) 및 엣지(Edge) 최신 버전에 최적화되어 있습니다.
        </div>
    </div>
    <!-- 항목 25 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(25)">
            앱이 자꾸 강제 종료됩니다. <span class="arrow" id="arrow-25">▼</span>
        </div>
        <div id="answer-25" class="faq-answer">
            기기의 OS 버전을 최신으로 업데이트하거나 앱을 재설치해 보시기 바랍니다.
        </div>
    </div>
    <!-- 항목 26 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(26)">
            푸시 알림을 끄고 싶어요. <span class="arrow" id="arrow-26">▼</span>
        </div>
        <div id="answer-26" class="faq-answer">
            설정 메뉴의 [알림]에서 마케팅 정보 및 알림 수신을 거부할 수 있습니다.
        </div>
    </div>
    <!-- 항목 27 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(27)">
            소리가 너무 작게 들려요. <span class="arrow" id="arrow-27">▼</span>
        </div>
        <div id="answer-27" class="faq-answer">
            설정에서 [음량 평준화(Normalization)] 기능을 켜면 곡별 음량 차이를 줄일 수 있습니다.
        </div>
    </div>
    <!-- 항목 28 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(28)">
            해외에서도 이용이 가능한가요? <span class="arrow" id="arrow-28">▼</span>
        </div>
        <div id="answer-28" class="faq-answer">
            저작권 협의에 따라 일부 국가에서는 서비스 이용이 제한될 수 있습니다.
        </div>
    </div>
    <!-- 항목 29 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(29)">
            캐시 데이터 용량이 너무 커요. <span class="arrow" id="arrow-29">▼</span>
        </div>
        <div id="answer-29" class="faq-answer">
            설정에서 [캐시 삭제]를 누르면 원활한 스트리밍을 위해 임시 저장된 데이터가 정리됩니다.
        </div>
    </div>
    <!-- 항목 30 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(30)">
           신곡 업데이트 주기가 어떻게 되나요? <span class="arrow" id="arrow-30">▼</span>
        </div>
        <div id="answer-30" class="faq-answer">
            국내외 최신 곡은 유통사 공급 즉시 실시간으로 업데이트됩니다.
        </div>
    </div>
</div>
</div>
<div id="pagination" class="pagination-container"></div>
<script>
function toggleFaq(id) {
    const answer = document.getElementById('answer-' + id);
    const arrow = document.getElementById('arrow-' + id);
    const isVisible = answer.style.display === 'block';
    
    // 모든 답변 초기화 (선택사항: 하나만 열리게 하고 싶을 때)
    document.querySelectorAll('.faq-answer').forEach(el => el.style.display = 'none');
    document.querySelectorAll('.arrow').forEach(el => el.innerText = '▼');
    
    // 현재 선택한 것 토글
    if (!isVisible) {
        answer.style.display = 'block';
        arrow.innerText = '▲';
    }
}

const rowsPerPage = 10; // 한 페이지에 보여줄 개수
const faqItems = document.querySelectorAll('.faq-item');
const pageCount = Math.ceil(faqItems.length / rowsPerPage);
const paginationContainer = document.getElementById('pagination');

function showPage(page) {
    const start = (page - 1) * rowsPerPage;
    const end = start + rowsPerPage;

    // 1. 일단 모두 숨기기
    faqItems.forEach((item, idx) => {
        item.style.display = 'none';
        // 페이지 바뀔 때 열려있는 답변 닫기
        const answer = item.querySelector('.faq-answer');
        if(answer) answer.style.display = 'none';
    });

    // 2. 해당 페이지 범위(10개)만 보여주기
    for (let i = start; i < end; i++) {
        if (faqItems[i]) faqItems[i].style.display = 'block';
    }

    // 3. 버튼 활성화 표시
    document.querySelectorAll('.page-btn').forEach((btn, idx) => {
        btn.classList.toggle('active', idx === page - 1);
    });
}

function initPagination() {
    paginationContainer.innerHTML = ''; 

    for (let i = 1; i <= pageCount; i++) {
        const btn = document.createElement('button');
        btn.innerText = i;
        btn.className = 'page-btn';
        btn.onclick = () => showPage(i);
        paginationContainer.appendChild(btn);
    }
    
    showPage(1); // 첫 페이지 기본 노출
}

// 문서 로드 시 실행
document.addEventListener('DOMContentLoaded', initPagination);
</script>
</body>
</html>