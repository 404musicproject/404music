<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | ${album.b_title}</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/music-service.js"></script>

    <style>
        /* 기본 레이아웃 (SearchResult/ArtistDetail과 동일) */
        body { background-color: #050505; color: #fff; margin: 0; font-family: 'Pretendard', sans-serif; }
        main { min-height: calc(100vh - 180px); padding-bottom: 120px; position: relative; z-index: 1; }
        .container { max-width: 1000px; margin: 0 auto; padding: 0 20px; }
        
        /* 앨범 전용 헤더 스타일 */
        .album-banner { 
            display: flex; align-items: flex-end; padding: 60px 0 30px 0; 
            background: linear-gradient(transparent, rgba(0, 242, 255, 0.05)); 
        }
        .album-img { 
            width: 230px; height: 230px; object-fit: cover; 
            margin-right: 30px; box-shadow: 0 10px 40px rgba(0,0,0,0.6); border-radius: 8px;
        }
        .album-info .label { color: #00f2ff; font-weight: bold; font-size: 0.9rem; text-transform: uppercase; }
        .album-info h1 { font-size: 3.5rem; margin: 10px 0; font-weight: 800; line-height: 1.2; }
        .album-meta { display: flex; align-items: center; gap: 10px; color: #eee; font-size: 1rem; }
        .artist-name-link { color: #fff; text-decoration: none; font-weight: bold; }
        .artist-name-link:hover { text-decoration: underline; color: #00f2ff; }

        /* 테이블 스타일 (SearchResult 이식) */
        .chart-table { width: 100%; border-collapse: collapse; margin-top: 20px; table-layout: fixed; }
        .chart-table th { border-bottom: 1px solid #222; color: #555; text-align: left; padding: 15px; font-size: 0.8rem; }
        .chart-table th:nth-child(1) { width: 50px; }
        .chart-table th:nth-child(3), .chart-table th:nth-child(4) { width: 80px; text-align: center; }
        .chart-table th:nth-child(5) { width: 100px; text-align: right; padding-right: 30px; }
        
        .play-trigger { color: #00f2ff; cursor: pointer; font-size: 1.5rem; transition: 0.2s; }
        .play-trigger:hover { transform: scale(1.2); text-shadow: 0 0 10px #00f2ff; }
        
        .btn-like.active { color: #ff0055 !important; }
        .section-title { font-size: 1.3rem; margin: 40px 0 10px 0; color: #888; font-weight: normal; }
    </style>
</head>
<body>
<header><jsp:include page="/WEB-INF/views/common/Header.jsp" /></header>

<main>
    <div class="container">
        <c:set var="highResAlbum" value="${fn:replace(album.b_image, '100x100bb', '600x600bb')}" />
        
       <div class="album-banner">
		    <c:choose>
		        <%-- 1. album 객체에 데이터가 있을 때 --%>
		        <c:when test="${not empty album.b_image}">
		            <c:set var="targetImg" value="${fn:replace(album.b_image, '100x100bb', '600x600bb')}" />
		            <c:set var="targetTitle" value="${album.b_title}" />
		        </c:when>
		        <%-- 2. album 객체가 비었으면 musicList의 첫 번째 곡 이미지라도 가져옴 --%>
		        <c:otherwise>
		            <c:set var="targetImg" value="${fn:replace(musicList[0].b_image, '100x100bb', '600x600bb')}" />
		            <c:set var="targetTitle" value="${musicList[0].b_title}" />
		        </c:otherwise>
		    </c:choose>
		
		    <img src="${not empty targetImg ? targetImg : 'https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png'}" 
		         class="album-img" 
		         onerror="this.src='https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png'">
		
		    <div class="album-info">
		        <span class="label" style="color: #00f2ff; font-weight: bold;">ALBUM</span>
		        <h1 style="color: white; font-size: 3.5rem; margin: 10px 0;">
		            ${not empty targetTitle ? targetTitle : 'Unknown Album'}
		        </h1>
		        <div class="album-meta">
		            <span style="color: #ccc;">아티스트: </span>
		            <a href="/artist/detail?a_no=${musicList[0].a_no}" style="color: #00f2ff; font-weight: bold; text-decoration: none;">
		                ${musicList[0].a_name}
		            </a>
		        </div>
		    </div>
		</div>

        <h2 class="section-title">수록곡</h2>
        
        <table class="chart-table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>TITLE</th>
                    <th style="text-align: center;">LIKE</th>
                    <th style="text-align: center;">LIB</th> 
                    <th style="text-align: right; padding-right: 30px;">PLAY</th>
                </tr>
            </thead>
            <tbody id="chart-body">
                <c:forEach var="music" items="${musicList}" varStatus="status">
                    <tr style="border-bottom: 1px solid #111; transition: 0.3s; cursor: pointer;" 
                        onclick="MusicApp.playLatestYouTube('${music.m_title}', '${music.a_name}', '${music.b_image}')"
                        onmouseover="this.style.backgroundColor='rgba(255,255,255,0.03)'" 
                        onmouseout="this.style.backgroundColor='transparent'">
                        <td style="padding: 15px; color: #444;">${status.count}</td>
                        <td>
                            <div>
                                <div style="font-weight: bold; color: #eee; margin-bottom: 4px;">${music.m_title}</div>
                                <div style="font-size: 0.85rem; color: #888;">${music.a_name}</div>
                            </div>
                        </td>
                        <td style="text-align: center;">
                            <button class="btn-like ${music.isLiked eq 'Y' ? 'active' : ''}" 
                                    style="background:none; border:none; cursor:pointer; color: ${music.isLiked eq 'Y' ? '#ff0055' : '#444'};"
                                    onclick="event.stopPropagation(); MusicApp.toggleLike(${music.m_no}, this);">
                                <i class="fa-${music.isLiked eq 'Y' ? 'solid' : 'regular'} fa-heart"></i>
                            </button>
                        </td>
                        <td style="text-align: center;">
                            <button class="btn-add-lib" style="background:none; border:none; color:#00f2ff; cursor:pointer; font-size: 1.1rem;"
                                    onclick="event.stopPropagation(); MusicApp.addToLibrary(${music.m_no}, this);">
                                <i class="fa-solid fa-plus-square"></i>
                            </button>
                        </td>
                        <td style="text-align: right; padding-right: 30px;">
                            <i class="fa-solid fa-circle-play play-trigger"></i>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</main>

<footer><jsp:include page="/WEB-INF/views/common/Footer.jsp" /></footer>

<script>
    $(document).ready(function() {
        const sessionUno = "${sessionScope.loginUser.UNo}";
        if (sessionUno && sessionUno !== "0") {
            if(typeof MusicApp !== 'undefined') {
                MusicApp.init(Number(sessionUno));
            }
        }
    });
</script>
</body>
</html>