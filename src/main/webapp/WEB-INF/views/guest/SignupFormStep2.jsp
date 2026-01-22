<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>

<head>
    <title>회원가입 2단계</title>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <style>
        .gender-group { margin: 10px 0; }
        .btn-group { margin-top: 20px; }
        .skip-link { color: gray; text-decoration: none; font-size: 14px; margin-left: 15px; }
    </style>
</head>
<body>
    <h2>회원가입 2단계 (선택 정보)</h2>
    <p>나머지 정보를 입력해 주세요. 입력하지 않고 건너뛰셔도 됩니다.</p>
    
    <form id="signupFormStep2">
        <input type="hidden" name="uId" value="${param.email}">
        
        <label>닉네임:</label>
		<input type="text" id="uNick" name="uNick" placeholder="닉네임 입력" required>
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
            <a href="/" class="skip-link">나중에 입력하기 (건너뛰기)</a>
        </div>
    </form>

    <script>
    let nickChecked = false; // 최종 가입 가능 여부 변수
    let timer; // 디바운싱용 타이머

    $('#uNick').on('input', function() {
        const nick = $(this).val();
        nickChecked = false; // 글자가 바뀔 때마다 다시 체크해야 함
        
        // 이전 타이머 취소 (연타 시 마지막 한 번만 실행되게)
        clearTimeout(timer);
        
        if (nick.length < 2) {
            $('#nickMsg').text("닉네임은 2자 이상 입력해주세요.").css("color", "gray");
            return;
        }

        // 0.3초 동안 입력이 없으면 서버에 확인 요청
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
        }, 300); // 300ms 대기
    });
    
    
    function submitStep2() {
    	
    	if(!nickChecked) {
            alert("닉네임 중복 확인을 해주세요.");
            return;
        }
        const formData = $('#signupFormStep2').serializeArray();
        const data = {};
        
        // 필드가 비어있지 않은 것만 데이터에 담기
        formData.forEach(item => {
            if(item.value.trim() !== "") {
                data[item.name] = item.value;
            }
        });

        console.log("전송할 2단계 데이터:", JSON.stringify(data));

        $.ajax({
            url: '/api/user/guest/signup/step2', 
            type: 'PUT',
            contentType: 'application/json; charset=UTF-8',
            data: JSON.stringify(data),
            success: function(res) {
                alert("정보가 저장되었습니다! 홈으로 이동합니다.");
                location.href = "/"; // 홈으로 이동
            },
            error: function(err) {
                // 400 에러 등이 날 경우 처리
                alert("저장 실패: " + (err.responseText || "서버 오류"));
            }
        });
    }
    </script>
</body>
</html>