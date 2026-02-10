<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
/* [1. 로그인 모달 배경] */
.login-modal-overlay {
    position: fixed;
    top: 0; left: 0; 
    width: 100%; height: 100%;
    background: rgba(0, 0, 0, 0.9); /* 배경을 더 어둡게 */
    display: none;
    justify-content: center;
    align-items: center;
    z-index: 2000;
    backdrop-filter: blur(5px); /* 배경 살짝 흐리게 처리 */
}

/* [2. 모달 본체 - 마이페이지 neon-card 스타일 계승] */
.login-modal-content {
    background-color: #080808;
    border: 1px solid #1a1a1a;
    padding: 50px 40px;
    width: 100%;
    max-width: 420px;
    box-shadow: 0 20px 50px rgba(0,0,0,0.9);
    text-align: center;
    position: relative;
    font-family: 'Pretendard', sans-serif;
}

/* 상단 흐르는 네온 라인 (마이페이지와 동일) */
.login-modal-content::before {
    content: ""; position: absolute; top: -1px; left: -1px; right: -1px; height: 3px;
    background: linear-gradient(90deg, #ff0055, #00f2ff, #ff0055);
    background-size: 200% auto;
    animation: neonFlow 3s linear infinite;
}
@keyframes neonFlow { to { background-position: 200% center; } }

.login-modal-content h3 {
    color: #ff0055 !important; 
    text-shadow: 0 0 15px rgba(255, 0, 85, 0.5); 
    letter-spacing: 4px; 
    font-family: 'Orbitron', sans-serif;
    font-weight: 900; 
    text-transform: uppercase; 
    margin-bottom: 35px;
}

.close-btn {
    position: absolute;
    top: 15px;
    right: 20px;
    color: #555;
    font-size: 28px;
    cursor: pointer;
    line-height: 1;
    transition: 0.3s;
}
.close-btn:hover { color: #ff0055; }

/* [3. 입력 필드 레이아웃] */
.modal-login-form {
    display: flex;
    flex-direction: column;
    gap: 15px;
}

.modal-login-form input {
    width: 100%;
    background: #111;
    border: 1px solid #333;
    padding: 14px 18px;
    color: #fff;
    outline: none;
    box-sizing: border-box;
    font-family: 'Pretendard', sans-serif;
    font-size: 14px;
    transition: 0.3s;
    border-radius: 4px;
}

.modal-login-form input:focus {
    border-color: #00f2ff;
    box-shadow: 0 0 15px rgba(0, 242, 255, 0.2);
}

/* [4. 로그인 버튼 - 마이페이지 save-btn 스타일] */
.login-submit-btn {
    width: 100%;
    padding: 16px;
    background: transparent;
    border: 1px solid #00f2ff;
    color: #00f2ff;
    font-family: 'Orbitron', sans-serif;
    font-weight: 700;
    font-size: 14px;
    cursor: pointer;
    transition: 0.3s;
    letter-spacing: 2px;
    text-transform: uppercase;
    margin-top: 10px;
}

.login-submit-btn:hover {
    background: #00f2ff;
    color: #000;
    box-shadow: 0 0 25px rgba(0, 242, 255, 0.4);
}

/* [5. SNS 로그인 섹션] */
.social-login-title {
    margin: 35px 0 15px;
    color: #444;
    font-size: 11px;
    font-family: 'Orbitron', sans-serif;
    letter-spacing: 2px;
}

.social-btns-container {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.btn-social {
    display: block;
    width: 100%;
    padding: 12px;
    text-decoration: none;
    font-size: 13px;
    font-weight: 700;
    box-sizing: border-box;
    text-align: center;
    border-radius: 4px;
    transition: 0.3s;
    font-family: 'Pretendard', sans-serif;
}

.btn-social:hover { opacity: 0.8; transform: translateY(-2px); }

.btn-kakao { background-color: #FEE500; color: #3C1E1E; }
.btn-naver { background-color: #03C75A; color: #fff; }
.btn-google { background-color: #fff; color: #000; border: 1px solid #eee; }

/* [6. 추가 링크 섹션: 완전 대칭 정렬] */
.modal-footer-links {
    margin-top: 25px;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
}

.modal-footer-links a {
    flex: 1;             /* 양쪽 영역을 5:5로 균등 배분 */
    text-decoration: none;
    font-size: 13px;
    transition: 0.3s;
    font-family: 'Pretendard', sans-serif;
}

/* 왼쪽: 비밀번호 찾기 (오른쪽 정렬로 선에 붙임) */
.modal-footer-links a:first-child {
    text-align: right;
    padding-right: 15px;
    color: #ff0055;
    font-weight: 700;
    
}

/* 오른쪽: 회원가입 (왼쪽 정렬로 선에 붙임) */
.modal-footer-links a:last-child {
    text-align: left;
    padding-left: 15px;
    color: #888;
    
}

.modal-footer-links a:hover {
    color: #00f2ff !important;
    text-shadow: 0 0 8px rgba(0, 242, 255, 0.6);
}

.modal-footer-links span {
    color: #333;
    font-size: 10px;
    flex: 0 0 auto;     /* 선은 너비를 차지하지 않고 제자리 고정 */
    user-select: none;
}

/* 비밀번호 표시 아이콘 스타일 */
.pw-toggle-icon {
    position: absolute;
    right: 15px;
    top: 50%;
    transform: translateY(-50%);
    cursor: pointer;
    color: #888; /* 기본은 무난한 회색 */
    font-size: 16px;
    user-select: none;
    transition: 0.2s;
}

.pw-toggle-icon:hover {
    color: #fff; /* 마우스 올리면 흰색으로 강조 */
    text-shadow: 0 0 5px rgba(255, 255, 255, 0.5);
}
</style>
<script src="${pageContext.request.contextPath}/js/validateForm.js"></script>
<div id="loginModal" class="login-modal-overlay">
    <div class="login-modal-content">
        <span class="close-btn" onclick="closeLoginModal()">&times;</span>
        <h3>SYSTEM LOGIN</h3>
        
<form id="modalLoginForm" class="modal-login-form">
    <input type="hidden" id="csrfToken" value="${_csrf.token}"/>
    
    <input type="text" id="modalId" placeholder="ID (EMAIL)" required>
   <div style="position:relative; width: 100%;">
    <input type="password" id="modalPw" placeholder="PASSWORD" required> 
    <span id="togglePw" class="pw-toggle-icon">◎</span>
</div>
    
    <button type="button" class="login-submit-btn" onclick="ajaxLogin()">ACCESS START</button>

	<div class="modal-footer-links">
		<a href="/signup">회원가입</a>
	    <span>|</span>
	    <a href="javascript:void(0)" onclick="openFindPwModal()">비밀번호 찾기</a>
	    
	</div>
</form>

        <div class="social-login-title">───── SNS LOGIN ─────</div>
        <div class="social-btns-container">
            <a href="${pageContext.request.contextPath}/oauth2/authorization/kakao" class="btn-social btn-kakao">카카오 로그인</a>
            <a href="/oauth2/authorization/naver" class="btn-social btn-naver">네이버 로그인</a>
            <a href="/oauth2/authorization/google" class="btn-social btn-google">구글 로그인</a>
        </div>
    </div>
</div>

<div id="findPwModal" class="login-modal-overlay" style="display: none; z-index: 2100;">
    <div class="login-modal-content">
        <span class="close-btn" onclick="closeFindPwModal()">&times;</span>
        <h3>FIND PASSWORD</h3>
        <p style="color: #888; font-size: 13px; margin-bottom: 20px;">가입하신 이메일을 입력해주세요.</p>
        
        <div class="modal-login-form">
            <input type="email" id="resetEmail" placeholder="ID (EMAIL)" required>
            <button type="button" class="login-submit-btn" id="btnSendMail" onclick="sendResetMail()">SEND RESET LINK</button>
        </div>
        
        <div style="margin-top: 20px;">
            <a href="javascript:void(0)" onclick="backToLogin()" style="color: #00f2ff; font-size: 12px; text-decoration: none;">← BACK TO LOGIN</a>
        </div>
    </div>
</div>

<script>
    function openLoginModal() {
        $('#loginModal').css('display', 'flex').hide().fadeIn(200);
        $('body').css('overflow', 'hidden');
    }

    function closeLoginModal() {
        $('#loginModal').fadeOut(200);
        $('body').css('overflow', 'auto');
    }

    $(document).ready(function() {
        // 1. 에러 파라미터 체크
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('loginError')) {
            alert("아이디 또는 비밀번호가 틀렸습니다.");
            openLoginModal();
        }

        // 2. 엔터키 이벤트 등록
        $('#modalId, #modalPw').on('keypress', function (e) {
            if (e.which === 13) {
                e.preventDefault();
                ajaxLogin();
            }
        });

        // 3. 비밀번호 표시/숨기기 토글 (HTML에 아이콘 추가 필요)
        $('#togglePw').on('click', function() {
            const pwField = $('#modalPw');
            const isPassword = pwField.attr('type') === 'password';
            
            // 타입 변경
            pwField.attr('type', isPassword ? 'text' : 'password');
            
            // 아이콘 변경: ◎(보임), ⊘(숨김)
            $(this).text(isPassword ? '⊘' : '◎');
        });
    }); // document.ready 끝

    // --- 함수들을 ready 블록 밖으로 꺼내야 안정적입니다 ---

    function ajaxLogin() {
  	// 공통 유효성 검사 호출
    if (!validateAll()) return;
    const uId = $('#modalId').val();
    const uPassword = $('#modalPw').val();

    if (!uId || !uPassword) {
        alert("아이디와 비밀번호를 모두 입력해주세요.");
        return;
    }

    const loginData = {
        uId: uId,
        uPassword: uPassword
    };

    $.ajax({
        url: '/api/user/login',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(loginData),
        beforeSend: function(xhr) {
            xhr.setRequestHeader("X-CSRF-TOKEN", $('#csrfToken').val());
        },
        success: function(res) {
            // 성공 시 알림 후 페이지 새로고침
            alert("환영합니다!");
            location.href = "${pageContext.request.contextPath}/"; // reload 대신 명시적 이동
        },
        error: function(xhr) {
            // 로그인이 되었는데도 에러가 나는 경우를 대비해 상태 코드 확인
            if (xhr.status === 200 || xhr.status === 204) {
                alert("환영합니다!");
                location.href = "${pageContext.request.contextPath}/";
            } else {
                console.log("Error Status:", xhr.status);
                alert("아이디 또는 비밀번호가 일치하지 않습니다.");
            }
        }
    });
}

    function openFindPwModal() {
        $('#loginModal').hide(); 
        $('#findPwModal').css('display', 'flex').hide().fadeIn(200);
    }

    function closeFindPwModal() {
        $('#findPwModal').fadeOut(200);
        $('body').css('overflow', 'auto');
    }

    function backToLogin() {
        $('#findPwModal').hide();
        $('#loginModal').show();
    }

    function sendResetMail() {
    	if (!validateAll()) return;
        const email = $('#resetEmail').val();
        if(!email) { alert("이메일을 입력하세요."); return; }

        $('#btnSendMail').prop('disabled', true).text('SENDING...');

        $.ajax({
            url: '/api/user/find-password',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ email: email }),
            beforeSend: function(xhr) {
                xhr.setRequestHeader("X-CSRF-TOKEN", $('#csrfToken').val());
            },
            success: function(res) {
                alert(res);
                closeFindPwModal();
            },
            error: function(xhr) {
                alert(xhr.responseText || "오류가 발생했습니다.");
                $('#btnSendMail').prop('disabled', false).text('SEND RESET LINK');
            }
        });
    }
</script>