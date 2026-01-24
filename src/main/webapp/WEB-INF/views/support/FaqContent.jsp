<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<style>

 body { background-color: #050505; color: #00f2ff; font-family: 'Courier New', monospace; }
    /* 공지사항과 동일하게 중앙 정렬 및 여백 설정 */
    .main-container { min-height: 700px; padding: 60px 40px; max-width: 1000px; margin: 0 auto; }
    .glitch-title { text-shadow: 2px 2px #ff0055; border-left: 5px solid #ff0055; padding-left: 15px; margin-bottom: 40px; font-size: 24px; }
    .faq-container { border-top: 1px solid #333; margin-top: 20px; }
    .faq-item { border-bottom: 1px solid #222; }
    .faq-question { 
        padding: 20px; cursor: pointer; display: flex; align-items: center;
        transition: background 0.3s; font-weight: bold; color: #00f2ff;
    }
    .faq-question:hover { background: rgba(0, 242, 255, 0.05); }
    .faq-question::before { content: 'Q.'; color: #ff0055; margin-right: 15px; font-size: 1.2em; }
    
    .faq-answer { 
        display: none; padding: 25px 20px 25px 55px; 
        background-color: #0a0a0a; color: #ccc; line-height: 1.6;
        border-top: 1px dashed #333;
    }
    .arrow { margin-left: auto; color: #ff0055; font-size: 0.8em; }
</style>
</head>
<body>
<div class="main-container">
 <h2 class="glitch-title"> FAQ</h2>
<div class="faq-container">
    <!-- 항목 1 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(1)">
            결제는 어떤 수단을 지원하나요? <span class="arrow" id="arrow-1">▼</span>
        </div>
        <div id="answer-1" class="faq-answer">
            카카오페이를 제공하고 있습니다. 2027년부터는 애플페이와 구글페이 서비스가 통합되어 더욱 편리하게 이용 가능합니다.
        </div>
    </div>

    <!-- 항목 2 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(2)">
            구독 해지 및 환불 정책이 궁금해요. <span class="arrow" id="arrow-2">▼</span>
        </div>
        <div id="answer-2" class="faq-answer">
            마이페이지 > 구독관리에서 해지 예약이 가능합니다. 결제 후 7일 이내에 음원 스트리밍이나 다운로드 기록이 없을 경우 전액 환불받으실 수 있습니다.
        </div>
    </div>

    <!-- 항목 3 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(3)">
            오프라인 재생이 가능한가요? <span class="arrow" id="arrow-3">▼</span>
        </div>
        <div id="answer-3" class="faq-answer">
            404MUSIC은 온라인 서비스로 오프라인 재생은 제공하지 않고 있습니다.
        </div>
    </div>

    <!-- 항목 4 -->
    <div class="faq-item">
        <div class="faq-question" onclick="toggleFaq(4)">
            가사 및 앨범 정보가 틀려요. <span class="arrow" id="arrow-4">▼</span>
        </div>
        <div id="answer-4" class="faq-answer">
            데이터 오류 신고는 1:1 문의를 통해 접수해 주세요. 404Music 시스템 검토 후 보통 24시간 이내에 수정 반영되며, 제보해주신 분께는 소정의 포인트가 지급될 수 있습니다.
        </div>
    </div>
</div>
</div>
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
</script>
</body>
</html>