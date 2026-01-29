<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | Regional Charts</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/music-chart.css">
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://www.youtube.com/iframe_api"></script>
    <script src="${pageContext.request.contextPath}/js/music-service.js"></script>

    <style>
        .region-hero {
            position: relative; height: 380px; width: 100%;
            display: flex; align-items: center; justify-content: center;
            overflow: hidden; border-bottom: 2px solid #ff0055; background-color: #050505;
        }
        #hero-bg {
            position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background-size: cover; background-position: center;
            filter: blur(40px) brightness(0.35); transform: scale(1.1);
            z-index: 1; opacity: 0; transition: opacity 1.2s ease;
        }
        .hero-content { position: relative; z-index: 2; text-align: center; }
        #hero-city-name { font-size: 5rem; font-weight: 900; margin: 0; color: #00f2ff; text-shadow: 0 0 30px rgba(0, 242, 255, 0.6); text-transform: uppercase; }
        #hero-song-info { font-size: 1.2rem; color: #eee; margin-top: 20px; font-weight: 300; }
        main { margin-top: -80px; }

        /* 하단 플레이어 스타일 유지 */
        #player-container { 
            position: fixed; bottom: 30px; right: 30px; 
            background: #000; padding: 12px; border-radius: 12px; 
            display: none; z-index: 1001; 
            border: 2px solid #ff0055; box-shadow: 0 0 25px rgba(255, 0, 85, 0.5); 
        }
    </style>

    <script>
        $(document).ready(function() {
            const uNo = "${sessionScope.loginUser.uNo}" || 0;
            MusicApp.currentMode = 'regional';
            MusicApp.selectedCity = "${city}";

            // MusicApp 초기화
            MusicApp.init(Number(uNo));
            startHeroWatch();

            // 차트 클릭 시 재생 기능 (Index.jsp와 동일)
            $('#chart-body').on('click', 'tr', function(e) {
                if ($(e.target).closest('.btn-like, .preview-badge').length) return;
                const musicNo = $(this).data('mno'); 
                if (musicNo) {
                    $('#player-container').fadeIn(); // 플레이어 보이기
                    MusicApp.playMusic(musicNo);
                }
            });
        });

        // 1위 곡 정보로 Hero 영역 업데이트
        function startHeroWatch() {
		    let attempts = 0;
		    const checkData = setInterval(function() {
		        const $firstRow = $('#chart-body tr').first();
		        
		        // 1. 이미지 가져오기
		        const imgSrc = $firstRow.find('img').attr('src');
		        
		        // 2. 제목 가져오기 (미리듣기 뱃지 텍스트 제외하고 제목만 추출)
		        let title = $firstRow.find('b').first().text(); 
		        if(!title) {
		            // b 태그가 없을 경우 대비하여 전체 텍스트에서 '미리듣기'를 제거
		            title = $firstRow.find('td:eq(1)').text().replace('미리듣기', '').trim();
		        }
		
		        // 3. 가수명 가져오기
		        const artist = $firstRow.find('.artist-name').text() || $firstRow.find('span').last().text();
		
		        if (imgSrc && title && title !== "Loading...") {
		            // 배경과 텍스트 업데이트
		            $('#hero-bg').css({'background-image': 'url("' + imgSrc + '")', 'opacity': '1'});
		            
		            // 정보 업데이트 (애니메이션 효과)
		            $('#hero-song-info').fadeOut(200, function() {
		                $(this).html('<b>' + title + '</b> — ' + artist).fadeIn(300);
		            });
		            
		            clearInterval(checkData); // 성공했으므로 감시 종료
		        }
		        
		        // 10초(20회) 동안 시도 후 데이터가 없으면 중단
		        if (++attempts > 20) clearInterval(checkData);
		    }, 500);
		}

        function changeRegion(city, btn) {
            $('.tab-btn').removeClass('active');
            $(btn).addClass('active');
            $('#hero-city-name').text(city);
            $('#hero-bg').css('opacity', '0');
            MusicApp.selectedCity = city;
            MusicApp.loadChart();
            startHeroWatch();
        }
    </script>
</head>
<body>
<header><%@ include file="/WEB-INF/views/common/Header.jsp" %></header>

<section class="region-hero">
    <div id="hero-bg"></div>
    <div class="hero-content">
        <h1 id="hero-city-name">${city}</h1>
        <div id="hero-song-info">Loading Regional Chart...</div>
    </div>
</section>

<main>
    <div class="container">
        <div class="chart-tabs">
            <button class="tab-btn ${city == 'SEOUL' ? 'active' : ''}" onclick="changeRegion('SEOUL', this)">SEOUL</button>
            <button class="tab-btn ${city == 'BUSAN' ? 'active' : ''}" onclick="changeRegion('BUSAN', this)">BUSAN</button>
            <button class="tab-btn ${city == 'DAEGU' ? 'active' : ''}" onclick="changeRegion('DAEGU', this)">DAEGU</button>
            <button class="tab-btn ${city == 'DAEJEON' ? 'active' : ''}" onclick="changeRegion('DAEJEON', this)">DAEJEON</button>
            <button class="tab-btn ${city == 'JEJU' ? 'active' : ''}" onclick="changeRegion('JEJU', this)">JEJU</button>
            <button class="tab-btn" onclick="location.href='${pageContext.request.contextPath}/music/Index'" style="margin-left: auto; border-color: #444; color: #888 !important; background: transparent;">← EXIT</button>
        </div>

        <div class="section">
            <div class="chart-header">
                <h2 style="margin:0; color:#ff0055;">TOP 100</h2>
            </div>
            <table class="chart-table">
                <thead>
                    <tr><th>RANK</th><th>SONG INFO</th><th style="text-align: center;">LIKE</th><th style="text-align: center; width: 80px;">LIB</th> <th style="text-align: right; padding-right: 20px;">PLAYS</th></tr>
                </thead>
                <tbody id="chart-body"></tbody>
            </table>
        </div>
    </div>
</main>

<div id="player-container">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
        <h4 id="now-playing-title" style="font-size: 0.75rem; color: #00f2ff; margin: 0; max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">재생 중인 곡 없음</h4>
        <button onclick="MusicApp.stopAll(); $('#player-container').fadeOut();" style="background:none; border:none; color:#ff0055; cursor:pointer; font-size: 18px;">&times;</button>
    </div>
    <div id="player"></div>
</div>

<footer><%@ include file="/WEB-INF/views/common/Footer.jsp" %></footer>
</body>
</html>