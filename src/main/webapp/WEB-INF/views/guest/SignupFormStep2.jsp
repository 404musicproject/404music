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
    </style>
</head>
<body>
    <h2>회원가입 2단계 (선택 정보)</h2>
    
    <form id="signupFormStep2">
        <input type="hidden" name="uId" value="${param.email}">
        
			<label>닉네임:</label>
			<input type="text" id="uNick" name="uNick" 
			       value="${loginUser.UNick}" 
			       placeholder="닉네임 입력">
			<div id="nickMsg" style="font-size: 12px; margin-top: 5px;"></div>
        
        <div class="gender-group">
            <label>성별: </label>
            <input type="radio" name="uGender" value="M"> 남성
            <input type="radio" name="uGender" value="F"> 여성
            <input type="radio" name="uGender" value="O" checked> 선택안함 
        </div>

        <label>생년월일: </label>
        <input type="date" name="uBirth"><br>
        
        <input type="text" name="uRegion" placeholder="지역 (예: 서울, 부산)"><br>
        <input type="text" name="uPreferredGenre" placeholder="선호 장르"><br>
        
        <div class="btn-group">
            <button type="button" onclick="submitStep2()">가입 완료하기</button>
            <button type="button" onclick="location.href='${pageContext.request.contextPath}/user/mypage'">나중에 설정하기</button>
        </div>
    </form>

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
                alert("가입이 완료되었습니다!");
                location.href = "/"; 
            }
        });
    }
    </script>
</body>
</html>