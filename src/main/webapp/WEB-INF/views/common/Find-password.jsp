<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<div class="find-pw-body" style="color: white; background: #000; padding: 20px;">
    <h3 style="color: #ff0055; text-align: center;">FIND PASSWORD</h3>
    <p style="font-size: 12px; text-align: center; color: #ccc;">가입하신 이메일로 재설정 링크를 보내드립니다.</p>
    
    <div style="margin-top: 20px;">
        <input type="email" id="resetEmail" placeholder="ID (EMAIL)" 
               style="width: 100%; background: #111; border: 1px solid #333; color: white; padding: 10px; margin-bottom: 10px;">
        
        <button type="button" onclick="sendResetMail()" 
                style="width: 100%; background: none; border: 1px solid #00f2ff; color: #00f2ff; padding: 10px; cursor: pointer;">
            SEND LINK
        </button>
    </div>
</div>

<script>
function sendResetMail() {
    // 공통 유효성 검사 호출
    if (!validateAll()) return; 

    const email = $('#resetEmail').val();
    
    // 로딩 상태 표시 (중복 클릭 방지)
    const btn = $('button[onclick="sendResetMail()"]');
    btn.prop('disabled', true).text('SENDING...');

    $.ajax({
        url: '/api/user/find-password',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({ email: email }),
        success: function(res) {
            alert(res);
            closeFindPwModal(); // 성공 시 모달 닫기
        },
        error: function(xhr) {
            alert(xhr.responseText || "오류가 발생했습니다.");
        },
        complete: function() {
            btn.prop('disabled', false).text('SEND LINK');
        }
    });
}
</script>