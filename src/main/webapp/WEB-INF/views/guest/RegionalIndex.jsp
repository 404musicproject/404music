<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | Regional Charts</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://www.youtube.com/iframe_api"></script>
    <script src="${pageContext.request.contextPath}/js/music-service.js"></script>

    <style>
        body { background-color: #050505; color: #fff; margin: 0; font-family: 'Pretendard', sans-serif; }
        
        /* 1. 히어로 섹션 - 배경 블러를 줄여 도시 이미지가 잘 보이게 조정 */
        .region-hero {
            position: relative; height: 380px; width: 100%;
            display: flex; align-items: center; justify-content: center;
            overflow: hidden; border-bottom: 2px solid #ff0055; background-color: #050505;
        }
        #hero-bg {
            position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background-size: cover; background-position: center;
            filter: brightness(0.4) blur(10px); /* 블러를 40에서 10으로 줄여 도시 느낌 강조 */
            transform: scale(1.1);
            z-index: 1; opacity: 0; transition: opacity 0.8s ease, background-image 0.5s ease;
        }
        .hero-content { position: relative; z-index: 2; text-align: center; }
        
        #hero-weather { 
            font-size: 0.9rem; color: #00f2ff; background: rgba(0, 242, 255, 0.15); 
            padding: 5px 15px; border-radius: 20px; display: inline-block; 
            margin-bottom: 10px; border: 1px solid #00f2ff; font-weight: bold;
        }
        #hero-city-name { 
            font-size: 5rem; font-weight: 900; margin: 0; color: #fff; 
            text-shadow: 0 0 30px rgba(255, 255, 255, 0.2); text-transform: uppercase; line-height: 1; 
        }
        #hero-song-info { font-size: 1.1rem; color: #eee; margin-top: 15px; font-weight: 300; }

        /* 2. 메인 컨텐츠 & 탭 */
        main { margin-top: -40px; padding-bottom: 150px; }
        .container { max-width: 1100px; margin: 0 auto; padding: 0 40px; }
        .chart-tabs { display: flex; gap: 12px; margin-bottom: 45px; position: relative; z-index: 10; overflow-x: auto; padding-bottom: 10px; }
        .tab-btn { background: #151515; border: none; color: #666; padding: 12px 28px; cursor: pointer; border-radius: 4px; font-weight: bold; transition: 0.3s; white-space: nowrap; }
        .tab-btn.active { background: #ff0055 !important; color: #fff !important; box-shadow: 0 0 15px rgba(255, 0, 85, 0.4); }

        /* 3. 테이블 및 버튼 스타일 (전과 동일) */
        .chart-table { width: 100%; border-collapse: collapse; margin-top: 20px; background: #0a0a0a; border-radius: 12px; overflow: hidden; }
        .chart-table thead tr { border-bottom: 1px solid #222; color: #555; text-align: left; }
        .chart-table th { padding: 15px; font-size: 0.75rem; text-transform: uppercase; }
        .chart-table button { background: none; border: none; cursor: pointer; transition: 0.2s; padding: 5px; }
        
        .btn-like { font-size: 1.1rem; width: 40px; }
        .btn-like:hover { transform: scale(1.2); color: #ff0055 !important; }
        .btn-lib { color: #00f2ff; font-size: 1.3rem !important; width: 40px; display: inline-flex; align-items: center; justify-content: center; }
        .btn-lib:hover { transform: scale(1.2); color: #fff !important; text-shadow: 0 0 8px #00f2ff; }

        .col-rank { width: 60px; text-align: center !important; }
        .col-play { width: 80px; text-align: right !important; padding-right: 30px !important; }
        .album-art { width: 45px; height: 45px; object-fit: cover; border-radius: 4px; margin-right: 15px; transition: 0.3s; cursor: pointer; }
        #chart-body tr { border-bottom: 1px solid #111; cursor: pointer; transition: 0.2s; }
        #chart-body tr:hover { background-color: rgba(255, 255, 255, 0.05) !important; }
    </style>

   <script>
        // [핵심] 홈 화면과 동일한 도시 이미지 매핑
        const regionImages = {
            'SEOUL': '${pageContext.request.contextPath}/img/location/seoul.jpg',
            'BUSAN': '${pageContext.request.contextPath}/img/location/busan.jpg',
            'DAEGU': '${pageContext.request.contextPath}/img/location/daegu.jpg',
            'DAEJEON': '${pageContext.request.contextPath}/img/location/daejeon.jpg',
            'JEJU': '${pageContext.request.contextPath}/img/location/jeju.jpg',
            'DEFAULT': '${pageContext.request.contextPath}/img/location/seoul.jpg'
        };

        $(document).ready(function() {
            const uNo = "${sessionScope.loginUser.uNo}" || 0;
            const contextPath = '${pageContext.request.contextPath}';
            const urlParams = new URLSearchParams(window.location.search);
            const targetCity = urlParams.get('city');

            MusicApp.currentMode = 'regional';
            MusicApp.init(Number(uNo));

            MusicApp.renderRow = function(item, index) {
                const mNo = item.MNO || item.m_no || 0;
                const bNo = item.BNO || item.b_no || 0;
                const aNo = item.ANO || item.a_no || 0;
                const rawTitle = item.TITLE || item.m_title || 'Unknown';
                const rawArtist = item.ARTIST || item.a_name || 'Unknown';
                const albumImg = item.ALBUM_IMG || item.b_image || '';
                const isLiked = (item.isLiked === 'Y' || (item.MY_LIKE && item.MY_LIKE > 0));

                if(index === 0) {
                    const realLoc = (item.H_LOCATION || item.h_location || "MY LOCATION").toUpperCase();
                    // 파라미터가 없을 때만 자동 위치로 이름과 배경 변경
                    if(!targetCity && $('#hero-city-name').text() === "MY LOCATION") {
                        $('#hero-city-name').text(realLoc);
                        updateBackground(realLoc);
                    }
                    const weatherId = item.H_WEATHER || item.h_weather || 800;
                    let weatherIcon = weatherId >= 801 ? 'fa-cloud' : (weatherId == 800 ? 'fa-sun' : 'fa-cloud-sun');
                    $('#hero-weather').html('<i class="fa-solid ' + weatherIcon + '"></i> ' + $('#hero-city-name').text());
                    $('#hero-song-info').html('<b style="color:#ff0055;">TOP HIT</b> &nbsp; ' + rawTitle + ' — ' + rawArtist);
                }

                return '<tr onclick="MusicApp.playLatestYouTube(\'' + rawTitle.replace(/'/g, "\\'") + '\', \'' + rawArtist.replace(/'/g, "\\'") + '\', \'' + albumImg + '\');">' +
                       '<td class="col-rank" style="padding: 20px 15px; color: #444;">' + (index + 1) + '</td>' +
                       '<td><div style="display:flex; align-items:center; padding: 10px 0;">' +
                       '<img src="' + albumImg + '" class="album-art">' +
                       '<div><div style="font-weight:bold; color: #eee; margin-bottom: 4px;">' + rawTitle + '</div>' +
                       '<div style="color:#888;">' + rawArtist + '</div></div></div></td>' +
                       '<td style="text-align:center;"><button class="btn-like" style="color:' + (isLiked ? '#ff0055' : '#444') + '" onclick="event.stopPropagation(); MusicApp.toggleLike(' + mNo + ', this);"><i class="fa-' + (isLiked ? 'solid' : 'regular') + ' fa-heart"></i></button></td>' +
                       '<td style="text-align:center;"><button class="btn-lib" onclick="event.stopPropagation(); MusicApp.addToLibrary(' + mNo + ');"><i class="fa-solid fa-plus-square"></i></button></td>' +
                       '<td class="col-play"><i class="fa-solid fa-circle-play play-trigger"></i></td>' +
                       '</tr>';
            };

            if (targetCity) {
                changeRegion(targetCity);
            } else {
                if (navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(pos => {
                        MusicApp.lat = pos.coords.latitude; MusicApp.lon = pos.coords.longitude;
                        MusicApp.loadChart();
                    }, () => MusicApp.loadChart());
                } else { MusicApp.loadChart(); }
            }
        });

        // 배경 이미지를 변경하는 함수
        function updateBackground(city) {
            const bgUrl = regionImages[city.toUpperCase()] || regionImages['DEFAULT'];
            $('#hero-bg').css({
                'background-image': 'url("' + bgUrl + '")',
                'opacity': '1'
            });
        }

        function changeRegion(city, btn) {
            $('.tab-btn').removeClass('active');
            if(btn) $(btn).addClass('active');
            else $(`.tab-btn:contains('${city.toUpperCase()}')`).addClass('active');

            $('#hero-city-name').text(city.toUpperCase());
            updateBackground(city); // 도시 배경 즉시 적용
            
            MusicApp.selectedCity = city;
            MusicApp.lat = null; MusicApp.lon = null;
            MusicApp.loadChart();
        }
    </script>
</head>
<body>
<header><%@ include file="/WEB-INF/views/common/Header.jsp" %></header>

<section class="region-hero">
    <div id="hero-bg"></div>
    <div class="hero-content">
        <div id="hero-weather"><i class="fa-solid fa-location-crosshairs"></i> SYNCING...</div>
        <h1 id="hero-city-name">MY LOCATION</h1>
        <div id="hero-song-info">Loading Local Data...</div>
    </div>
</section>

<main>
    <div class="container">
        <div class="chart-tabs">
            <button class="tab-btn active" onclick="location.reload()">AUTO(GPS)</button>
            <button class="tab-btn" onclick="changeRegion('SEOUL', this)">SEOUL</button>
            <button class="tab-btn" onclick="changeRegion('BUSAN', this)">BUSAN</button>
            <button class="tab-btn" onclick="changeRegion('DAEGU', this)">DAEGU</button>
            <button class="tab-btn" onclick="changeRegion('DAEJEON', this)">DAEJEON</button>
            <button class="tab-btn" onclick="changeRegion('JEJU', this)">JEJU</button>
            <button class="tab-btn" onclick="location.href='${pageContext.request.contextPath}/music/Index'" style="margin-left: auto; color: #ff0055 !important;">← EXIT</button>
        </div>

        <table class="chart-table">
            <thead>
                <tr>
                    <th class="col-rank">#</th>
                    <th>SONG INFO</th>
                    <th style="text-align: center;">LIKE</th>
                    <th style="text-align: center;">LIB</th>
                    <th class="col-play">PLAY</th>
                </tr>
            </thead>
            <tbody id="chart-body">
                <tr><td colspan="5" style="text-align:center; padding:100px; color:#444;">데이터 분석 중...</td></tr>
            </tbody>
        </table>
    </div>
</main>

<footer><%@ include file="/WEB-INF/views/common/Footer.jsp" %></footer>
</body>
</html>