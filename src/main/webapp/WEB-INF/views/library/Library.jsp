<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Library</title>
</head>
<body>

<h2>라이브러리 (좋아요)</h2>

<c:if test="${empty uNo}">
    <p><b>uNo가 없습니다.</b> 테스트하려면 아래처럼 접속하세요:</p>
    <p><code>/user/library?uNo=1</code></p>
</c:if>

<hr>

<h3>곡 좋아요 추가</h3>
<form method="post" action="${pageContext.request.contextPath}/user/library/like">
    <input type="hidden" name="uNo" value="${uNo}" />
    m_no: <input type="number" name="mNo" required />
    <button type="submit">좋아요</button>
</form>

<hr>

<h3>내 좋아요 곡</h3>
<c:if test="${empty likedSongs}">
    <p>좋아요한 곡이 없습니다.</p>
</c:if>

<c:if test="${not empty likedSongs}">
    <table border="1" cellpadding="6">
        <tr>
            <th>곡</th>
            <th>m_no</th>
            <th>취소</th>
        </tr>
        <c:forEach var="s" items="${likedSongs}">
            <tr>
                <td>${s.mTitle} - ${s.aName}</td>
                <td>${s.lTargetNo}</td>
                <td>
                    <form method="post" action="${pageContext.request.contextPath}/user/library/unlike" style="display:inline;">
                        <input type="hidden" name="uNo" value="${uNo}" />
                        <input type="hidden" name="mNo" value="${s.lTargetNo}" />
                        <button type="submit">취소</button>
                    </form>
                </td>
            </tr>
        </c:forEach>
    </table>
</c:if>

<hr>

<h3>내 플레이리스트 바로가기</h3>
<p><a href="${pageContext.request.contextPath}/user/playlists?uNo=${uNo}">플레이리스트</a></p>

<c:if test="${not empty playlists}">
    <ul>
        <c:forEach var="p" items="${playlists}">
            <li>
                <a href="${pageContext.request.contextPath}/user/playlists/detail?tNo=${p.tNo}&uNo=${uNo}">
                    ${p.tTitle} (t_no=${p.tNo})
                </a>
            </li>
        </c:forEach>
    </ul>
</c:if>

</body>
</html>