<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music // NOTICE</title>
    <meta http-equiv="Content-Security-Policy" content="img-src 'self' * data:;">
    <style>
        /* 기본 레이아웃 */
        body { background-color: #050505; color: #00f2ff; font-family: 'Courier New', monospace; }
        .main-container { min-height: 700px; padding: 60px 40px; max-width: 1000px; margin: 0 auto; }
        .glitch-title { text-shadow: 2px 2px #ff0055; border-left: 5px solid #ff0055; padding-left: 15px; margin-bottom: 40px; font-size: 24px; }
        
        /* 테이블 스타일 */
        .retro-table { width: 100%; border-collapse: collapse; border: 1px solid #333; background: rgba(20, 20, 20, 0.8); }
        .retro-table th { background: #111; color: #ff0055; padding: 15px; border-bottom: 2px solid #00f2ff; text-transform: uppercase; }
        .retro-table td { padding: 15px; border-bottom: 1px solid #222; color: #00f2ff; text-align: center; }
        .retro-table .subject { text-align: left; }
        .retro-table tr:hover { background: rgba(0, 242, 255, 0.05); cursor: pointer; }
        .notice-tag { color: #ff0055; margin-right: 10px; font-weight: bold; }

        /* 아코디언 내용 영역 */
        .content-row { display: none; background: #111; }
        .content-cell { padding: 30px; color: #ccc; line-height: 1.6; border-bottom: 1px solid #ff0055; text-align: left !important; }
        .notice-body { margin-bottom: 20px; min-height: 50px; }
        
        /* 관리자 도구 */
        .admin-controls { text-align: right; border-top: 1px dotted #333; padding-top: 15px; }
        .btn-admin { background: transparent; padding: 8px 18px; cursor: pointer; font-family: 'Courier New'; font-weight: bold; transition: 0.3s; margin-left: 10px; }
        .btn-edit { border: 1px solid #00f2ff; color: #00f2ff; }
        .btn-edit:hover { background: #00f2ff; color: #000; }
        .btn-delete { border: 1px solid #ff0055; color: #ff0055; }
        .btn-delete:hover { background: #ff0055; color: #000; }
        
        .write-container { text-align: right; margin-top: 20px; }
        .btn-write { background: transparent; border: 1px solid #ff0055; color: #ff0055; padding: 12px 25px; cursor: pointer; font-weight: bold; transition: 0.3s; }
        .btn-write:hover { background: #ff0055; color: #fff; box-shadow: 0 0 10px #ff0055; }
    </style>
</head>
<body>

<div class="main-container">
    <h2 class="glitch-title"> PUBLIC_NOTICE</h2>

    <table class="retro-table">
        <thead>
            <tr>
                <th width="15%">NO.</th>
                <th width="60%">SUBJECT_PACKET</th>
                <th width="25%">LOG_DATE</th>
            </tr>
        </thead>
<tbody>
    <c:forEach var="notice" items="${list}" varStatus="status">
        <!-- 제목 행 -->
        <tr onclick="toggleNotice('${status.index}')">
            <td>${notice.INo}</td> <!-- INo -> iNo -->
            <td class="subject">
                <span class="notice-tag">[NOTICE]</span> ${notice.ITitle} <!-- ITitle -> iTitle -->
            </td>
            <td>${notice.IDate}</td>
        </tr>
        
        <!-- 내용 행 -->
        <tr id="content-${status.index}" class="content-row">
            <td colspan="3" class="content-cell">
                <div class="notice-body">
                    <!-- HTML 태그 해석을 위해 escapeXml="false" 사용 -->
                    <c:out value="${notice.IContent}" escapeXml="false" />
                </div>

                <!-- 관리자 버튼 -->
                <c:if test="${sessionScope.loginUser.UAuth == 'ADMIN'}">
                    <div class="admin-controls">
                        <button type="button" class="btn-admin btn-edit" 
                                onclick="location.href='${pageContext.request.contextPath}/support/noticeUpdate?nNo=${notice.INo}'">
                            [EDIT_PACKET]
                        </button>
                        <button type="button" class="btn-admin btn-delete" 
                                onclick="deleteNotice('${notice.INo}')">
                            [DELETE_PACKET]
                        </button>
                    </div>
                </c:if>
            </td>
        </tr>
    </c:forEach>
</tbody>
    </table>

    <c:if test="${mode == 'notice' && sessionScope.loginUser.UAuth == 'ADMIN'}">
        <div class="write-container">
            <button class="btn-write" onclick="location.href='${pageContext.request.contextPath}/support/noticeWrite'">
                + NEW_NOTICE_PACKET
            </button>
        </div>
    </c:if>
</div>

<script>
function toggleNotice(index) {
    const el = document.getElementById('content-' + index);
    const isHidden = el.style.display === 'none' || el.style.display === '';
    
    // 선택한 행 토글
    el.style.display = isHidden ? 'table-row' : 'none';
}

function deleteNotice(nNo) {
    if (confirm("NOTICE_PACKET을 영구 삭제하시겠습니까?")) {
        location.href = '${pageContext.request.contextPath}/support/noticeDelete.do?nNo=' + nNo;
    }
}
</script>
</body>
</html>