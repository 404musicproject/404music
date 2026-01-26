<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>FOOTER</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Footer.css">
<style type="text/css">
/* 네온 레트로 팝업 컨테이너 (왼쪽 상단) */
.retro-popup-container {
    position: fixed;
    top: 20px;
    left: 20px;
    z-index: 10000;
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.retro-popup {
    background: rgba(10, 10, 10, 0.95); /* 반투명한 다크 배경 */
    border: 2px solid #ff0055; /* 네온 핑크/레드 테두리 */
    width: 350px;
    padding: 0;
    box-shadow: 0 0 15px #ff0055, inset 0 0 5px #ff0055; /* 안팎으로 퍼지는 네온 광원 */
    font-family: 'Courier New', monospace;
    animation: neonSlideIn 0.5s ease-out;
}

/* 상단바 (네온 헤더) */
.retro-header {
    background: #ff0055;
    color: #ffffff;
    padding: 5px 12px;
    font-size: 13px;
    font-weight: bold;
    text-shadow: 0 0 8px #ffffff;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

/* 본문 영역 (CRT 스캔라인 효과 유지) */
.retro-content {
    padding: 15px;
    max-height: 250px;
    overflow-y: auto;
    color: #00f2ff; /* 본문은 대조적인 네온 블루 */
    font-size: 14px;
    line-height: 1.6;
    background: linear-gradient(rgba(18, 16, 16, 0) 50%, rgba(0, 0, 0, 0.1) 50%), 
                linear-gradient(90deg, rgba(255, 0, 85, 0.05), rgba(0, 242, 255, 0.05));
    background-size: 100% 4px, 3px 100%;
}

/* 제목 강조 */
.retro-content strong {
    color: #ff0055;
    text-shadow: 0 0 5px #ff0055;
    display: block;
    margin-bottom: 8px;
}

/* 푸터 영역 */
.retro-footer {
    padding: 8px 12px;
    border-top: 1px solid #ff0055;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: #000;
}

.retro-btn {
    background: transparent;
    border: 1px solid #ff0055;
    color: #ff0055;
    padding: 2px 10px;
    cursor: pointer;
    font-size: 11px;
    transition: 0.3s;
}

.retro-btn:hover {
    background: #ff0055;
    color: #fff;
    box-shadow: 0 0 10px #ff0055;
}

@keyframes neonSlideIn {
    from { transform: translateX(-100%); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
}
</style>
 
</head>
<body>
    <footer class="neon-footer">
        <div class="footer-container">
            <div class="footer-copyright">
                <!-- 현재 날짜 2026년 기준 저작권 표시 -->
                <p>Copyright © 2026 404Music Inc. 모든 권리 보유.</p>
            </div>
            
            <nav class="footer-nav">
                <!-- 개인정보처리방침은 법적 고지사항이므로 단독 페이지 유지 권장 -->
                <a href="${pageContext.request.contextPath}/terms" class="neon-link">개인정보처리방침</a>
                <span class="sep">|</span>
                
                <!-- [수정] 통합 고객 센터의 NOTICE 탭으로 연결 -->
                <a href="${pageContext.request.contextPath}/support?mode=notice" class="neon-link">공지사항</a>
                <span class="sep">|</span>
                
                <!-- [수정] 통합 고객 센터의 INQUIRY 탭으로 연결 -->
                <a href="${pageContext.request.contextPath}/support?mode=inquiry" class="neon-link">1:1 문의</a>
                <span class="sep">|</span>
                
                <!-- [추가] 통합 고객 센터의 FAQ 탭으로 연결 -->
                <a href="${pageContext.request.contextPath}/support?mode=faq" class="neon-link">FAQ</a>
            </nav>
        </div>
    </footer>
<script>
$(document).ready(function() {
    const path = window.location.pathname;
    // 2026-01-25: 메인 페이지 혹은 인덱스 페이지에서만 실행
    if (path === '/' || path.includes('index') || path === '/404music/') {
        $.ajax({
            url: '${pageContext.request.contextPath}/api/getPopups',
            method: 'GET',
            success: function(data) {
                if(data && data.length > 0) {
                    data.forEach(function(popup) {
                        const pNo = popup.noticeNo || popup.nNo;
                        const isHidden = localStorage.getItem('hide_popup_' + pNo);
                        const now = new Date().getTime();

                        if (!isHidden || now > parseInt(isHidden)) {
                            openPopupModal(popup);
                        }
                    });
                }
            }
        });
    }
});

function openPopupModal(popup) {
    if ($('.retro-popup-container').length === 0) {
        $('body').append('<div class="retro-popup-container"></div>');
    }

    const pNo = popup.noticeno || popup.noticeNo || popup.nNo || Date.now(); 
    const title = popup.ntitle || "SYSTEM_ALERT";
    const content = popup.ncontent || "NO_DATA";

    const html = `
        <div class="retro-popup" id="popup_${pNo}">
            <div class="retro-header">
                <span>[NEON_LOG_ENTRY]</span>
                <span class="btn-x-close" style="cursor:pointer; font-size:20px; font-weight:bold;">&times;</span>
            </div>
            <div class="retro-content">
                <strong class="popup-title-target" style="color:#ff0055; text-shadow: 0 0 5px #ff0055; display:block; margin-bottom:10px;"></strong>
                <div class="popup-content-target" style="color:#ffffff !important;"></div>
            </div>
            <div class="retro-footer">
                <label style="font-size: 10px; color: #ff0055; cursor: pointer;">
                    <input type="checkbox" class="check-today" style="cursor:pointer;"> [MUTE_FOR_24H]
                </label>
                <button class="retro-btn btn-dismiss">DISMISS</button>
            </div>
        </div>
    `;
    
    const $popup = $(html);
    $('.retro-popup-container').append($popup);
    $popup.find('.popup-title-target').text("> " + title);
    $popup.find('.popup-content-target').html(content);

    // [이벤트 1] 상단 X 버튼
    $popup.find('.btn-x-close').on('click', function() {
        $(this).closest('.retro-popup').fadeOut(200, function() { $(this).remove(); });
    });

    // [이벤트 2] 하단 DISMISS 버튼
    $popup.find('.btn-dismiss').on('click', function() {
        const $currentPopup = $(this).closest('.retro-popup'); // 현재 버튼이 속한 팝업 찾기
        const isChecked = $currentPopup.find('.check-today').is(':checked');
        
        if (isChecked) {
            saveHideStatus(pNo); 
        }
        
        // 팝업 닫기 실행
        $currentPopup.fadeOut(200, function() { 
            $(this).remove(); 
            // 컨테이너가 비었으면 컨테이너도 삭제
            if ($('.retro-popup').length === 0) {
                $('.retro-popup-container').remove();
            }
        });
    });
}


// 팝업 닫기 함수
function closePopup(pNo) {
    const target = $('#popup_' + pNo);
    if (target.length > 0) {
        target.fadeOut(200, function() { $(this).remove(); });
    }
}

// localStorage 저장 전용 함수
function saveHideStatus(pNo) {
    const expire = new Date();
    // 2026-01-26 00:00:00 만료 시간 설정
    expire.setHours(24, 0, 0, 0); 
    localStorage.setItem('hide_popup_' + pNo, expire.getTime().toString());
    console.log("저장 완료. 만료시간: ", expire);
}

</script>
</body>
</html>