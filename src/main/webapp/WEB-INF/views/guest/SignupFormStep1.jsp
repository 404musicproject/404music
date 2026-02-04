<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>회원가입</title>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <link rel="stylesheet" href="/css/SignupFormStep1.css">
</head>
<body>
    <jsp:include page="../common/Header.jsp" />
    <main class="signup-main">
      <div class="signup-wrap">
<h2>회원가입</h2>


<div class="progress-container">
    <div class="progress-step active">
        <span class="step-num">01</span>
        <span class="step-text">AUTH</span>
    </div>
    <div class="progress-line"></div>
    <div class="progress-step">
        <span class="step-num">02</span>
        <span class="step-text">INFO</span>
    </div>
    <div class="progress-line"></div>
    <div class="progress-step">
        <span class="step-num">03</span>
        <span class="step-text">PHOTO</span>
    </div>
</div>


    <form id="signupForm">
        <div style="margin-bottom:10px;">
            <input type="email" id="uId" name="uId" placeholder="이메일 주소" required>
            <button type="button" id="btnSendMail" onclick="sendMail()">인증번호 받기</button>
        </div>

        <div id="authDiv" style="display:none; margin-bottom:10px;">
            <input type="text" id="inputCode" placeholder="인증번호 6자리">
            <button type="button" onclick="checkCode()">확인</button>
            <span id="authMsg"></span>
        </div>

        <input type="password" name="uPassword" placeholder="비밀번호" required><br>
        

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
                    $('#uId').attr('readonly', true); // 발송 후 이메일 수정 불가
                }
            });
        }

        function checkCode() {
            const code = $('#inputCode').val();
            $.post("/api/auth/verify-code", { code: code }, function(res) {
                if(res === "success") {
                    alert("인증되었습니다.");
                    verified = true;
                    
                    // ✅ 추가된 코드: 인증 완료 시 관련 UI 정리
                    $('#btnSendMail').hide();      // 인증번호 받기 버튼 숨기기
                    $('#authDiv').hide();          // 인증번호 입력칸과 확인 버튼 숨기기
                    
                    $('#authMsg').text("✅ 이메일 인증 완료").css("color", "green");
                    $('#btnSubmit').attr('disabled', false); // 가입 버튼 활성화
                } else {
                    alert("번호가 틀렸습니다.");
                }
            });
        }

        function submitSignup() {
            if(!verified) return alert("이메일 인증이 필요합니다.");
            
            // 전송 전 데이터를 변수에 담고 콘솔로 꼭 확인해보세요!
            const signupData = {
                "uId": $('#uId').val(), 
                "uPassword": $('input[name="uPassword"]').val()
            };
            
            console.log("서버로 보내는 데이터: ", signupData); 

            $.ajax({
                url: '/api/user/guest/signup/step1',
                type: 'POST',
                contentType: 'application/json', // JSON 형식임을 명시
                data: JSON.stringify(signupData),
                success: function(res) {
                    alert("가입 성공!");
                    location.href = res; // 컨트롤러가 준 "/signup/step2?email=..." 로 이동
                },
                error: function(xhr) {
                    alert("에러 발생: " + xhr.responseText);
                }
            });
        }
    </script>
      </div>
    </main>
    <jsp:include page="../common/Footer.jsp" />
</body>
</html>