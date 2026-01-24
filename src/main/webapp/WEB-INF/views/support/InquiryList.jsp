<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>404Music // Inquiry</title>

<script>
// 1. 아코디언 토글 함수
function toggleReply(id) {
    const el = document.getElementById('row_' + id);
    if (!el) return;

    // 현재 클릭한 행의 표시 상태를 미리 저장
    const isCurrentlyVisible = (el.style.display === 'table-row');
    
    // 1. 모든 행을 일단 숨김
    document.querySelectorAll('.reply-row').forEach(row => {
        row.style.display = 'none';
    });
    
    // 2. 만약 이전에 닫혀있었다면 해당 행만 열기 (열려있었다면 위에서 닫힌 상태로 유지)
    if (!isCurrentlyVisible) {
        el.style.display = 'table-row';
    }

    // 3. 수정 모드 초기화 (필요 시)
    // ID가 'q-view-' 형식이므로 이를 반영하여 초기화
    const qView = document.getElementById('q-view-' + id);
    const qEdit = document.getElementById('q-edit-' + id);
    if (qView && qEdit) {
        qView.style.display = 'block';
        qEdit.style.display = 'none';
    }
}

function showEditMode(type, id) {
    const viewId = type + '-view-' + id;
    const editId = type + '-edit-' + id;
    
    const viewEl = document.getElementById(viewId);
    const editEl = document.getElementById(editId);
    
    if (viewEl && editEl) {
        viewEl.style.display = 'none';
        editEl.style.display = 'block';
        console.log("Switching to edit mode:", editId); // 디버깅용
    } else {
        console.error("Element not found:", viewId, editId);
    }
}

function hideEditMode(type, id) {
    const viewId = type + '-view-' + id;
    const editId = type + '-edit-' + id;
    
    const viewEl = document.getElementById(viewId);
    const editEl = document.getElementById(editId);
    
    if (viewEl && editEl) {
        viewEl.style.display = 'block';
        editEl.style.display = 'none';
    }
}

