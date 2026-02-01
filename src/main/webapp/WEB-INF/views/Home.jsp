<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" buffer="16kb" autoFlush="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
        .location-section, .Weather-section, .activity-section { max-width: 1000px; margin: 80px auto; padding: 0 20px; }
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
        
         /* 번호별 태그 이미지 등록 */
		.tag-1 { background-image: url('${pageContext.request.contextPath}/img/Tag/1.png'); }
		.tag-2 { background-image: url('${pageContext.request.contextPath}/img/Tag/2.png'); }
		.tag-3 { background-image: url('${pageContext.request.contextPath}/img/Tag/3.png'); }
		.tag-4 { background-image: url('${pageContext.request.contextPath}/img/Tag/4.png'); }
		.tag-5 { background-image: url('${pageContext.request.contextPath}/img/Tag/5.png'); }
		.tag-6 { background-image: url('${pageContext.request.contextPath}/img/Tag/6.png'); }
		.tag-7 { background-image: url('${pageContext.request.contextPath}/img/Tag/7.png'); }
		.tag-8 { background-image: url('${pageContext.request.contextPath}/img/Tag/8.png'); }
		.tag-9 { background-image: url('${pageContext.request.contextPath}/img/Tag/9.png'); }
		.tag-10 { background-image: url('${pageContext.request.contextPath}/img/Tag/10.png'); }
		.tag-11 { background-image: url('${pageContext.request.contextPath}/img/Tag/11.png'); }
		.tag-12 { background-image: url('${pageContext.request.contextPath}/img/Tag/12.png'); }
		.tag-13 { background-image: url('${pageContext.request.contextPath}/img/Tag/13.png'); }
		.tag-14 { background-image: url('${pageContext.request.contextPath}/img/Tag/14.png'); }
		.tag-15 { background-image: url('${pageContext.request.contextPath}/img/Tag/15.png'); }
		.tag-16 { background-image: url('${pageContext.request.contextPath}/img/Tag/16.png'); }
		.tag-17 { background-image: url('${pageContext.request.contextPath}/img/Tag/17.png'); }
		.tag-18 { background-image: url('${pageContext.request.contextPath}/img/Tag/18.png'); }
		.tag-19 { background-image: url('${pageContext.request.contextPath}/img/Tag/19.png'); }
		.tag-20 { background-image: url('${pageContext.request.contextPath}/img/Tag/20.png'); }
		.tag-21 { background-image: url('${pageContext.request.contextPath}/img/Tag/21.png'); }
        
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
                <h2 style="color: #00f2ff; text-shadow: 0 0 10px rgba(0, 242, 255, 0.5); margin:0;">NEW RELEASES</h2>
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
    
<%-- 섹션 4: Today's Context --%>
<section class="Weather-section">
    <div class="section-title">Today's Context</div>
    <div class="location-grid" id="context-list">
        </div>
</section>

<%-- 섹션 5: Personalized Mood Tags --%>
<section class="activity-section">
    <div class="section-title">Personalized Mood Tags</div>
    <div class="location-grid" id="personalized-list">
        </div>
</section>
</main>

<footer><jsp:include page="/WEB-INF/views/common/Footer.jsp" /></footer>

<script>
const contextPath = '${pageContext.request.contextPath}';
const FALLBACK_IMG = 'https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png';
let cachedTopOne = null;

// 태그 이름 -> 이미지 번호 매핑
const tagNoMap = {
  "행복한 기분": 1, "파티": 2, "더운 여름": 3, "자신감 뿜뿜": 4, "운동": 5,
  "스트레스 해소": 6, "슬픔": 7, "비 오는 날": 8, "새벽 감성": 9, "로맨틱": 10,
  "휴식": 11, "요리할 때": 12, "집중": 13, "맑음": 14, "흐림": 15,
  "눈 오는 날": 16, "바다": 17, "산/등산": 18, "카페/작업": 19, "헬스장": 20, "공원/피크닉": 21
};

// 1. 유틸리티 함수
function toHighResArtwork(url) {
    if (!url) return FALLBACK_IMG;
    return String(url).replace(/100x100bb/g, '600x600bb').replace(/100x100/g, '600x600');
}

function goTag(tagName) {
    location.href = contextPath + "/music/recommendationList?tagName=" + encodeURIComponent(tagName);
}

function goRegional(city) { 
    location.href = contextPath + '/music/regional?city=' + city; 
}

// 2. 음악 재생 및 로그 기록
function playLatestYouTube(title, artist, imgUrl) {
    if (!window.MusicApp) return;

    $.ajax({
        url: contextPath + '/api/music/logHistoryAuto',
        type: 'POST',
        data: { title: title, artist: artist },
        success: function(res) { console.log("로그 기록 완료"); }
    });

    window.MusicApp.playLatestYouTube(title, artist, imgUrl);
}

function playTopOne() {
    if (cachedTopOne) playLatestYouTube(cachedTopOne.TITLE, cachedTopOne.ARTIST, cachedTopOne.ALBUM_IMG);
}

// 3. 데이터 로딩 함수들
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

