<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>404Music // 문의</title>
<style>
/* 1. 기본 배경 및 폰트 설정 (이전 페이지들과 통일) */
:root {
    --neon-cyan: #00f2ff;
    --neon-pink: #ff0055;
    --dark-bg: #050505;
}

body { 
    background-color: #050505; 
    color: #00f2ff; 
}

.main-container {
    font-family: 'Courier New', monospace;
    min-height: auto;
    padding: 40px;
    max-width: 900px; /* FAQ와 동일하게 조정 */
    margin: 0 auto;
}

/* 2. 제목 스타일 (glitch-title 스타일 적용) */
.neon-title { 
    font-size: 30px; /* FAQ와 동일하게 30px */
    color: #fff;
    text-shadow: 2px 2px var(--neon-pink); 
    margin-bottom: 30px;
    border-left: 5px solid var(--neon-pink);
    padding-left: 15px;
    font-family: inherit;
}

/* 3. 테이블 스타일 (공지사항 테이블과 통일) */
.retro-table {
    width: 100%;
    border-collapse: collapse;
    border-top: 1px solid #333;
    table-layout: fixed;
}

.retro-table thead th { 
    background: #0a0a0a; 
    color: var(--neon-pink); 
    padding: 12px 15px; 
    border-bottom: 1px solid #222; 
    text-align: center;
    font-size: 13px; 
    font-weight: bold;
    font-family: inherit;
}

.retro-table tbody td {
    padding: 12px 15px;
    border-bottom: 1px solid #222;
    color: var(--neon-cyan);
    font-size: 13px; 
    text-align: center;
    font-family: inherit;
}

/* 제목 열 (FAQ 질문처럼 볼드 처리) */
.retro-table tbody td:nth-child(2) {
    text-align: left;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    font-weight: bold;
}

.inquiry-header-row:hover {
    background: rgba(0, 242, 255, 0.05);
    cursor: pointer;
}

/* 4. 답변/상세 영역 (FAQ 답변 박스 스타일 적용) */
.reply-row { display: none; }
.reply-content-box { 
    padding: 18px 20px 18px 45px; /* FAQ 답변 패딩 */
    background-color: #0a0a0a; /* FAQ 답변 배경색 */
    color: #ccc; /* FAQ 답변 글자색 */
    line-height: 1.5; 
    border-top: 1px dashed #333; /* FAQ 답변 상단 점선 */
    border-bottom: 1px solid #222;
    text-align: left;
    font-size: 12px; /* FAQ 답변 글자 크기 */
    font-family: inherit;
}

/* 배지 스타일 */
.badge {
    padding: 2px 8px;
    border: 1px solid;
    font-size: 10px;
    font-weight: bold;
}
.badge-my {
    background: #050505; 
    border: 1px solid var(--neon-cyan); 
    color: var(--neon-cyan); 
    padding: 1px 5px; 
    font-size: 10px; 
    margin-right: 8px;
}
.status-complete { border-color: var(--neon-cyan); color: var(--neon-cyan); }
.status-wait { border-color: var(--neon-pink); color: var(--neon-pink); }

