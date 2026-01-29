<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | ${artist.a_name}</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/music-service.js"></script>

    <style>
        /* SearchResult.jsp의 스타일 그대로 복사 */
        body { background-color: #050505; color: #fff; margin: 0; font-family: 'Pretendard', sans-serif; }
        main { min-height: calc(100vh - 180px); padding-bottom: 120px; position: relative; z-index: 1; }
        .container { max-width: 1000px; margin: 0 auto; padding: 0 20px; }
        
        /* 아티스트 전용 헤더 스타일 */
        .artist-banner { 
            display: flex; align-items: flex-end; padding: 60px 0 30px 0; 
            background: linear-gradient(transparent, rgba(255, 0, 85, 0.1)); 
        }
        .artist-img { 
            width: 200px; height: 200px; border-radius: 50%; object-fit: cover; 
            margin-right: 30px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); border: 2px solid #222;
        }
        .artist-info h1 { font-size: 4rem; margin: 10px 0; text-shadow: 2px 2px 10px rgba(0,0,0,0.5); }
        .artist-label { color: #ff0055; font-weight: bold; font-size: 0.9rem; text-transform: uppercase; }

        /* 테이블 스타일 (SearchResult 이식) */
        .chart-table { width: 100%; border-collapse: collapse; margin-top: 20px; table-layout: fixed; }
        .chart-table th { border-bottom: 1px solid #222; color: #555; text-align: left; padding: 15px; }
        .chart-table th:nth-child(1) { width: 50px; }
        .chart-table th:nth-child(3), .chart-table th:nth-child(4) { width: 80px; text-align: center; }
        .chart-table th:nth-child(5) { width: 100px; text-align: right; padding-right: 30px; }
        
        .album-art { width: 45px; height: 45px; object-fit: cover; border-radius: 4px; margin-right: 15px; cursor: pointer; }
        .play-trigger { color: #00f2ff; cursor: pointer; font-size: 1.5rem; transition: 0.2s; }
        .play-trigger:hover { transform: scale(1.2); text-shadow: 0 0 10px #00f2ff; }
        
        .btn-like.active { color: #ff0055 !important; }
        .section-title { font-size: 1.5rem; margin: 40px 0 20px 0; color: #eee; border-left: 4px solid #ff0055; padding-left: 15px; }
    </style>
</head>
<body>
<header><jsp:include page="/WEB-INF/views/common/Header.jsp" /></header>

<main>
    <div class="container">
        <c:set var="highResImage" value="${fn:replace(artist.a_image, '100x100bb', '600x600bb')}" />
        <div class="artist-banner">
            <img src="${not empty artist.a_image ? highResImage : 'https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png'}" class="artist-img">
            <div class="artist-info">
                <span class="artist-label"><i class="fa-solid fa-circle-check"></i> Verified Artist</span>
                <h1>${artist.a_name}</h1>
                <p style="color: #888;">장르: ${not empty artist.a_genres ? artist.a_genres : 'K-POP'}</p>
            </div>
        </div>

        <h2 class="section-title">인기 곡</h2>
        
        <table class="chart-table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>SONG INFO</th>
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
                            <div style="display: flex; align-items: center; padding: 10px 0;">
                                <img src="${not empty music.b_image ? music.b_image : 'https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png'}" 
                                     class="album-art" onclick="event.stopPropagation(); location.href='/album/detail?b_no=${music.b_no}'">
                                <div>
                                    <div style="font-weight: bold; color: #eee; margin-bottom: 4px;">${music.m_title}</div>
                                    <div style="font-size: 0.85rem; color: #888;">${music.b_title}</div>
                                </div>
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