function loadItunesMusic() {
    $.get(contextPath + "/api/music/rss/most-played", { limit: 8 }, function(data) {
        let html = '';
        data.forEach(function(m) {
            const t = (m.TITLE || 'Unknown').replace(/'/g, "\\'");
            const a = (m.ARTIST || 'Unknown').replace(/'/g, "\\'");
            html += '<div class="itunes-card" onclick="playLatestYouTube(\'' + t + '\', \'' + a + '\', \'' + m.ALBUM_IMG + '\')">'
                + '  <img src="' + toHighResArtwork(m.ALBUM_IMG) + '" style="width:100%; aspect-ratio:1/1; object-fit:cover; border-radius:8px;">'
                + '  <div class="city-top-song" style="margin-top:10px;">' + m.TITLE + '</div>'
                + '  <div class="city-top-artist" style="color:#00f2ff;">' + m.ARTIST + '</div>'
                + '</div>';
        });
        $('#itunes-list').html(html);
    });
}

// 4. 태그 및 날씨 렌더링
function drawTagCards() {
    // 1. 장소 태그 (안전하게 배열 생성)
    const placeTags = [];
    <c:if test="${not empty placeTags}">
        <c:forEach var="pt" items="${placeTags}">
            placeTags.push("${pt}");
        </c:forEach>
    </c:if>

    let contextHtml = '<div id="geo-weather-card" class="location-card" style="background-image:url(\'${pageContext.request.contextPath}/img/location/default.jpg\')">'
                    + '  <span class="city-name" id="geo-city">LOCATION</span>'
                    + '  <div class="city-top-song" id="geo-weather-title">날씨 확인 중...</div>'
                    + '  <div class="city-top-artist" id="geo-weather-desc">데이터를 불러오고 있습니다.</div>'
                    + '</div>';
    
    // 데이터가 있을 때만 forEach 실행
    if (placeTags.length > 0) {
        placeTags.forEach(name => {
            const no = tagNoMap[name] || 11;
            contextHtml += '<div class="location-card tag-' + no + '" onclick="goTag(\'' + name + '\')">'
                         + '  <span class="city-name">NEARBY PLACE</span>'
                         + '  <div class="city-top-song">' + name + '</div>'
                         + '  <div class="city-top-artist">지금 위치에 어울리는 추천</div>'
                         + '</div>';
        });
    }
    $('#context-list').html(contextHtml);

    // 2. 개인화 태그 (안전하게 배열 생성)
    const topTags = [];
    <c:if test="${not empty topTags}">
        <c:forEach var="tt" items="${topTags}">
            topTags.push("${tt}");
        </c:forEach>
    </c:if>

    let personalHtml = '';
    if (topTags.length > 0) {
        topTags.forEach((name, idx) => {
            const no = tagNoMap[name] || 11;
            personalHtml += '<div class="location-card tag-' + no + '" onclick="goTag(\'' + name + '\')">'
                          + '  <span class="city-name">MY TAG #' + (idx + 1) + '</span>'
                          + '  <div class="city-top-song">' + name + ' 스타일</div>'
                          + '  <div class="city-top-artist">당신이 자주 찾는 감성</div>'
                          + '</div>';
        });
    }
    $('#personalized-list').html(personalHtml);
    
    renderContextWeather();
}

function renderContextWeather() {
    if (!window.MusicApp) return;
    window.MusicApp.getWeatherData(function(data) {
        if (!data) return;
        const city = data.name.toUpperCase();
        const weatherId = data.weather[0].id;
        let tagName = "맑음";
        let bgImg = "${pageContext.request.contextPath}/img/weather/sunny.jpg";

        if (weatherId < 600) { tagName = "비 오는 날"; bgImg = "${pageContext.request.contextPath}/img/weather/rainy.jpg"; }
        else if (weatherId < 700) { tagName = "눈 오는 날"; bgImg = "${pageContext.request.contextPath}/img/weather/snowy.jpg"; }
        else if (weatherId > 800) { tagName = "흐림"; bgImg = "${pageContext.request.contextPath}/img/weather/cloudy.jpg"; }

        $('#geo-city').text(city);
        $('#geo-weather-title').text(tagName);
        $('#geo-weather-desc').text(Math.round(data.main.temp) + "°C, 현재 날씨 맞춤형");
        $('#geo-weather-card').css('background-image', 'url(' + bgImg + ')').attr('onclick', "goTag('" + tagName + "')");
    });
}

// [통합] 초기화 및 실행
$(document).ready(function() {
    const uNo = "${loginUser.uNo}" != "" ? parseInt("${loginUser.uNo}") : 0;
    const urlParams = new URLSearchParams(window.location.search);
    
    // 로그인 에러 체크 (이전 모달 연동용)
    if (urlParams.has('loginError')) {
        if(typeof openLoginModal === 'function') openLoginModal();
        alert("아이디 또는 비밀번호가 틀렸습니다.");
    }

    setTimeout(function() {
        if (window.MusicApp) {
            window.MusicApp.init(uNo);
        }
        loadTopOne();
        loadRegionalPreviews();
        loadItunesMusic();
        drawTagCards(); 
    }, 200);
});
</script>
</script>
</body>
</html>