// 4. 삭제 함수
function deleteInquiry(INo) {
    if (confirm("시스템 경고: 해당 데이터를 영구 삭제하시겠습니까?")) {
        location.href = '${pageContext.request.contextPath}/support/inquiryDelete.do?INo=' + INo;
    }
}
</script>
<style>
    /* Neon Retro Theme Definition */
    :root {
        --neon-cyan: #00f2ff;
        --neon-pink: #ff0055;
        --neon-purple: #bc13fe;
        --dark-bg: #050505;
        --grid-line: rgba(188, 19, 254, 0.2);
    }

    body { 
        background-color: var(--dark-bg); 
        color: var(--neon-cyan); 
        font-family: 'Courier New', monospace;
        /* 배경에 미세한 그리드 효과 */
        background-image: linear-gradient(var(--grid-line) 1px, transparent 1px),
                          linear-gradient(90deg, var(--grid-line) 1px, transparent 1px);
        background-size: 30px 30px;
    }

    .main-container { min-height: 700px; padding: 60px 40px; max-width: 1000px; margin: 0 auto; }
    
    /* 네온 텍스트 효과 */
    .neon-title { 
        font-size: 28px;
        color: #fff;
        text-transform: uppercase;
        text-shadow: 0 0 5px #fff, 0 0 10px var(--neon-pink), 0 0 20px var(--neon-pink);
        margin-bottom: 40px;
        border-left: 4px solid var(--neon-pink);
        padding-left: 15px;
    }

    /* 레트로 테이블 스타일 */
    .retro-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; background: rgba(0, 0, 0, 0.6); }
    .retro-table thead th { 
        background: rgba(20, 20, 20, 0.9); 
        color: var(--neon-pink); 
        padding: 15px; 
        border-bottom: 2px solid var(--neon-cyan); 
        text-align: left;
        box-shadow: 0 4px 10px rgba(0, 242, 255, 0.2);
    }
    .retro-table tbody td { padding: 15px; border-bottom: 1px solid var(--grid-line); text-align: left; }
    .retro-table tbody tr:hover { background: rgba(0, 242, 255, 0.05); cursor: pointer; }

    /* 네온 뱃지 */
    .badge { padding: 4px 12px; border: 1px solid; font-size: 0.8em; text-transform: uppercase; font-weight: bold; }
    .status-complete { border-color: var(--neon-cyan); color: var(--neon-cyan); box-shadow: 0 0 8px var(--neon-cyan); }
    .status-wait { border-color: var(--neon-pink); color: var(--neon-pink); box-shadow: 0 0 8px var(--neon-pink); }

    /* 아코디언 답변 영역 */
    .reply-row { display: none; background-color: rgba(10, 10, 10, 0.9); }
    .reply-content-box { 
        padding: 25px; 
        border: 1px double var(--neon-purple); 
        margin: 10px;
        box-shadow: inset 0 0 15px rgba(188, 19, 254, 0.2);
    }
    .content-label { color: var(--neon-purple); font-weight: bold; margin-right: 10px; }
    .content-divider { border: 0; border-top: 1px dashed var(--neon-purple); margin: 20px 0; }

    /* 티켓 관리 버튼 (수정/삭제) */
    .control-panel { text-align: right; margin-bottom: 15px; }
    .btn-ticket { 
        background: transparent; 
        padding: 5px 12px; 
        cursor: pointer; 
        font-family: inherit; 
        font-size: 0.75em; 
        transition: 0.3s;
        margin-left: 8px;
        text-transform: uppercase;
    }
    .btn-edit { border: 1px solid var(--neon-cyan); color: var(--neon-cyan); }
    .btn-edit:hover { background: var(--neon-cyan); color: #000; box-shadow: 0 0 15px var(--neon-cyan); }
    .btn-delete { border: 1px solid var(--neon-pink); color: var(--neon-pink); }
    .btn-delete:hover { background: var(--neon-pink); color: #fff; box-shadow: 0 0 15px var(--neon-pink); }

    /* 답변 폼 스타일 */
    .admin-response-area { margin-top: 15px; }
    .retro-input { 
        width: 100%; 
        background: #000; 
        color: var(--neon-cyan); 
        border: 1px solid var(--neon-purple); 
        padding: 12px; 
        outline: none; 
        font-family: inherit; 
        box-sizing: border-box;
    }
    .retro-input:focus { border-color: var(--neon-cyan); box-shadow: 0 0 10px var(--neon-cyan); }

    /* 하단 메인 버튼 */
    .btn-main-container { text-align: right; margin-top: 30px; }
    .btn-neon-main { 
        background: transparent; 
        color: var(--neon-cyan); 
        border: 2px solid var(--neon-cyan); 
        padding: 12px 30px; 
        font-weight: bold; 
        cursor: pointer; 
        text-transform: uppercase;
        letter-spacing: 2px;
        transition: 0.4s;
    }
    .btn-neon-main:hover { 
        background: var(--neon-cyan); 
        color: #000; 
        box-shadow: 0 0 25px var(--neon-cyan); 
    }
    
    /* 본인 작성 글 강조 배지 */
.badge-my {
    background-color: var(--neon-pink);
    color: #fff;
    font-size: 0.7em;
    padding: 2px 6px;
    margin-right: 8px;
    border-radius: 2px;
    font-weight: bold;
    box-shadow: 0 0 10px var(--neon-pink);
    vertical-align: middle;
}

/* 본인 글 행(Row) 배경색 강조 (선택 사항) */
.my-post-row {
    background: rgba(188, 19, 254, 0.08) !important; /* 미세한 보랏빛 배경 */
}

.my-post-row:hover {
    background: rgba(188, 19, 254, 0.15) !important;
}
</style>
</head>
<body>
<div class="main-container">
    <h1 class="neon-title">1:1_INQUIRY_LOG</h1>
    
    <table class="retro-table">
        <thead>
            <tr>
                <th width="10%">ID</th>
                <th width="60%">SUBJECT_PACKET</th>
                <th width="15%">STATUS</th>
                <th width="15%">DATE</th>
            </tr>
        </thead>
        <tbody>
<c:forEach var="inq" items="${list}">
<c:set var="isMyPost" value="${inq.userNo == sessionScope.loginUser.UNo}" />
    <c:set var="isAuthorized" value="${sessionScope.loginUser.UAuth == 'ADMIN' || inq.userNo == sessionScope.loginUser.UNo}" />

   <tr onclick="${(inq.IIsSecret == 'Y' && !isAuthorized) ? 'alert(\'ACCESS DENIED: 비밀글입니다.\')' : 'toggleReply('.concat(inq.INo).concat(')')}">
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
                ${inq.IStatus == '답변완료' ? 'RESOLVED' : 'PENDING'}
            </span>
        </td>
        <td><fmt:formatDate value="${inq.IDate}" pattern="yy.MM.dd"/></td>
    </tr>

    <c:if test="${inq.IIsSecret != 'Y' || isAuthorized}">
        <tr id="row_${inq.INo}" class="reply-row">
            <td colspan="4">
<div class="reply-content-box">
    <!-- 1. 유저 질문 영역 (유저 본인만 수정 가능) -->
    <div id="q-view-${inq.INo}">
        <span class="content-label">QUESTION_DATA:</span><br>
        <div style="margin-top:10px;">${inq.IContent}</div>
        
        <%-- 유저 본인이면서 답변 대기 중일 때만 수정/삭제 노출 --%>
        <c:if test="${inq.userNo == sessionScope.loginUser.UNo}">
            <div class="control-panel">
            <c:if test="${inq.IStatus == '답변대기'}">
                <button type="button" class="btn-ticket btn-edit" onclick="showEditMode('q', '${inq.INo}')">EDIT_QUESTION</button>
              </c:if>  
                <button type="button" class="btn-ticket btn-delete" onclick="deleteInquiry('${inq.INo}')">DELETE_TICKET</button>
            </div>
       </c:if>
    </div>

    <!-- 유저 질문 수정 폼 (기본 숨김) -->
    <div id="q-edit-${inq.INo}" style="display:none;">
        <span class="content-label" style="color:var(--neon-cyan);">EDITING_QUESTION...</span>
        <form action="${pageContext.request.contextPath}/support/updateInquiry.do" method="post" style="margin-top:10px;">
            <input type="hidden" name="iNo" value="${inq.INo}">
            <input type="hidden" name="iTitle" value="${inq.ITitle}">
            <textarea name="iContent" rows="4" class="retro-input">${inq.IContent}</textarea>
            <div style="text-align: right; margin-top:10px;">
                <button type="button" class="btn-ticket" onclick="hideEditMode('q', '${inq.INo}')" style="border-color:#666; color:#666;">CANCEL</button>
                <button type="submit" class="btn-ticket btn-edit">UPDATE_QUESTION</button>
            </div>
        </form>
    </div>

    <hr class="content-divider">
    
    <!-- 2. 관리자 답변 영역 -->
    <c:choose>
        <%-- 답변이 이미 있는 경우 --%>
<c:when test="${not empty inq.IAnswer}">
    <div id="a-view-${inq.INo}"> <!-- ID 확인 -->
        <span class="content-label">ADMIN_RESPONSE:</span><br>
        <div style="margin-top:10px;">${inq.IAnswer}</div>
        
        <c:if test="${sessionScope.loginUser.UAuth == 'ADMIN'}">
            <div class="control-panel">
                <%-- 파라미터를 'a'와 '${inq.INo}'로 정확히 전달 --%>
                <button type="button" class="btn-ticket btn-edit" onclick="showEditMode('a', '${inq.INo}')">EDIT_RESPONSE</button>
            </div>
        </c:if>
    </div>

    <!-- 관리자 답변 수정 폼 -->
    <div id="a-edit-${inq.INo}" style="display:none;"> <!-- ID 확인 -->
        <span class="content-label" style="color:var(--neon-pink);">EDITING_RESPONSE...</span>
        <form action="${pageContext.request.contextPath}/admin/answer.do" method="post">
            <input type="hidden" name="iNo" value="${inq.INo}">
            
                <input type="hidden" name="userNo" value="${inq.userNo}">
    
    <input type="hidden" name="iTitle" value="${inq.ITitle}">
    
            
            <textarea name="iAnswer" rows="4" class="retro-input">${inq.IAnswer}</textarea>
            <div style="text-align: right; margin-top:10px;">
                <button type="button" class="btn-ticket" onclick="hideEditMode('a', '${inq.INo}')">CANCEL</button>
                <button type="submit" class="btn-ticket btn-edit">UPDATE_RESPONSE</button>
            </div>
        </form>
    </div>
</c:when>

        <%-- 답변이 없고 관리자인 경우 (최초 답변 작성) --%>
        <c:when test="${sessionScope.loginUser.UAuth == 'ADMIN'}">
            <span class="content-label" style="color: var(--neon-pink);">SYSTEM_CONSOLE_INPUT:</span>
            <form action="${pageContext.request.contextPath}/admin/answer.do" method="post" class="admin-response-area">
                <input type="hidden" name="iNo" value="${inq.INo}">
                
                 <input type="hidden" name="userNo" value="${inq.userNo}">
                         <%-- 알림 메시지에 쓸 제목 --%>
        <input type="hidden" name="iTitle" value="${inq.ITitle}">
                
                <textarea name="iAnswer" rows="4" class="retro-input" placeholder="답변을 입력하십시오..." required></textarea>
                <div style="text-align: right; margin-top: 15px;">
                    <button type="submit" class="btn-neon-main" style="padding: 8px 20px; font-size: 0.8em;">UPLOAD_RESPONSE</button>
                </div>
            </form>
        </c:when>

        <c:otherwise>
            <span class="content-label">STATUS:</span>
            <span style="color: #666;">데이터 분석 중... 시스템 답변 대기 중입니다.</span>
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
        <button type="button" class="btn-neon-main" onclick="location.href='${pageContext.request.contextPath}/support/inquiryWrite'">
            + NEW_INQUIRY_TICKET
        </button>
    </div>
</div>

</body>
</html>