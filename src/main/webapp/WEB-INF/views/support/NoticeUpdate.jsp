<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>404Music Admin | 공지수정</title>
<link rel="stylesheet" href="/ckeditor5/style.css">
<link rel="stylesheet" href="https://cdn.ckeditor.com/ckeditor5/47.4.0/ckeditor5.css" crossorigin>
<style>
    /* 기존 스타일 유지하면서 수치만 수정 */
    body { background-color: #050505; color: #00f2ff;  margin: 0; }
    
    .main-container { padding: 60px 40px; max-width: 1000px; margin: 0 auto; background-color: #050505; color: #00f2ff; font-family: 'Courier New', monospace; font-size: 13px;}
    
    .label-text { color: #ff0055; font-weight: bold; display: block; margin-bottom: 10px; font-size: 13px; }
    
    input[type="text"] { 
        width: 100%; background: #111; border: 1px solid #00f2ff; color: #00f2ff; 
        padding: 15px; margin-bottom: 25px; box-sizing: border-box; font-size: 13px; 
    }

    /* ⭐ 에디터 내부도 전체 검은 배경으로 수정 */
    .ck-editor__main .ck-content { 
        background-color: #111 !important; 
        color: #00f2ff !important; 
        min-height: 500px; 
        font-size: 13px !important; 
    }
    
    .ck.ck-toolbar { background-color: #222 !important; border-color: #444 !important; }

    /* ⭐ 버튼 그룹을 오른쪽 끝으로 고정하는 설정만 추가 */
    .btn-group { display: flex; justify-content: flex-end; gap: 15px; }

    .btn-submit { 
        background: transparent; border: 1px solid #ff0055; color: #ff0055; 
        padding: 12px 40px; cursor: pointer; font-weight: bold; font-size: 13px; 
    }
    
    .btn-blue { border: 1px solid #00f2ff; color: #00f2ff; padding: 12px 40px; cursor: pointer; font-weight: bold; font-size: 13px; text-decoration: none; }
</style>
</head>
<body>
<div class="main-container">
    <h2>공지수정</h2>
    
    <!-- 경로를 insert가 아닌 updateNotice.do로 변경 -->
    <form action="${pageContext.request.contextPath}/support/updateNotice.do" method="post" id="noticeForm">
        
        <!-- [필수] 수정할 글의 번호를 전송해야 합니다 -->
        <input type="hidden" name="noticeNo" value="${notice.noticeNo}">
        
        <label class="label-text">공지제목</label>
        <input type="text" name="nTitle" value="${notice.NTitle}" required>
        
        <label class="label-text">공지내용</label>
        <div class="editor-container">
            <div id="editor"></div>
        </div>
		
        <!-- 데이터 전송용 Hidden Input -->
        <input type="hidden" name="nContent" id="nContent">
    
        <div style="text-align: right; margin-top: 20px;">
            <button type="button" onclick="history.back();" style="color:#ccc; background:none; border:none; margin-right:20px; cursor:pointer;">취소</button>
            <button type="submit" class="btn-submit">수정후게시</button>
        </div>
    </form>
</div>

<script src="https://cdn.ckeditor.com/ckeditor5/41.0.0/super-build/ckeditor.js"></script>

<script src="https://cdn.ckeditor.com/ckeditor5/41.0.0/classic/translations/ko.js"></script>

<script src="/ckeditor5/main.js"></script>

<script>
    // 에디터 초기 데이터 주입 및 전송 스크립트
    const checkEditor = setInterval(() => {
        if (window.editor) {
            // 서버에서 넘어온 기존 내용을 에디터에 주입
            // 주의: Java 객체의 필드명이 NContent인지 nContent인지 확인하세요. 
            // EL 데이터에 HTML 태그가 포함되어 있으므로 따옴표 보다는 백틱(`)이 안전합니다.
            const existingContent = `${notice.NContent}`; 
            window.editor.setData(existingContent);
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
            // hidden input에 에디터 데이터 담기
            document.getElementById('nContent').value = data;
        }
    });
</script>	
</body>
</html>