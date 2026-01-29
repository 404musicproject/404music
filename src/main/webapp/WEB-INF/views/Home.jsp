<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" buffer="16kb" autoFlush="true" %>
<%@ taglib prefix="c" uri = "jakarta.tags.core"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | Digital Archive</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/music-service.js"></script>
    <style>
        body { background-color: #050505; color: #fff; font-family: 'Pretendard', sans-serif; overflow-x: hidden; margin: 0; }
        
        /* 1. 히어로 섹션 */
        .hero-section { position: relative; height: 60vh; width: 100%; display: flex; align-items: center; justify-content: center; overflow: hidden; border-bottom: 2px solid #ff0055; }
        #top1-bg { position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-size: cover; background-position: center; filter: blur(20px) brightness(0.3); z-index: 1; transition: all 1s ease; }
        .hero-content { position: relative; z-index: 2; text-align: center; display: flex; flex-direction: column; align-items: center; cursor: pointer; transition: transform 0.3s; }
        .hero-content:hover { transform: scale(1.03); }
        #top1-jacket { width: 250px; height: 250px; border-radius: 12px; box-shadow: 0 0 30px rgba(255, 0, 85, 0.5); border: 2px solid #ff0055; margin-bottom: 20px; object-fit: cover; }
        .top1-badge { background: #ff0055; padding: 4px 12px; font-weight: bold; font-size: 0.9rem; margin-bottom: 10px; letter-spacing: 2px; }

        /* 2. 메뉴 그리드 */
        .menu-grid { max-width: 1000px; margin: -50px auto 50px; display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; padding: 0 20px; position: relative; z-index: 10; }
        .menu-card { background: #0a0a0a; border: 1px solid #00f2ff; padding: 30px 10px; text-align: center; text-decoration: none; color: #00f2ff; transition: all 0.3s; border-radius: 8px; display: flex; flex-direction: column; gap: 10px; cursor: pointer; }
        .menu-card:hover { background: rgba(0, 242, 255, 0.1); transform: translateY(-10px); box-shadow: 0 0 20px rgba(0, 242, 255, 0.4); color: #fff; border-color: #fff; }
        
        /* 3. 최신 음악 섹션 (4x2 그리드) */
        .container { max-width: 1000px; margin: 80px auto; padding: 0 20px; }
        .chart-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 25px; }
        #itunes-list { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; justify-content: center; }
        .itunes-card { background: #111; padding: 15px; border-radius: 12px; border: 1px solid #222; transition: 0.3s; cursor: pointer; }
        .itunes-card:hover { transform: translateY(-5px); border-color: #ff0055 !important; box-shadow: 0 0 15px rgba(255, 0, 85, 0.3); background: #1a1a1a !important; }

        /* 4. 지역별 섹션 이미지 스타일 (완벽 복구) */
        .location-section { max-width: 1000px; margin: 80px auto; padding: 0 20px; }
        .section-title { color: #ff0055; font-size: 1.5rem; font-weight: bold; margin-bottom: 30px; text-transform: uppercase; letter-spacing: 2px; border-left: 4px solid #ff0055; padding-left: 15px; }
        .location-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 15px; }
        .location-card { position: relative; height: 160px; background-color: #111; background-size: cover; background-position: center; border: 1px solid #222; border-radius: 12px; transition: all 0.3s ease; overflow: hidden; display: flex; flex-direction: column; justify-content: flex-end; padding: 15px; text-decoration: none; cursor: pointer; }
        .location-card::after { content: ''; position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: linear-gradient(to top, rgba(0,0,0,0.9) 10%, rgba(0,0,0,0.1) 90%); z-index: 1; }
        .location-card:hover { border-color: #ff0055; transform: translateY(-5px); box-shadow: 0 5px 15px rgba(255,0,85,0.3); }
        .location-card > * { position: relative; z-index: 2; }
        
        .card-seoul { background-image: url('${pageContext.request.contextPath}/img/location/seoul.jpg'); }
        .card-busan { background-image: url('${pageContext.request.contextPath}/img/location/busan.jpg'); }
        .card-daegu { background-image: url('${pageContext.request.contextPath}/img/location/daegu.jpg'); }
        .card-daejeon { background-image: url('${pageContext.request.contextPath}/img/location/daejeon.jpg'); }
        .card-jeju { background-image: url('${pageContext.request.contextPath}/img/location/jeju.jpg'); }

        .city-name { font-size: 0.8rem; color: #00f2ff; font-weight: bold; margin-bottom: 8px; display: block; }
        .city-top-song { font-size: 0.9rem; font-weight: bold; color: #fff; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .city-top-artist { font-size: 0.75rem; color: #aaa; }

        @media (max-width: 900px) {
            #itunes-list { grid-template-columns: repeat(2, 1fr); }
            .location-grid { grid-template-columns: repeat(2, 1fr); }
            .menu-grid { grid-template-columns: repeat(2, 1fr); }
        }
    </style>
</head>
<body>
<header><jsp:include page="/WEB-INF/views/common/Header.jsp" /></header> 

<main>
    <section class="hero-section">
        <div id="top1-bg"></div>
        <div class="hero-content" onclick="playTopOne()">
            <div class="top1-badge">CURRENT NO.1</div>
            <img id="top1-jacket" src="" alt="Top Music">
            <h1 id="top1-title" style="margin: 0; font-size: 2.2rem; text-shadow: 0 0 15px #ff0055;">Loading...</h1>
            <p id="top1-artist" style="color: #ccc; margin-top: 5px;"></p>
            <div style="margin-top: 15px; color: #ff0055;"><i class="fas fa-play-circle fa-2x"></i></div>
        </div>
    </section>

    <section class="menu-grid">
        <a href="${pageContext.request.contextPath}/music/Index?type=top100" class="menu-card">
            <span style="font-size: 0.7rem; opacity: 0.7;">REAL-TIME</span>
            <span style="font-weight: bold; letter-spacing: 1px;">DAILY</span>
        </a>
        <a href="${pageContext.request.contextPath}/music/Index?type=weekly" class="menu-card">
            <span style="font-size: 0.7rem; opacity: 0.7;">7 DAYS</span>
            <span style="font-weight: bold; letter-spacing: 1px;">WEEKLY</span>
        </a>
        <a href="${pageContext.request.contextPath}/music/Index?type=monthly" class="menu-card">
            <span style="font-size: 0.7rem; opacity: 0.7;">30 DAYS</span>
            <span style="font-weight: bold; letter-spacing: 1px;">MONTHLY</span>
        </a>
        <a href="${pageContext.request.contextPath}/music/Index?type=yearly" class="menu-card">
            <span style="font-size: 0.7rem; opacity: 0.7;">365 DAYS</span>
            <span style="font-weight: bold; letter-spacing: 1px;">YEARLY</span>
        </a>
    </section>

    <section class="container">
        <div class="chart-header">
            <div>
                <h2 style="color: #00f2ff; text-shadow: 0 0 10px rgba(0, 242, 255, 0.5); margin:0;">K-POP Trend</h2>
                <p style="margin: 4px 0 0 0; color: #888; font-size: 0.8rem;">글로벌 트렌드 차트</p>
                
            </div>
            <button onclick="loadItunesMusic()" style="background: none; border: 1px solid #333; color: #888; cursor: pointer; padding: 5px 10px; border-radius: 4px;">REFRESH</button>
        </div>
        <div id="itunes-list"></div>
    </section>    

    <section class="location-section">
        <div class="section-title">Regional Top Hits</div>
        <div class="location-grid">
            <div class="location-card card-seoul" onclick="goRegional('SEOUL')">
                <span class="city-name">SEOUL</span>
                <div id="seoul-title" class="city-top-song">-</div>
                <div id="seoul-artist" class="city-top-artist">-</div>
            </div>
            <div class="location-card card-busan" onclick="goRegional('BUSAN')">
                <span class="city-name">BUSAN</span>
                <div id="busan-title" class="city-top-song">-</div>
                <div id="busan-artist" class="city-top-artist">-</div>
            </div>
            <div class="location-card card-daegu" onclick="goRegional('DAEGU')">
                <span class="city-name">DAEGU</span>
                <div id="daegu-title" class="city-top-song">-</div>
                <div id="daegu-artist" class="city-top-artist">-</div>
            </div>
            <div class="location-card card-daejeon" onclick="goRegional('DAEJEON')">
                <span class="city-name">DAEJEON</span>
                <div id="daejeon-title" class="city-top-song">-</div>
                <div id="daejeon-artist" class="city-top-artist">-</div>
            </div>
            <div class="location-card card-jeju" onclick="goRegional('JEJU')">
                <span class="city-name">JEJU</span>
                <div id="jeju-title" class="city-top-song">-</div>
                <div id="jeju-artist" class="city-top-artist">-</div>
            </div>
        </div>
    </section>
    
<section class="context-recommend-section" style="max-width: 1000px; margin: 80px auto; padding: 0 20px;">
    <div class="section-title">Vibe by Context</div>
    <div class="location-grid">
        <div class="location-card card-weather" onclick="goContext('weather')">
            <span class="city-name">CURRENT WEATHER</span>
            <div id="weather-desc" class="city-top-song">비 오는 날의 선율</div>
            <div class="city-top-artist">지금 날씨에 딱 맞는 곡</div>
        </div>
        
        <div class="location-card card-place" onclick="goContext('cafe')">
            <span class="city-name">PLACE VIBE</span>
            <div id="place-desc" class="city-top-song">카페에서 듣기 좋은</div>
            <div class="city-top-artist">공간을 채우는 감성</div>
        </div>

        <div class="location-card card-time" onclick="goContext('night')">
            <span class="city-name">TIME OF DAY</span>
            <div id="time-desc" class="city-top-song">깊은 밤, 새벽 감성</div>
            <div class="city-top-artist">오늘 하루를 마무리하며</div>
        </div>

        <div class="location-card card-workout" onclick="goContext('workout')">
            <span class="city-name">ACTIVITY</span>
            <div id="activity-desc" class="city-top-song">에너지 업! 비트</div>
            <div class="city-top-artist">운동할 때 힘이 되는 음악</div>
        </div>

        <div class="location-card card-drive" onclick="goContext('drive')">
            <span class="city-name">DRIVE</span>
            <div id="drive-desc" class="city-top-song">끝없이 펼쳐진 도로</div>
            <div class="city-top-artist">드라이브 필수 플레이리스트</div>
        </div>
    </div>
</section>    
    
    
<section class="location-section">
    <div class="section-title">Personalized Mood Tags</div>
    <div class="location-grid">
        <c:forEach var="tag" items="${topTags}" varStatus="status">
            <div class="location-card tag-card-${status.index}" onclick="goTag('${tag}')">
                <span class="city-name">MY TAG #${status.index + 1}</span>
                <div class="city-top-song">${tag} 스타일</div>
                <div class="city-top-artist">당신이 자주 찾는 감성</div>
            </div>
        </c:forEach>
    </div>
</section>





<a href="${pageContext.request.contextPath}/recommendationCategories" 
   style="display: flex; align-items: center; justify-content: space-between; 
          background: linear-gradient(90deg, #4b6cb7 0%, #182848 100%); 
          color: white; padding: 20px; border-radius: 12px; text-decoration: none; margin: 20px 0;">
    <div>
        <h4 style="margin: 0; font-size: 1.2rem;">어떤 음악을 들을지 고민인가요? 🤔</h4>
        <p style="margin: 5px 0 0 0; opacity: 0.8;">지금 기분과 날씨에 딱 맞는 곡을 추천해 드려요.</p>
    </div>
    <span style="background: rgba(255,255,255,0.2); padding: 8px 15px; border-radius: 20px; font-weight: bold;">
        보러가기 >
    </span>
</a>


</main>

<footer><jsp:include page="/WEB-INF/views/common/Footer.jsp" /></footer>

<script>
const contextPath = '${pageContext.request.contextPath}';
const FALLBACK_IMG = 'https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png';
let cachedTopOne = null;
console.log("현재 MusicApp 상태:", window.MusicApp);
// 1. MusicApp 연동 재생 함수
function playLatestYouTube(title, artist, imgUrl) {
    // 만약 window.MusicApp이 없으면 여기서 강제로 다시 체크
    if (!window.MusicApp) {
        console.error("MusicApp 객체가 메모리에 없습니다. 파일 로드 상태를 확인하세요.");
        return;
    }
    window.MusicApp.playLatestYouTube(title, artist, imgUrl);
}

function playTopOne() {
    if (cachedTopOne) playLatestYouTube(cachedTopOne.TITLE, cachedTopOne.ARTIST, cachedTopOne.ALBUM_IMG);
}

function toHighResArtwork(url) {
    if (!url) return FALLBACK_IMG;
    return String(url).replace(/100x100bb/g, '600x600bb').replace(/100x100/g, '600x600');
}

// 2. 데이터 로딩 로직
function loadTopOne() {
    $.get(contextPath + '/api/music/top100', function(data) {
        if (data && data.length > 0) {
            cachedTopOne = data[0];
            const img = toHighResArtwork(cachedTopOne.ALBUM_IMG);
            $('#top1-bg').css('background-image', 'url(' + img + ')');
            $('#top1-jacket').attr('src', img);
            $('#top1-title').text(cachedTopOne.TITLE);
            $('#top1-artist').text(cachedTopOne.ARTIST);
        }
    });
}

function loadRegionalPreviews() {
    const cities = ['SEOUL', 'BUSAN', 'DAEGU', 'DAEJEON', 'JEJU'];
    cities.forEach(city => {
        $.get(contextPath + '/api/music/regional', { city: city }, function(data) {
            if (data && data.length > 0) {
                const idPrefix = city.toLowerCase();
                $('#' + idPrefix + '-title').text(data[0].TITLE || '-');
                $('#' + idPrefix + '-artist').text(data[0].ARTIST || '-');
            }
        });
    });
}

function loadNewReleases() {
    $.get(contextPath + '/api/music/rss/new-releases', function(data) {
        const $list = $('#itunes-list');
        $list.empty();

        data.forEach(m => {
            const img = toHighResArtwork(m.ALBUM_IMG);
            $list.append(`
                <div class="itunes-card" onclick="playLatestYouTube('${m.TITLE}', '${m.ARTIST}', '${img}')">
                    <img src="${img}" style="width:100%; border-radius:8px;">
                    <div style="margin-top:8px; font-weight:bold;">${m.TITLE}</div>
                    <div style="font-size:0.8rem; color:#00f2ff;">${m.ARTIST}</div>
                </div>
            `);
        });
    });
}

function goRegional(city) { location.href = contextPath + '/music/regional?city=' + city; }

$(document).ready(function() {
    setTimeout(function() {
        if (window.MusicApp) {
            MusicApp.init(${loginUser.uNo != null ? loginUser.uNo : 0});
        }
        loadTopOne();        // 히어로 (top100 OK)
        loadNewReleases();   // 🔥 NEW RELEASES
        loadRegionalPreviews();
    }, 100);
});

function goTag(tagName) {
    // 기존에 만드신 추천 리스트 페이지로 이동
    location.href = "${pageContext.request.contextPath}/music/recommendationList?tagName=" + encodeURIComponent(tagName);
}
</script>
</body>
</html>