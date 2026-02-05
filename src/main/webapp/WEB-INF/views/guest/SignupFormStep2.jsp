<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>

<head>
    <title>회원가입 2단계</title>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <link rel="stylesheet" href="/css/SignupFormStep2.css">
    <style>
        .gender-group { margin: 10px 0; }
        .btn-group { margin-top: 20px; }
        .skip-link { color: gray; text-decoration: none; font-size: 14px; margin-left: 15px; }
		/* 활성화된 라인 스타일 추가 */
.progress-line.active-line {
    background: #00f2ff; /* 시안 색상 */
    box-shadow: 0 0 8px #00f2ff;
    opacity: 1;
}   
    </style>
</head>
<body>
    <jsp:include page="../common/Header.jsp" />
    <main class="signup-main">
      <div class="signup-wrap">
<div id="signup-container">
    <h2>프로필 설정</h2>
    
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
    
    <form id="signupFormStep2">
        <input type="hidden" name="uId" value="${param.email}">
        
        <div class="input-section">
            <label>닉네임</label>
            <input type="text" id="uNick" name="uNick" value="${loginUser.UNick}" placeholder="NICKNAME">
            <div id="nickMsg"></div>
        </div>
        
        <div class="input-section">
            <label>성 별 </label>
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
            <input type="text" name="uRegion" placeholder="CITY (ex: SEOUL)">
        </div>
        
        <div class="input-section">
            <label>선호하는 장르</label>
            <input type="text" name="uPreferredGenre" placeholder="GENRE (ex: K-POP, ROCK)">
        </div>
        
        <div class="btn-group">
            <button type="button" onclick="submitStep2()">NEXT STEP</button>
            <button type="button" onclick="location.href='${pageContext.request.contextPath}/'">SKIP</button>
        </div>
    </form>
</div>
    <script>
    let nickChecked = true; 
    let timer;
    const originalNick = "${sessionScope.loginUser.UNick}"; // 세션에서 가져온 초기 닉네임

    $('#uNick').on('input', function() {
        const nick = $(this).val();

        // 2. 입력값이 처음 부여받은 임시 닉네임과 같다면 체크 통과 처리
        if (nick === originalNick || nick.trim() === "") {
            $('#nickMsg').text("기존 임시 닉네임을 사용합니다.").css("color", "blue");
            nickChecked = true;
            return;
        }

        nickChecked = false; // 새로운 값을 입력하기 시작하면 다시 체크 필요
        clearTimeout(timer);
        
        if (nick.length < 2) {
            $('#nickMsg').text("닉네임은 2자 이상 입력해주세요.").css("color", "gray");
            return;
        }

        timer = setTimeout(function() {
            $.get("/api/user/guest/check-nick", { uNick: nick }, function(isAvailable) {
                if (isAvailable) {
                    $('#nickMsg').text("✅ 사용 가능한 닉네임입니다.").css("color", "green");
                    nickChecked = true;
                } else {
                    $('#nickMsg').text("❌ 이미 사용 중인 닉네임입니다.").css("color", "red");
                    nickChecked = false;
                }
            });
        }, 300);
    });

    
    function submitStep2() {
    	if (!nickChecked) {
            alert("닉네임을 확인해주세요.");
            $('#uNick').focus();
            return;
        }
    	
        const formData = $('#signupFormStep2').serializeArray();
        const data = {};
        
        formData.forEach(item => {
            if(item.value.trim() !== "") {
                data[item.name] = item.value;
            }
        });

        // [중요] 만약 사용자가 닉네임을 입력하지 않았다면 
        // 전송 데이터에 닉네임을 포함시키지 않거나, 기존 값을 다시 세팅합니다.
        if(!data.uNick) {
            data.uNick = "${loginUser.UNick}"; // 기존 임시 닉네임 유지
        }

        $.ajax({
            url: '/api/user/guest/signup/step2', 
            type: 'PUT',
            contentType: 'application/json; charset=UTF-8',
            data: JSON.stringify(data),
         success: function(res) {
             // 2단계 데이터 저장 성공 후 3단계로 이동
             location.href = "/signup/step3?uId=" + $('input[name="uId"]').val();
         }
        });
    }
    </script>
      </div>
    </main>
    <jsp:include page="../common/Footer.jsp" />
</body>
</html>