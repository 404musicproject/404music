<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>404Music Admin | EDIT_NOTICE</title>
<link rel="stylesheet" href="/ckeditor5/style.css">
<link rel="stylesheet" href="https://cdn.ckeditor.com/ckeditor5/47.4.0/ckeditor5.css" crossorigin>
<style>
    /* 기존 스타일 유지 또는 추가 */
    .main-container { padding: 60px 40px; max-width: 1000px; margin: 0 auto; background-color: #050505; color: #00f2ff; }
    input[type="text"] { width: 100%; background: #111; border: 1px solid #00f2ff; color: #00f2ff; padding: 15px; margin-bottom: 25px; }
    .label-text { color: #ff0055; font-weight: bold; display: block; margin-bottom: 10px; }
    .btn-submit { background: transparent; border: 1px solid #ff0055; color: #ff0055; padding: 12px 40px; cursor: pointer; font-weight: bold; }
</style>
</head>
<body>
<div class="main-container">
    <h2>UPDATE_NOTICE_PACKET</h2>
    
    <!-- 경로를 insert가 아닌 updateNotice.do로 변경 -->
    <form action="${pageContext.request.contextPath}/support/updateNotice.do" method="post" id="noticeForm">
        
        <!-- [필수] 수정할 글의 번호를 전송해야 합니다 -->
        <input type="hidden" name="noticeNo" value="${notice.noticeNo}">
        
        <label class="label-text">NOTICE_TITLE</label>
        <input type="text" name="nTitle" value="${notice.NTitle}" required>
        
        <label class="label-text">NOTICE_CONTENT</label>
        <div class="editor-container">
            <div id="editor"></div>
        </div>
		
        <!-- 데이터 전송용 Hidden Input -->
        <input type="hidden" name="nContent" id="nContent">
    
        <div style="text-align: right; margin-top: 20px;">
            <button type="button" onclick="history.back();" style="color:#ccc; background:none; border:none; margin-right:20px; cursor:pointer;">[CANCEL]</button>
            <button type="submit" class="btn-submit">UPDATE_PUBLISH</button>
        </div>
    </form>
</div>

<script src="https://cdn.ckeditor.com/ckeditor5/47.4.0/ckeditor5.umd.js" crossorigin></script>
<script src="https://cdn.ckeditor.com/ckeditor5/47.4.0/translations/ko.umd.js" crossorigin></script>
<!-- main.js에서 window.editor를 설정한다고 가정 -->
<script src="/ckeditor5/main.js"></script>

<script>
    // 에디터 인스턴스가 생성될 때까지 기다렸다가 기존 데이터를 넣어줍니다.
    const checkEditor = setInterval(() => {
        if (window.editor) {
            // 서버에서 넘어온 기존 content를 에디터에 주입
            // (EL의 줄바꿈 에러 방지를 위해 백틱(`) 사용 권장)
            window.editor.setData(`${notice.NContent}`);
            clearInterval(checkEditor);
        }
    }, 100);

    document.getElementById('noticeForm').addEventListener('submit', function(e) {
        if (window.editor) {
            const data = window.editor.getData();
            if (data.trim() === "" || data === "<p>&nbsp;</p>") {
                alert("내용을 입력하세요.");
                e.preventDefault();
                return;
            }
            document.getElementById('nContent').value = data;
        }
    });
</script>		
</body>
</html>