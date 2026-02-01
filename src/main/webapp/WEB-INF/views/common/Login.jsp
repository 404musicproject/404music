<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
/* 로그인 모달 배경 */
.login-modal-overlay {
    position: fixed;
    top: 0; left: 0; 
    width: 100%; height: 100%;
    background: rgba(0, 0, 0, 0.85);
    display: none;
    justify-content: center;
    align-items: center;
    z-index: 2000;
}

/* 모달 본체 */
.login-modal-content {
    background-color: #000;
    border: 2px solid #ff0055;
    padding: 40px;
    width: 400px;
    box-shadow: 0 0 20px rgba(255, 0, 85, 0.3);
    text-align: center;
    position: relative;
}

.login-modal-content h3 {
    color: #00f2ff;
    margin-bottom: 30px;
    font-family: 'Courier New', monospace;
    text-transform: uppercase;
    letter-spacing: 2px;
}

.close-btn {
    position: absolute;
    top: 15px;
    right: 20px;
    color: #ff0055;
    font-size: 24px;
    cursor: pointer;
    line-height: 1;
}

/* 입력 필드 및 버튼 레이아웃 */
.modal-login-form {
    display: flex;
    flex-direction: column;
    gap: 15px;
}

.modal-login-form input {
    width: 100%;
    background: transparent;
    border: 1px solid #00f2ff;
    padding: 12px 15px;
    color: #fff;
    outline: none;
    box-sizing: border-box;
}

.modal-login-form input:focus {
    border-color: #ff0055;
    box-shadow: 0 0 5px #ff0055;
}

.login-submit-btn {
    width: 100%;
    background-color: #ff0055;
    border: none;
    color: #fff;
    padding: 12px;
    font-weight: bold;
    cursor: pointer;
    text-transform: uppercase;
    transition: 0.3s;
}

.login-submit-btn:hover {
    background-color: #00f2ff;
    color: #000;
}

/* SNS 로그인 섹션 */
.social-login-title {
    margin: 25px 0 15px;
    color: #00f2ff;
    font-size: 0.8em;
    letter-spacing: 1px;
}

.social-btns-container {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.btn-social {
    display: block;
    width: 100%;
    padding: 10px;
    text-decoration: none;
    font-size: 14px;
    font-weight: bold;
    box-sizing: border-box;
    text-align: center;
}

.btn-kakao { background-color: #FEE500; color: #3C1E1E; }
.btn-naver { background-color: #03C75A; color: #fff; }
.btn-google { background-color: #fff; color: #000; border: 1px solid #ccc; }
</style>

<div id="loginModal" class="login-modal-overlay">
    <div class="login-modal-content">
        <span class="close-btn" onclick="closeLoginModal()">&times;</span>
        <h3>SYSTEM LOGIN</h3>
        
<form id="modalLoginForm" class="modal-login-form">
    <input type="hidden" id="csrfToken" value="${_csrf.token}"/>
    
    <input type="text" id="modalId" placeholder="ID (EMAIL)" required>
    <input type="password" id="modalPw" placeholder="PASSWORD" required> 
    
    <button type="button" class="login-submit-btn" onclick="ajaxLogin()">ACCESS START</button>
</form>

        <div class="social-login-title">───── SNS LOGIN ─────</div>
        <div class="social-btns-container">
            <a href="${pageContext.request.contextPath}/oauth2/authorization/kakao" class="btn-social btn-kakao">카카오 로그인</a>
            <a href="/oauth2/authorization/naver" class="btn-social btn-naver">네이버 로그인</a>
            <a href="/oauth2/authorization/google" class="btn-social btn-google">구글 로그인</a>
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

    $(window).on('click', function(e) {
        if ($(e.target).is('#loginModal')) {
            closeLoginModal();
        }
    });
    $(document).ready(function() {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('loginError')) {
            alert("아이디 또는 비밀번호가 틀렸습니다.");
            openLoginModal(); // 에러 시 다시 팝업 띄우기
        }
    });
    
    function ajaxLogin() {
        const loginData = {
            uId: $('#modalId').val(),
            uPassword: $('#modalPw').val()
        };

        $.ajax({
            url: '/api/user/login',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(loginData),
            beforeSend: function(xhr) {
                // CSRF 토큰 헤더 추가 (Security 설정 때문)
                xhr.setRequestHeader("X-CSRF-TOKEN", $('#csrfToken').val());
            },
            success: function(res) {
                alert("환영합니다!");
                // 현재 페이지를 유지하면서 서버 세션만 새로 읽어오려면 reload가 가장 깔끔합니다.
                location.reload(); 
            },
            error: function(xhr) {
                alert("비밀번호가 틀렸거나 없는 계정입니다.");
            }
        });
    }
</script>