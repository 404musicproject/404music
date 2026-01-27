<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Playlists</title>
</head>
<body>
<h2>내 플레이리스트</h2>

<c:if test="${empty uNo}">
    <p><b>uNo가 없습니다.</b> 테스트하려면 아래처럼 접속하세요:</p>
    <p><code>/user/playlists?uNo=1</code></p>
</c:if>

<hr>

<h3>플레이리스트 생성</h3>
<form method="post" action="${pageContext.request.contextPath}/user/playlists/create">
    <input type="hidden" name="uNo" value="${uNo}" />
    제목: <input type="text" name="title" required />
    비공개(Y/N): <input type="text" name="isPrivate" value="N" />
    대표곡 m_no(필수): <input type="number" name="coverMNo" required />
    <button type="submit">생성</button>
</form>

<hr>

<h3>목록</h3>
<c:if test="${empty playlists}">
    <p>플레이리스트가 없습니다.</p>
</c:if>

<c:if test="${not empty playlists}">
    <table border="1" cellpadding="6">
        <tr>
            <th>t_no</th>
            <th>제목</th>
            <th>대표곡</th>
            <th>비공개</th>
            <th>상세</th>
            <th>삭제</th>
        </tr>
        <c:forEach var="p" items="${playlists}">
            <tr>
                <td>${p.tNo}</td>
                <td>${p.tTitle}</td>
                <td>${p.coverTitle} - ${p.coverArtist} (m_no=${p.mNo})</td>
                <td>${p.tPrivate}</td>
                <td>
                    <a href="${pageContext.request.contextPath}/user/playlists/detail?tNo=${p.tNo}&uNo=${uNo}">열기</a>
                </td>
                <td>
                    <form method="post" action="${pageContext.request.contextPath}/user/playlists/delete" style="display:inline;">
                        <input type="hidden" name="tNo" value="${p.tNo}" />
                        <input type="hidden" name="uNo" value="${uNo}" />
                        <button type="submit" onclick="return confirm('삭제할까요?');">삭제</button>
                    </form>
                </td>
            </tr>
        </c:forEach>
    </table>
</c:if>

<hr>
<p><a href="${pageContext.request.contextPath}/user/library?uNo=${uNo}">라이브러리(좋아요)</a></p>
</body>
</html>