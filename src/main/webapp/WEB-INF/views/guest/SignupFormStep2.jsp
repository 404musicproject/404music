<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>회원가입 2단계</title>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <link rel="stylesheet" href="/css/SignupFormStep2.css">
    <script src="${pageContext.request.contextPath}/js/validateForm.js"></script>
</head>
<body>
    <jsp:include page="../common/Header.jsp" />
    
    <main class="signup-main">
      <div class="signup-wrap">
        
        <div class="progress-container">
            <div class="progress-step active">
                <span class="step-num">01</span>
                <span class="step-text">인증</span>
            </div>
            <div class="progress-line active-line"></div> 
            <div class="progress-step active">
                <span class="step-num">02</span>
                <span class="step-text">정보</span>
            </div>
            <div class="progress-line"></div>
            <div class="progress-step">
                <span class="step-num">03</span>
                <span class="step-text">프로필</span>
            </div>
        </div>

        <h2>회원 정보</h2>
            
        <form id="signupFormStep2">
            <input type="hidden" name="uId" value="${param.email}">
            
            <div class="input-section">
                <label>닉네임</label>
                <input type="text" id="uNick" name="uNick" value="${loginUser.UNick}" placeholder="NICKNAME">
                <div id="nickMsg"></div>
            </div>
            
            <div class="input-section">
                <label>성 별</label>
                <div class="gender-group">
                    <label><input type="radio" name="uGender" value="M"> MALE</label>
                    <label><input type="radio" name="uGender" value="F"> FEMALE</label>
                    <label><input type="radio" name="uGender" value="O" checked> NONE</label>
                </div>
            </div>

            <div class="input-section">
                <label>생 일</label>
                <input type="date" name="uBirth">
            </div>

            <div class="input-section">
                <label>지역</label>
                <input type="text" id="uRegion" name="uRegion" placeholder="CITY (ex: SEOUL)">
            </div>
            
            <div class="input-section">
                <label>선호하는 장르</label>
                <input type="text" id="uPreferredGenre" name="uPreferredGenre" placeholder="GENRE (ex: K-POP, ROCK)">
            </div>
            
            <div class="btn-group">
                <button type="button" onclick="submitStep2()">NEXT STEP</button>
                <button type="button" onclick="location.href='${pageContext.request.contextPath}/'">SKIP</button>
            </div>
        </form>

        <script>
            let nickChecked = true;
            let timer;
            const originalNick = "${sessionScope.loginUser.UNick}"; 

            $('#uNick').on('input', function() {
                const nick = $(this).val();
                if (nick === originalNick || nick.trim() === "") {
                    $('#nickMsg').text("기존 임시 닉네임을 사용합니다.").css("color", "#a0f8ff");
                    nickChecked = true;
                    return;
                }
                nickChecked = false;
                clearTimeout(timer);
                if (nick.length < 2) {
                    $('#nickMsg').text("닉네임은 2자 이상 입력해주세요.").css("color", "gray");
                    return;
                }
                timer = setTimeout(function() {
                    $.get("/api/user/guest/check-nick", { uNick: nick }, function(isAvailable) {
                    	// 기존 스크립트 내부 수정 예시
                    	if (isAvailable) {
                    	    $('#nickMsg').html("<span style='color: #00f2ff;'>✅ 사용 가능한 닉네임입니다.</span>");
                    	    nickChecked = true;
                    	} else {
                    	    $('#nickMsg').html("<span style='color: #ff0055;'>❌ 이미 사용 중인 닉네임입니다.</span>");
                    	    nickChecked = false;
                    	}
                    });
                }, 300);
            });

            function submitStep2() {
            	// 1. 공통 유효성 검사 실행 (validateForm.js)
                if (!validateAll()) return;
            	
                if (!nickChecked) {
                    alert("닉네임을 확인해주세요.");
                    $('#uNick').focus();
                    return;
                }

                // 1. JSON.stringify 대신 폼 데이터를 그대로 직렬화합니다.
                const formData = $('#signupFormStep2').serialize(); 

                $.ajax({
                    url: '/api/user/guest/signup/step2', 
                    type: 'PUT',
                    // 2. contentType을 제거 (기본값인 application/x-www-form-urlencoded 사용)
                    // contentType: 'application/json; charset=UTF-8', 
                    data: formData, // JSON.stringify(data) 대신 formData 사용
                    success: function(res) {
                        location.href = "/signup/step3?uId=" + $('input[name="uId"]').val();
                    },
                    error: function(xhr) {
                        console.log(xhr.responseText);
                        alert("에러 발생: " + xhr.status);
                    }
                });
            }
        </script>
      </div>
    </main>
    <jsp:include page="../common/Footer.jsp" />
</body>
</html>