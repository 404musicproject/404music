<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<title>404Music Admin | 새공지</title>
<meta http-equiv="Content-Security-Policy" content="img-src 'self' * data:;">
<link rel="stylesheet" href="https://cdn.ckeditor.com/ckeditor5/41.0.0/classic/ckeditor.css">
<style>
/* =========================
   기본 레이아웃
========================= */
body {
    background-color: #050505;
    color: #00f2ff;
}

.main-container {
    padding: 20px 10px;
    max-width: 1000px;
    margin: 0 auto;
    background-color: #050505;
    font-family: 'Courier New', monospace;
    font-size: 13px;
}

/* =========================
   메인 타이틀
========================= */
.main-container > h2 {
    position: relative;
    font-size: 22px;
    font-weight: 800;
    letter-spacing: 3px;
    color: #00e6ff;
    margin: 40px 0 35px;
    padding-left: 22px;
    font-family: 'Noto Sans KR','Pretendard',sans-serif;
    text-shadow:
        0 0 4px rgba(0,230,255,0.6),
        0 0 10px rgba(0,230,255,0.4),
        0 0 18px rgba(0,230,255,0.25);
}

.main-container > h2::before {
    content: "|";
    position: absolute;
    left: 0;
    top: 50%;
    transform: translateY(-50%);
    font-size: 26px;
    font-weight: 900;
    color: #ff0055;
    text-shadow:
        0 0 4px rgba(255,0,85,0.7),
        0 0 10px rgba(255,0,85,0.5),
        0 0 18px rgba(255,0,85,0.3);
}

/* =========================
   서브 라벨
========================= */
.label-text {
    display: block;
    font-size: 15px;
    font-weight: 600;
    letter-spacing: 1.5px;
    color: #cccccc;
    margin: 25px 0 12px;
    font-family: 'Noto Sans KR','Pretendard',sans-serif;
}

/* =========================
   제목 입력 (공지 전용)
========================= */
.notice-write input[type="text"] {
    width: 100%;
    background: #111;
    border: 1px solid #00e6ff;
    color: #00e6ff;
    outline: none;
    margin-bottom: 35px;
    padding: 15px;
    box-sizing: border-box;
    transition: 0.3s;
    font-size: 13px;
}

.notice-write input[type="text"]:focus {
    border-color: #ff0055;
    box-shadow: 0 0 10px rgba(255,0,85,0.5);
}

/* =========================
   팝업 옵션
========================= */
.popup-options {
    display: flex;
    align-items: center;
    gap: 20px;
    flex-wrap: wrap; /* 중요 */
}

.checkbox-label {
    display: flex;
    align-items: center;
    gap: 10px;
    color: #00e6ff;
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 0;
    white-space: nowrap;
}

.date-group {
    display: none;
    align-items: center;
    gap: 12px;
}

.date-group label {
    font-size: 15px;
    font-weight: 700;
    color: #00e6ff;
    text-shadow:
        0 0 4px rgba(0,230,255,0.6),
        0 0 10px rgba(0,230,255,0.4);
}

.date-group input[type="date"] {
    background: #111;
    border: 1px solid #00e6ff;
    color: #00e6ff;
    padding: 8px 12px;
    font-size: 12px;
    outline: none;
    box-shadow: 0 0 6px rgba(0,230,255,0.4);
}

/* =========================
   CKEditor
========================= */
.ck-editor__main .ck-content {
    background-color: #111 !important;
    color: #00f2ff !important;
    min-height: 400px;
    font-size: 13px !important;
}

.ck.ck-toolbar {
    background-color: #222 !important;
    border-color: #444 !important;
}

/* =========================
   등록 버튼
========================= */
.btn-submit {
    background: transparent;
    border: 1px solid #ff0055;
    color: #ff0055;
    padding: 8px 26px;
    cursor: pointer;
    font-weight: bold;
    text-transform: uppercase;
    transition: 0.3s;
    font-size: 13px;
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

<jsp:include page="/WEB-INF/views/common/Header.jsp" />

<div class="main-container notice-write">
    <h2>새 공지등록</h2>

    <form action="${pageContext.request.contextPath}/support/insertNotice.do" method="post" id="noticeForm">

        <label class="label-text">공지사항 제목</label>
        <input type="text" name="nTitle" placeholder="Enter title here..." required>

        <div class="popup-options">
            <label class="checkbox-label">
                <input type="checkbox" name="isPopup" value="Y" id="isPopupCheckbox">
                팝업으로 공지 (메인 팝업으로 게시)
            </label>

            <div id="dateGroup" class="date-group">
                <label>팝업 공지 노출 종료일(해당 날짜 자정까지 노출됩니다.)</label>
                <input type="date" name="nEndDate" id="nEndDate">
            </div>
        </div>

        <label class="label-text">공지내용</label>

        <div class="editor-container editor-container_classic-editor" id="editor-container">
            <div class="editor-container__editor">
                <div id="editor"></div>
            </div>
        </div>

        <input type="hidden" name="nContent" id="nContent">

        <div style="text-align:right; margin-top:30px;">
            <button type="submit" class="btn-submit">게시물등록</button>
        </div>

    </form>
</div>

<script src="https://cdn.ckeditor.com/ckeditor5/41.0.0/super-build/ckeditor.js"></script>

<script src="https://cdn.ckeditor.com/ckeditor5/41.0.0/classic/translations/ko.js"></script>

<script src="/ckeditor5/main.js"></script>

<script>
document.getElementById('isPopupCheckbox').addEventListener('change', function () {
    const dateGroup = document.getElementById('dateGroup');
    const nEndDate = document.getElementById('nEndDate');

    if (this.checked) {
        dateGroup.style.display = 'flex';
        nEndDate.required = true;
    } else {
        dateGroup.style.display = 'none';
        nEndDate.required = false;
        nEndDate.value = '';
    }
});

document.getElementById('noticeForm').addEventListener('submit', function (e) {
    if (window.editor) {
        const data = window.editor.getData();
        if (data.trim() === "") {
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