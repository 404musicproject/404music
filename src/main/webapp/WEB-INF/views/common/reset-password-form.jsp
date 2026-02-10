<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>RESET PASSWORD | 404Music</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body style="background-color: #000; color: white; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0;">

    <div style="width: 350px; border: 1px solid #333; padding: 40px; text-align: center;">
        <h2 style="color: #ff0055; letter-spacing: 2px;">RESET PASSWORD</h2>
        <input type="hidden" id="token" value="${token}">
        
        <input type="password" id="newPw" placeholder="NEW PASSWORD" 
               style="width: 100%; background: #111; border: 1px solid #333; color: white; padding: 12px; margin-bottom: 10px; box-sizing: border-box;">
        
        <input type="password" id="newPwConfirm" placeholder="CONFIRM PASSWORD" 
               style="width: 100%; background: #111; border: 1px solid #333; color: white; padding: 12px; margin-bottom: 20px; box-sizing: border-box;">
        
        <button type="button" onclick="submitNewPw()"
                style="width: 100%; background: #00f2ff; border: none; color: black; padding: 12px; font-weight: bold; cursor: pointer;">
            UPDATE PASSWORD
        </button>
    </div>

<script>
function submitNewPw() {
    const pw = $('#newPw').val();
    const pwConfirm = $('#newPwConfirm').val();

    if(pw !== pwConfirm) { alert("비밀번호가 일치하지 않습니다."); return; }

    $.ajax({
        url: '/api/user/reset-password',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({ 
            token: $('#token').val(), 
            password: pw 
        }),
        success: function(res) {
            alert("비밀번호가 변경되었습니다. 다시 로그인해주세요.");
            location.href = "/home";
        },
        error: function(xhr) {
            alert("유효하지 않은 토큰이거나 오류가 발생했습니다.");
        }
    });
}
</script>
</body>
</html>