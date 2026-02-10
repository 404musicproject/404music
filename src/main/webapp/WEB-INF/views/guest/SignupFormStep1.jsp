<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>회원가입</title>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <link rel="stylesheet" href="/css/SignupFormStep1.css">
    <script src="${pageContext.request.contextPath}/js/validateForm.js"></script>
</head>
<body>
    <jsp:include page="../common/Header.jsp" />
    <main class="signup-main">
      <div class="signup-wrap">
        <h2>회원가입 인증</h2>

        <div class="progress-container">
            <div class="progress-step active">
                <span class="step-num">01</span>
                <span class="step-text">인증</span>
            </div>
            <div class="progress-line"></div>
            <div class="progress-step">
                <span class="step-num">02</span>
                <span class="step-text">정보</span>
            </div>
            <div class="progress-line"></div>
            <div class="progress-step">
                <span class="step-num">03</span>
                <span class="step-text">프로필</span>
            </div>
        </div>

        <form id="signupForm">
            <div>
                <input type="email" id="uId" name="uId" placeholder="이메일 주소" required>
                <button type="button" id="btnSendMail" onclick="sendMail()">인증번호 받기</button>
            </div>

            <div id="authDiv" style="display:none;">
                <input type="text" id="inputCode" placeholder="인증번호 6자리">
                <button type="button" onclick="checkCode()">확인</button>
                <span id="authMsg"></span>
            </div>

            <input type="password" id="uPassword" name="uPassword" placeholder="비밀번호" required><br>
            
            <button type="button" id="btnSubmit" onclick="submitSignup()" disabled>가입하기</button>
        </form>

        <script>
            let verified = false;

            function sendMail() {
                const email = $('#uId').val();
                if(!email) return alert("이메일을 입력하세요.");

                $.post("/api/auth/send-email", { email: email }, function(res) {
                    if(res === "success") {
                        alert("인증번호가 발송되었습니다.");
                        $('#authDiv').show();
                        $('#uId').attr('readonly', true);
                    }
                });
            }

            function checkCode() {
                const code = $('#inputCode').val();
                $.post("/api/auth/verify-code", { code: code }, function(res) {
                    if(res === "success") {
                        alert("인증되었습니다.");
                        verified = true;
                        
                        $('#btnSendMail').hide();
                        $('#authDiv').hide();
                        
                        $('#authMsg').text("✅ 이메일 인증 완료").css("color", "green");
                        $('#btnSubmit').attr('disabled', false);
                    } else {
                        alert("번호가 틀렸습니다.");
                    }
                });
            }

            function submitSignup() {
                if(!verified) return alert("이메일 인증이 필요합니다.");
                
             	// 2. 외부 validateForm.js의 유효성 검사 함수 호출
                if(!validateAll()) return; // 검사 탈락 시 중단
                
                // JSON.stringify를 하지 않고, 일반 객체 그대로 보냅니다.
                const signupData = {
                    "uId": $('#uId').val(), 
                    "uPassword": $('input[name="uPassword"]').val()
                };

                $.ajax({
                    url: '/api/user/guest/signup/step1',
                    type: 'POST',
                    // contentType 설정을 제거하거나 'application/x-www-form-urlencoded'로 둡니다.
                    // data: JSON.stringify(signupData), // 이 부분을 아래처럼 수정
                    data: signupData, 
                    success: function(res) {
                        alert("가입 성공!");
                        location.href = res; 
                    },
                    error: function(xhr) {
                        if (xhr.status === 400) {
                            // 서버에서 ResponseEntity.badRequest().body("이미 사용 중인 이메일")로 보낸 메세지 출력
                            alert(xhr.responseText); 
                        } else {
                            alert("가입 처리 중 오류가 발생했습니다. (에러코드: " + xhr.status + ")");
                        }
                    }
                });
            }
        </script>
      </div>
    </main>
    <jsp:include page="../common/Footer.jsp" />
</body>
</html>