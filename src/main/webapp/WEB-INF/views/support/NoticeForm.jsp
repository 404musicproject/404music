<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>404Music Admin | NEW_NOTICE</title>
    <meta http-equiv="Content-Security-Policy" content="img-src 'self' * data:;">
    <style>
        body { background-color: #050505; color: #00f2ff; font-family: 'Courier New', monospace; margin: 0; }
        .main-container { padding: 60px 40px; max-width: 1000px; margin: 0 auto; }
        
        /* 레이블 스타일 */
        .label-text { 
            color: #ff0055; 
            font-weight: bold; 
            display: block; 
            margin-bottom: 10px; 
            letter-spacing: 1px;
        }

        /* 입력창 공통 스타일 */
        input[type="text"]{
            width: 100%; 
            background: #111; 
            border: 1px solid #00f2ff;
            color: #00f2ff; 
            outline: none; 
            margin-bottom: 25px;
            padding: 15px;
            box-sizing: border-box; /* 패딩이 너비에 포함되도록 설정 */
            transition: all 0.3s ease;
        }

        /* 포커스 시 네온 효과 */
        input[type="text"]:focus {
            border-color: #ff0055;
            box-shadow: 0 0 10px rgba(255, 0, 85, 0.5);
        }

        /* 제출 버튼 */
        .btn-submit {
            background: transparent; 
            border: 1px solid #ff0055; 
            color: #ff0055;
            padding: 12px 40px; 
            cursor: pointer; 
            font-weight: bold; 
            margin-top: 10px;
            text-transform: uppercase;
            transition: 0.3s;
        }
        .btn-submit:hover { 
            background: #ff0055; 
            color: #fff; 
            box-shadow: 0 0 15px #ff0055;
        }
    </style>
<link rel="stylesheet" href="/ckeditor5/style.css">
<link rel="stylesheet" href="https://cdn.ckeditor.com/ckeditor5/47.4.0/ckeditor5.css" crossorigin>
</head>
<body>
<div class="main-container">
    <h2>NEW_NOTICE_ENTRY</h2>
    
    <form action="${pageContext.request.contextPath}/support/insertNotice.do" method="post" id="noticeForm">
        <label class="label-text">NOTICE_TITLE</label>
        <input type="text" name="nTitle" placeholder="Enter title here..." required>
        
        <label class="label-text">NOTICE_CONTENT</label>
        
	       <div class="main-container">
				<div class="editor-container editor-container_classic-editor" id="editor-container">
					<div class="editor-container__editor"><div id="editor"></div></div>
				</div>
			</div>
		
	    <!-- 데이터 전송용 Hidden Input -->
	    <input type="hidden" name="nContent" id="nContent">
    
        <div style="text-align: right;">
            <button type="submit" class="btn-submit">PUBLISH_NOTICE</button>
        </div>
    </form>
</div>
<script src="https://cdn.ckeditor.com/ckeditor5/47.4.0/ckeditor5.umd.js" crossorigin></script>
<script src="https://cdn.ckeditor.com/ckeditor5/47.4.0/translations/ko.umd.js" crossorigin></script>
<script src="/ckeditor5/main.js"></script>

<script>
    document.getElementById('noticeForm').addEventListener('submit', function(e) {
        if (window.editor) {
            const data = window.editor.getData();
            if (data.trim() === "") {
                alert("내용을 입력하세요.");
                e.preventDefault();
                return;
            }
            // hidden input에 에디터 내용 주입
            document.getElementById('nContent').value = data;
        }
    });
</script>		
		
</body>
</html>