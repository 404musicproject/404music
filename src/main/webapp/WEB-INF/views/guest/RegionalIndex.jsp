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
        
        /* [Region 고유 스타일] 히어로 섹션 */
        .region-hero {
            position: relative; height: 380px; width: 100%;
            display: flex; align-items: center; justify-content: center;
            overflow: hidden; border-bottom: 2px solid #ff0055; background-color: #050505;
        }
        #hero-bg {
            position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background-size: cover; background-position: center;
            filter: brightness(0.4) blur(10px);
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

        /* [공통 스타일] 메인 레이아웃 */
        main { margin-top: -40px; padding-bottom: 150px; position: relative; z-index: 10; }
        .container { max-width: 1100px; margin: 0 auto; padding: 0 40px; }

        /* [공통 스타일] 탭 버튼 */
        .chart-tabs { display: flex; gap: 12px; margin-bottom: 45px; overflow-x: auto; padding-bottom: 10px; }
        .tab-btn { background: #151515; border: none; color: #666; padding: 12px 28px; cursor: pointer; border-radius: 4px; font-weight: bold; transition: 0.3s; white-space: nowrap; }
        .tab-btn.active { background: #ff0055 !important; color: #fff !important; box-shadow: 0 0 15px rgba(255, 0, 85, 0.4); }

        /* [공통 스타일] 테이블 디자인 (Index.jsp와 동기화) */
        .chart-table { width: 100%; border-collapse: collapse; margin-top: 20px; background: #0a0a0a; border-radius: 12px; overflow: hidden; }
        .chart-table thead tr { border-bottom: 1px solid #222; color: #555; text-align: left; }
        .chart-table th { padding: 15px; font-size: 0.75rem; text-transform: uppercase; }

        /* 컬럼 너비 설정 */
        .col-rank { width: 50px; text-align: center !important; }
        .col-info { width: auto; }
        .col-btn  { width: 80px; text-align: center !important; }
        .col-play { width: 80px; text-align: right !important; padding-right: 30px !important; }

        /* 버튼 및 텍스트 스타일 */
        .chart-table button { background: none; border: none; cursor: pointer; transition: 0.2s; padding: 5px; }
        .album-art { width: 45px; height: 45px; object-fit: cover; border-radius: 4px; margin-right: 15px; transition: 0.3s; cursor: pointer; flex-shrink: 0; }
        .album-art:hover { filter: brightness(1.3); transform: scale(1.05); }
        
        .artist-name { color: #888; font-size: 0.85rem; cursor: pointer; transition: 0.2s; }
        .artist-name:hover { color: #00f2ff !important; text-decoration: underline; }

        /* 플레이 버튼 스타일 (Index와 동일) */
        .play-trigger { color: #00f2ff; cursor: pointer; font-size: 1.5rem; transition: 0.2s; }
        .play-trigger:hover { transform: scale(1.2); text-shadow: 0 0 10px #00f2ff; }

        /* 행 스타일 */
        #chart-body tr { border-bottom: 1px solid #111; cursor: pointer; transition: 0.2s; }
        #chart-body tr:hover { background-color: rgba(255, 255, 255, 0.05) !important; }
    </style>

   <script>
        // 도시 이미지 매핑
        const regionImages = {
            'SEOUL': '${pageContext.request.contextPath}/img/Location/seoul.jpg',
            'BUSAN': '${pageContext.request.contextPath}/img/Location/busan.jpg',
            'DAEGU': '${pageContext.request.contextPath}/img/Location/daegu.jpg',
            'DAEJEON': '${pageContext.request.contextPath}/img/Location/daejeon.jpg',
            'JEJU': '${pageContext.request.contextPath}/img/Location/jeju.jpg',
            'DEFAULT': '${pageContext.request.contextPath}/img/Location/seoul.jpg'
        };

        $(document).ready(function() {
            const uNo = "${sessionScope.loginUser.uNo}" || 0;
            const contextPath = '${pageContext.request.contextPath}';
            const urlParams = new URLSearchParams(window.location.search);
            const targetCity = urlParams.get('city');

            MusicApp.init(Number(uNo));
            MusicApp.currentMode = 'regional';

            // [핵심 변경] renderRow를 Index.jsp 스타일로 재정의
            MusicApp.renderRow = function(item, index) {
                const mNo = item.MNO || item.m_no || 0;
                const bNo = item.BNO || item.b_no || 0;
                const aNo = item.ANO || item.a_no || 0;
                const rawTitle = item.TITLE || item.m_title || 'Unknown';
                const rawArtist = item.ARTIST || item.a_name || 'Unknown';
                const albumImg = item.ALBUM_IMG || item.b_image || '';
                
                const titleForJS = String(rawTitle).replace(/'/g, "\\'");
                const artistForJS = String(rawArtist).replace(/'/g, "\\'");

                // 로그인 유저 체크 후 좋아요 여부 판단
                const isLiked = (uNo > 0) && (item.isLiked === 'Y' || (item.MY_LIKE && item.MY_LIKE > 0));

                // 1위 곡 정보로 히어로 섹션 업데이트 (Region 페이지 전용 로직)
                if(index === 0) {
                    const realLoc = (item.H_LOCATION || item.h_location || "MY LOCATION").toUpperCase();
                    if(!targetCity && $('#hero-city-name').text() === "MY LOCATION") {
                        $('#hero-city-name').text(realLoc);
                        updateBackground(realLoc);
                    }
                    const weatherId = item.H_WEATHER || item.h_weather || 800;
                    let weatherIcon = weatherId >= 801 ? 'fa-cloud' : (weatherId == 800 ? 'fa-sun' : 'fa-cloud-sun');
                    $('#hero-weather').html('<i class="fa-solid ' + weatherIcon + '"></i> ' + $('#hero-city-name').text());
                    $('#hero-song-info').html('<b style="color:#ff0055;">TOP HIT</b> &nbsp; ' + rawTitle + ' — ' + rawArtist);
                }

                // [중요] Index.jsp와 동일한 테이블 구조 반환
                return '<tr onclick="MusicApp.playLatestYouTube(\'' + titleForJS + '\', \'' + artistForJS + '\', \'' + albumImg + '\');">' +
                       '<td class="col-rank">' + (index + 1) + '</td>' +
                       '<td>' +
                           '<div style="display: flex; align-items: center; padding: 10px 0;">' +
                               '<img src="' + albumImg + '" class="album-art" onclick="event.stopPropagation(); location.href=\'' + contextPath + '/album/detail?b_no=' + bNo + '\'">' +
                               '<div style="margin-left: 5px;">' +
                                   '<div style="font-weight: bold; color: #eee; margin-bottom: 4px;">' + rawTitle + '</div>' +
                                   '<div class="artist-name" onclick="event.stopPropagation(); location.href=\'' + contextPath + '/artist/detail?a_no=' + aNo + '\'">' + rawArtist + '</div>' +
                               '</div>' +
                           '</div>' +
                       '</td>' +
                       '<td class="col-btn">' +
                           '<button style="color:' + (isLiked ? '#ff0055' : '#444') + '" onclick="event.stopPropagation(); MusicApp.toggleLike(' + mNo + ', this);">' +
                               '<i class="fa-' + (isLiked ? 'solid' : 'regular') + ' fa-heart"></i>' +
                           '</button>' +
                       '</td>' +
                       '<td class="col-btn">' +
                           '<button style="color: #00f2ff;" onclick="event.stopPropagation(); MusicApp.addToLibrary(' + mNo + ');">' +
                               '<i class="fa-solid fa-plus-square"></i>' +
                           '</button>' +
                       '</td>' +
                       '<td class="col-play">' +
                           '<i class="fa-solid fa-circle-play play-trigger"></i>' +
                       '</td>' +
                       '</tr>';
            };

            // 위치 초기화 로직
            if (targetCity) {
                changeRegion(targetCity);
            } else {
                if (navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(
                        pos => {
                            const lat = pos.coords.latitude;
                            const lon = pos.coords.longitude;
                            
                            MusicApp.lat = lat; 
                            MusicApp.lon = lon;
                            MusicApp.selectedCity = null;

                            // [추가] GPS 좌표를 가져오면 실제 날씨 API를 호출합니다.
                            fetchRealWeather(lat, lon); 
                            
                            MusicApp.loadChart();
                        }, 
                        err => {
                            console.warn("GPS 실패:", err.message);
                            MusicApp.loadChart();
                        },
                        { timeout: 5000 } 
                    );
                } else { 
                    MusicApp.loadChart(); 
                }
            }
        });

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
            updateBackground(city);
            
            MusicApp.selectedCity = city;
            MusicApp.lat = null; MusicApp.lon = null;
            MusicApp.loadChart();
        }
     // 예시: 날씨 정보를 직접 가져오는 함수 (API 키 필요)
     // [수정] 날씨 정보를 가져와서 화면에 반영하는 완성된 함수
        function fetchRealWeather(lat, lon) {
            const apiKey = '9021ce9b1f7a9ae39654c4cb2f33250a';
            // units=metric 추가 시 섭씨 온도를 가져올 수 있습니다.
            const url = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${apiKey}&units=metric`;
            
            $.getJSON(url, function(data) {
                const weatherId = data.weather[0].id;
                const temp = Math.round(data.main.temp); // 현재 온도
                const cityName = data.name; // 도시 이름 (영어)

                // Weather ID에 따른 아이콘 결정
                let iconClass = 'fa-sun';
                if (weatherId >= 200 && weatherId < 600) iconClass = 'fa-cloud-showers-heavy';
                else if (weatherId >= 600 && weatherId < 700) iconClass = 'fa-snowflake';
                else if (weatherId >= 801) iconClass = 'fa-cloud';

                // 화면에 반영
                $('#hero-weather').html(`<i class="fa-solid ${iconClass}"></i> ${cityName} ${temp}°C`);
                $('#hero-city-name').text(cityName.toUpperCase());
            }).fail(function() {
                console.error("날씨 정보를 불러오지 못했습니다.");
            });
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
                    <th class="col-info">SONG INFO</th>
                    <th class="col-btn">LIKE</th>
                    <th class="col-btn">LIB</th>
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