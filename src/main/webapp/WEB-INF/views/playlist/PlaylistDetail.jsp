<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Playlist Detail</title>
</head>
<body>

<h2>플레이리스트 상세</h2>

<c:if test="${empty playlist}">
    <p>플레이리스트를 찾을 수 없습니다.</p>
    <p><a href="${pageContext.request.contextPath}/user/playlists?uNo=${uNo}">목록</a></p>
</c:if>

<c:if test="${not empty playlist}">
    <p>
        <b>${playlist.tTitle}</b>
        (t_no=${playlist.tNo}, u_no=${playlist.uNo}, private=${playlist.tPrivate})
    </p>
    <p>대표곡: ${playlist.coverTitle} - ${playlist.coverArtist} (m_no=${playlist.mNo})</p>

    <hr>

    <h3>트랙 추가</h3>
    <form method="post" action="${pageContext.request.contextPath}/user/playlists/tracks/add">
        <input type="hidden" name="tNo" value="${playlist.tNo}" />
        <input type="hidden" name="uNo" value="${uNo}" />
        m_no: <input type="number" name="mNo" required />
        <button type="submit">추가</button>
    </form>

    <hr>

    <h3>트랙 목록</h3>
    <c:if test="${empty tracks}">
        <p>트랙이 없습니다.</p>
    </c:if>

    <c:if test="${not empty tracks}">
        <table border="1" cellpadding="6">
            <tr>
                <th>순서</th>
                <th>곡</th>
                <th>m_no</th>
                <th>추가일</th>
                <th>삭제</th>
            </tr>
            <c:forEach var="t" items="${tracks}">
                <tr>
                    <td>${t.mOrder}</td>
                    <td>${t.mTitle} - ${t.aName}</td>
                    <td>${t.mNo}</td>
                    <td>${t.ptAddedAt}</td>
                    <td>
                        <form method="post" action="${pageContext.request.contextPath}/user/playlists/tracks/delete" style="display:inline;">
                            <input type="hidden" name="tNo" value="${playlist.tNo}" />
                            <input type="hidden" name="ptNo" value="${t.ptNo}" />
                            <input type="hidden" name="uNo" value="${uNo}" />
                            <button type="submit">삭제</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
        </table>
    </c:if>

    <hr>
    <p>
        <a href="${pageContext.request.contextPath}/user/playlists?uNo=${uNo}">목록</a>
        |
        <a href="${pageContext.request.contextPath}/user/library?uNo=${uNo}">라이브러리(좋아요)</a>
    </p>
</c:if>

</body>
</html>