/* 컨트롤 및 입력창 */
.content-label { color: var(--neon-cyan); font-weight: bold; font-size: 12px; }
.content-divider { border: 0; border-top: 1px dotted #333; margin: 15px 0; }

.btn-ticket {
    background: transparent;
    border: 1px solid var(--neon-cyan);
    color: var(--neon-cyan);
    padding: 4px 10px;
    cursor: pointer;
    font-size: 11px;
    transition: 0.3s;
    margin-left: 5px;
    font-family: inherit;
}
.btn-ticket:hover { border-color: var(--neon-pink); color: var(--neon-pink); }

.retro-input {
    width: 100%;
    background: #000;
    color: var(--neon-cyan);
    border: 1px solid #333;
    padding: 10px;
    font-family: inherit;
    font-size: 12px;
}

/* 하단 버튼 및 페이징 (FAQ 스타일과 통일) */
.btn-main-container { text-align: right; margin-top: 20px; }
.btn-neon-main { 
    background: transparent; 
    border: 1px solid var(--neon-cyan); 
    color: var(--neon-cyan);
    padding: 5px 10px;         
    font-size: 11px;          
    cursor: pointer; 
    font-family: inherit;
    transition: 0.3s; 
}
.btn-neon-main:hover { border-color: var(--neon-pink); color: var(--neon-pink); }

.pagination-box { display: flex; justify-content: center; margin: 20px 0; gap: 8px; padding-bottom: 40px; }
.page-btn {
    background: transparent;
    border: 1px solid #00f2ff;
    color: #00f2ff;
    padding: 5px 10px;
    cursor: pointer;
    font-size: 11px;
    font-family: inherit;
    transition: 0.3s;
}
.page-btn.active { background: #00f2ff; color: #000; box-shadow: 0 0 10px #00f2ff; }
.page-btn:hover:not(.active) { border-color: #ff0055; color: #ff0055; }
</style>
</head>
<body>
<div class="main-container">
    <h1 class="neon-title">1:1 문의</h1>
    
    <table class="retro-table">
        <thead>
            <tr>
                <th width="12%">ID</th>
                <th width="58%">타이틀</th>
                <th width="15%">상태</th>
                <th width="15%">날짜</th>
            </tr>
        </thead>
        <tbody id="inquiryTbody">
<c:forEach var="inq" items="${list}">
<c:set var="isMyPost" value="${inq.userNo == sessionScope.loginUser.UNo}" />
    <c:set var="isAuthorized" value="${sessionScope.loginUser.UAuth == 'ADMIN' || inq.userNo == sessionScope.loginUser.UNo}" />

   <tr class="inquiry-header-row" onclick="${(inq.IIsSecret == 'Y' && !isAuthorized) ? 'alert(\'ACCESS DENIED: 비밀글입니다.\')' : 'toggleReply('.concat(inq.INo).concat(')')}">
        <td>#${inq.INo}</td>
        <td>
            <c:choose>
                <c:when test="${inq.IIsSecret == 'Y' && !isAuthorized}">[ENCRYPTED_DATA]</c:when>
                <c:otherwise>
                  <c:if test="${isMyPost}">
                        <span class="badge-my">MY</span>
                    </c:if>
                    <c:if test="${inq.IIsSecret == 'Y'}">🔒 </c:if>${inq.ITitle}
                </c:otherwise>
            </c:choose>
        </td>
        <td>
            <span class="badge ${inq.IStatus == '답변완료' ? 'status-complete' : 'status-wait'}">
                ${inq.IStatus == '답변완료' ? 'RESOLVED' : 'WAITING'}
            </span>
        </td>
        <td><fmt:formatDate value="${inq.IDate}" pattern="yy.MM.dd"/></td>
    </tr>

    <c:if test="${inq.IIsSecret != 'Y' || isAuthorized}">
        <tr id="row_${inq.INo}" class="reply-row">
            <td colspan="4">
                <div class="reply-content-box">
                    <div id="q-view-${inq.INo}">
                        <span class="content-label">Q. 문의 내용</span><br>
                        <div style="margin-top:10px; line-height:1.6;">${inq.IContent}</div>
                        <c:if test="${inq.userNo == sessionScope.loginUser.UNo}">
                            <div class="control-panel" style="text-align:right; margin-top:10px;">
                                <c:if test="${inq.IStatus == '답변대기'}">
                                    <button type="button" class="btn-ticket" onclick="showEditMode('q', '${inq.INo}')">수정</button>
                                </c:if>  
                                <button type="button" class="btn-ticket" onclick="deleteInquiry('${inq.INo}')" style="border-color:var(--neon-pink); color:var(--neon-pink);">삭제</button>
                            </div>
                        </c:if>
                    </div>

                    <div id="q-edit-${inq.INo}" style="display:none;">
                        <span class="content-label">데이터 수정중...</span>
                        <form action="${pageContext.request.contextPath}/support/updateInquiry.do" method="post" style="margin-top:10px;">
                            <input type="hidden" name="iNo" value="${inq.INo}">
                            <input type="hidden" name="iTitle" value="${inq.ITitle}">
                            <textarea name="iContent" rows="5" class="retro-input">${inq.IContent}</textarea>
                            <div style="text-align: right; margin-top:10px;">
                                <button type="button" class="btn-ticket" onclick="hideEditMode('q', '${inq.INo}')" style="border-color:#666; color:#666;">취소</button>
                                <button type="submit" class="btn-ticket">저장</button>
                            </div>
                        </form>
                    </div>

                    <hr class="content-divider">
                    
                    <c:choose>
                        <c:when test="${not empty inq.IAnswer}">
                            <div id="a-view-${inq.INo}">
                                <span class="content-label" style="color:var(--neon-pink);">A. 관리자 답변</span><br>
                                <div style="margin-top:10px; line-height:1.6;">${inq.IAnswer}</div>
                                <c:if test="${sessionScope.loginUser.UAuth == 'ADMIN'}">
                                    <div class="control-panel" style="text-align:right; margin-top:10px;">
                                        <button type="button" class="btn-ticket" onclick="showEditMode('a', '${inq.INo}')">답변수정</button>
                                    </div>
                                </c:if>
                            </div>

                            <div id="a-edit-${inq.INo}" style="display:none;">
                                <span class="content-label">답변 수정중...</span>
                                <form action="${pageContext.request.contextPath}/admin/answer.do" method="post">
                                    <input type="hidden" name="iNo" value="${inq.INo}">
                                    <input type="hidden" name="userNo" value="${inq.userNo}">
                                    <input type="hidden" name="iTitle" value="${inq.ITitle}">
                                    <textarea name="iAnswer" rows="5" class="retro-input">${inq.IAnswer}</textarea>
                                    <div style="text-align: right; margin-top:10px;">
                                        <button type="button" class="btn-ticket" onclick="hideEditMode('a', '${inq.INo}')">취소</button>
                                        <button type="submit" class="btn-ticket">업데이트</button>
                                    </div>
                                </form>
                            </div>
                        </c:when>

                        <c:when test="${sessionScope.loginUser.UAuth == 'ADMIN'}">
                            <span class="content-label" style="color: var(--neon-pink);">CONSOLE: 입력 대기중</span>
                            <form action="${pageContext.request.contextPath}/admin/answer.do" method="post" class="admin-response-area">
                                <input type="hidden" name="iNo" value="${inq.INo}">
                                <input type="hidden" name="userNo" value="${inq.userNo}">
                                <input type="hidden" name="iTitle" value="${inq.ITitle}">
                                <textarea name="iAnswer" rows="4" class="retro-input" placeholder="답변을 입력하십시오..." required style="margin-top:10px;"></textarea>
                                <div style="text-align: right; margin-top: 15px;">
                                    <button type="submit" class="btn-neon-main">답변등록</button>
                                </div>
                            </form>
                        </c:when>

                        <c:otherwise>
                            <span style="color: #666; font-size:11px;">[SYSTEM] 분석 중... 답변 대기 중입니다.</span>
                        </c:otherwise>
                    </c:choose>
                </div>
           </td>
        </tr>
    </c:if>
</c:forEach>
        </tbody>
    </table>

    <div class="btn-main-container">
        <button type="button" class="btn-neon-main" onclick="location.href='${pageContext.request.contextPath}/support/inquiryWrite'">+ 새로운 문의등록</button>     
    </div>
    <div id="pagination" class="pagination-box"></div>
</div>

<script>
// 기존 스크립트 기능 유지
function toggleReply(id) {
    const el = document.getElementById('row_' + id);
    if (!el) return;
    const isCurrentlyVisible = (el.style.display === 'table-row');
    document.querySelectorAll('.reply-row').forEach(row => row.style.display = 'none');
    if (!isCurrentlyVisible) el.style.display = 'table-row';
}

function showEditMode(type, id) {
    const viewEl = document.getElementById(type + '-view-' + id);
    const editEl = document.getElementById(type + '-edit-' + id);
    if (viewEl && editEl) {
        viewEl.style.display = 'none';
        editEl.style.display = 'block';
    }
}

function hideEditMode(type, id) {
    const viewEl = document.getElementById(type + '-view-' + id);
    const editEl = document.getElementById(type + '-edit-' + id);
    if (viewEl && editEl) {
        viewEl.style.display = 'block';
        editEl.style.display = 'none';
    }
}

function deleteInquiry(INo) {
    if (confirm("시스템 경고: 해당 데이터를 영구 삭제하시겠습니까?")) {
        location.href = '${pageContext.request.contextPath}/support/inquiryDelete.do?INo=' + INo;
    }
}

const rowsPerPage = 10;
const rows = document.querySelectorAll('.inquiry-header-row');
const pageCount = Math.ceil(rows.length / rowsPerPage);

function showPage(page) {
    const start = (page - 1) * rowsPerPage;
    const end = start + rowsPerPage;

    rows.forEach((row, idx) => {
        row.style.display = (idx >= start && idx < end) ? 'table-row' : 'none';
        const inqNoMatch = row.getAttribute('onclick')?.match(/\d+/);
        if(inqNoMatch) {
            const reply = document.getElementById('row_' + inqNoMatch[0]);
            if(reply) reply.style.display = 'none';
        }
    });

    document.querySelectorAll('.page-btn').forEach((btn, idx) => {
        btn.classList.toggle('active', idx === page - 1);
    });
}

function initPagination() {
    const container = document.getElementById('pagination');
    if(!container) return;
    container.innerHTML = ''; 
    if(pageCount <= 1 && rows.length > 0) { showPage(1); return; }

    for (let i = 1; i <= pageCount; i++) {
        const btn = document.createElement('button');
        btn.innerText = i;
        btn.className = 'page-btn';
        btn.onclick = () => { showPage(i); window.scrollTo(0,0); };
        container.appendChild(btn);
    }
    showPage(1);
}

document.addEventListener('DOMContentLoaded', initPagination);
</script>
</body>
</html>