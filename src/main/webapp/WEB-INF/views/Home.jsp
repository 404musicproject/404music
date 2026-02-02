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

		/* TOP 10 섹션 스타일 (2열 그리드 적용) */
		.top10-container { max-width: 1000px; margin: 40px auto; padding: 0 20px; }
		.top10-wrapper { 
		    background: #0a0a0a; 
		    border: 1px solid #333; 
		    border-radius: 12px; 
		    padding: 10px; 
		}
		/* 중요: 2열 배치를 위한 그리드 설정 */
		.top10-list { 
		    display: grid; 
		    grid-template-columns: 1fr 1fr; 
		    gap: 10px 20px; 
		}
		
		.top10-item { 
		    display: flex; 
		    align-items: center; 
		    padding: 10px; 
		    border-radius: 8px; 
		    transition: 0.2s; 
		    cursor: pointer;
		    background: rgba(255, 255, 255, 0.03);
		}
		.top10-item:hover { background: rgba(255, 0, 85, 0.15); transform: translateX(5px); }
		
		.top10-rank { 
		    font-size: 1.2rem; 
		    font-weight: 900; 
		    color: #ff0055; 
		    width: 30px; 
		    text-align: center; 
		    font-style: italic;
		    margin-right: 15px;
		}
		.top10-img { width: 50px; height: 50px; border-radius: 4px; object-fit: cover; margin-right: 15px; }
		.top10-info { flex-grow: 1; min-width: 0; overflow: hidden; }
		.top10-title { font-weight: bold; font-size: 1rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
		.top10-artist { font-size: 0.8rem; color: #888; }
		.top10-play { color: #ff0055; font-size: 1.2rem; padding: 0 10px; }

        /* 2. 메뉴 그리드 */
        .menu-grid { max-width: 1000px; margin: -50px auto 50px; display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; padding: 0 20px; position: relative; z-index: 10; }
        .menu-card { background: #0a0a0a; border: 1px solid #00f2ff; padding: 30px 10px; text-align: center; text-decoration: none; color: #00f2ff; transition: all 0.3s; border-radius: 8px; display: flex; flex-direction: column; gap: 10px; cursor: pointer; }
        .menu-card:hover { background: rgba(0, 242, 255, 0.1); transform: translateY(-10px); box-shadow: 0 0 20px rgba(0, 242, 255, 0.4); color: #fff; border-color: #fff; }
        
        /* 3. 최신 음악 섹션 */
        .container { max-width: 1000px; margin: 80px auto; padding: 0 20px; }
        .chart-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 25px; }
        #itunes-list { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; justify-content: center; }
        .itunes-card { background: #111; padding: 15px; border-radius: 12px; border: 1px solid #222; transition: 0.3s; cursor: pointer; }
        .itunes-card:hover { transform: translateY(-5px); border-color: #ff0055 !important; box-shadow: 0 0 15px rgba(255, 0, 85, 0.3); background: #1a1a1a !important; }

        /* 4. 지역별 섹션 이미지 스타일 */
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
            .top10-list { grid-template-columns: 1fr; } /* 모바일은 1열 */
        }
        
        /* 태그 이미지 (생략 가능하면 유지) */
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
		    <img id="top1-jacket" src="${pageContext.request.contextPath}/img/location/default.jpg" alt="Top Music">
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
	
	<section class="top10-container">
	    <div class="section-title">Real-time Top 10</div>
	    <div class="top10-wrapper">
	        <div id="top10-list" class="top10-list">
                </div>
	    </div>
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
    
<c:if test="${not empty loginUser}">
<section class="location-section">
    <div class="section-title">📍 NOW & HERE</div>
    <div class="location-grid" id="context-list">
        </div>
</section>
    
</c:if>

<c:if test="${not empty loginUser}">
<section class="location-section">
    <div class="section-title">✨ FOR YOUR MOOD</div>
    <div class="location-grid" id="personalized-list">
        </div>
</section>
</c:if>


</main>

<footer><jsp:include page="/WEB-INF/views/common/Footer.jsp" /></footer>

<script>
const contextPath = '${pageContext.request.contextPath}';
const FALLBACK_IMG = 'https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png';
let cachedTopOne = null;

const tagNoMap = {
  "행복한 기분": 1, "파티": 2, "더운 여름": 3, "자신감 뿜뿜": 4, "운동": 5,
  "스트레스 해소": 6, "슬픔": 7, "비 오는 날": 8, "새벽 감성": 9, "로맨틱": 10,
  "휴식": 11, "요리할 때": 12, "집중": 13, "맑음": 14, "흐림": 15,
  "눈 오는 날": 16, "바다": 17, "산/등산": 18, "카페/작업": 19, "헬스장": 20, "공원/피크닉": 21
};

function toHighResArtwork(url) {
    if (!url) return FALLBACK_IMG;
    return String(url).replace(/100x100bb/g, '600x600bb').replace(/100x100/g, '600x600');
}

function goTag(tagName) {
    // tagList를 수집해서 넘길 필요 없이, 클릭한 태그 이름 하나만 전송합니다.
    if(!tagName || tagName === '-') return;
    
    // ' 스타일' 글자가 붙어있다면 제거해서 순수 태그명만 전달
    const cleanTagName = tagName.replace(' 스타일', '').trim();
    
    location.href = contextPath + "/music/recommendationList?tagName=" + encodeURIComponent(cleanTagName);
}

function goRegional(city) { 
    location.href = contextPath + '/music/regional?city=' + city; 
}

//클릭 시 히어로 변경 + MusicApp을 통한 재생 및 로그 기록
function changeHeroAndPlay(title, artist, imgUrl) {
    // 1. 히어로 섹션 비주얼 업데이트 (기존 동일)
    const highImg = toHighResArtwork(imgUrl);
    $('#top1-bg').css('background-image', 'url(' + highImg + ')');
    $('#top1-jacket').attr('src', highImg);
    $('#top1-title').text(title);
    $('#top1-artist').text(artist);

    // 2. MusicApp 서비스 호출 (이 함수가 내부적으로 로그/위치/날씨를 다 처리함)
    if (window.MusicApp && typeof window.MusicApp.playLatestYouTube === 'function') {
        // 이미 music-service.js에 정의된 이 함수가 
        // 1) 유튜브 검색 -> 2) 상세정보 업데이트 -> 3) 재생로그(sendPlayLog)를 순서대로 실행합니다.
        window.MusicApp.playLatestYouTube(title, artist, imgUrl);
    } else {
        console.error("MusicApp을 찾을 수 없습니다. js파일 로드 확인 필요");
    }
}

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
    if (cachedTopOne) {
        changeHeroAndPlay(cachedTopOne.TITLE || cachedTopOne.m_title, cachedTopOne.ARTIST || cachedTopOne.a_name, cachedTopOne.ALBUM_IMG || cachedTopOne.B_IMAGE);
    }
}

function loadTop10() {
    var userNo = "${loginUser != null ? loginUser.UNo : 0}";

    $.get(contextPath + '/api/music/top100', { u_no: userNo }, function(data) {
        if (data && data.length > 0) {
            // --- [1] 초기 Hero 설정 (1위곡) ---
            cachedTopOne = data[0];
            var heroImgRaw = cachedTopOne.ALBUM_IMG || cachedTopOne.B_IMAGE || cachedTopOne.album_img || FALLBACK_IMG;
            var heroImg = toHighResArtwork(heroImgRaw);

            $('#top1-bg').css('background-image', 'url(' + heroImg + ')');
            $('#top1-jacket').attr('src', heroImg);
            $('#top1-title').text(cachedTopOne.TITLE || cachedTopOne.m_title);
            $('#top1-artist').text(cachedTopOne.ARTIST || cachedTopOne.a_name);

            // --- [2] 리스트 생성 (2열 그리드) ---
            var top10Html = '';
            var displayData = data.slice(0, 10);
            
            for (var i = 0; i < displayData.length; i++) {
                var m = displayData[i];
                var title = (m.TITLE || m.m_title || 'Unknown').replace(/'/g, "\\'");
                var artist = (m.ARTIST || m.a_name || 'Unknown').replace(/'/g, "\\'");
                var imgRaw = m.ALBUM_IMG || m.B_IMAGE || m.album_img || FALLBACK_IMG;
                var img = toHighResArtwork(imgRaw);
                
                // 클릭 시 changeHeroAndPlay 호출
                top10Html += '<div class="top10-item" onclick="changeHeroAndPlay(\'' + title + '\', \'' + artist + '\', \'' + img + '\')">';
                top10Html += '  <div class="top10-rank">' + (i + 1) + '</div>';
                top10Html += '  <img src="' + img + '" class="top10-img" onerror="this.src=\'' + FALLBACK_IMG + '\'">';
                top10Html += '  <div class="top10-info">';
                top10Html += '    <div class="top10-title">' + (m.TITLE || m.m_title) + '</div>';
                top10Html += '    <div class="top10-artist">' + (m.ARTIST || m.a_name) + '</div>';
                top10Html += '  </div>';
                top10Html += '  <div class="top10-play"><i class="fa-solid fa-play"></i></div>';
                top10Html += '</div>';
            }
            $('#top10-list').html(top10Html);
        }
    });
}

function loadRegionalPreviews() {
    const cities = ['SEOUL', 'BUSAN', 'DAEGU', 'DAEJEON', 'JEJU'];
    cities.forEach(city => {
        $.get(contextPath + '/api/music/regional', { city: city }, function(data) {
            if (data && data.length > 0) {
                const idPrefix = city.toLowerCase();
                $('#' + idPrefix + '-title').text(data[0].TITLE || data[0].m_title || '-');
                $('#' + idPrefix + '-artist').text(data[0].ARTIST || data[0].a_name || '-');
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
            const img = m.ALBUM_IMG || FALLBACK_IMG;
            html += '<div class="itunes-card" onclick="changeHeroAndPlay(\'' + t + '\', \'' + a + '\', \'' + img + '\')">'
                + '  <img src="' + toHighResArtwork(img) + '" style="width:100%; aspect-ratio:1/1; object-fit:cover; border-radius:8px;">'
                + '  <div class="city-top-song" style="margin-top:10px;">' + m.TITLE + '</div>'
                + '  <div class="city-top-artist" style="color:#00f2ff;">' + m.ARTIST + '</div>'
                + '</div>';
        });
        $('#itunes-list').html(html);
    });
}

function drawTagCards() {
    // 1. 상황/장소 데이터 수집
    const rawContextTags = [];
    <c:forEach var="ct" items="${homeContextTags}">
        rawContextTags.push("${ct}");
    </c:forEach>

    const locationTags = ["바다", "산/등산", "카페/작업", "헬스장", "공원/피크닉"];
    const weatherTags = ["맑음", "흐림", "비 오는 날", "눈 오는 날", "더운 여름"];

    // 📍 NOW & HERE 리스트 생성 (날씨 카드 1개 + 장소 카드들)
    let contextHtml = '<div id="geo-weather-card" class="location-card" style="background-image:url(\'${pageContext.request.contextPath}/img/location/default.jpg\')">'
                    + '  <span class="city-name" id="geo-city">LOCATION</span>'
                    + '  <div class="city-top-song" id="geo-weather-title">날씨 확인 중...</div>'
                    + '  <div class="city-top-artist" id="geo-weather-desc">위치 정보를 불러오는 중</div>'
                    + '</div>';
    
    // 장소 태그들만 필터링해서 추가 (최대 4개까지만 추가해서 총 5개 맞춤)
    let addedCount = 0;
    rawContextTags.forEach(name => {
        if (locationTags.indexOf(name) !== -1 && addedCount < 4) {
            const no = tagNoMap[name] || 19;
            contextHtml += '<div class="location-card tag-' + no + '" onclick="goTag(\'' + name + '\')">'
                         + '  <span class="city-name">NEARBY PLACE</span>'
                         + '  <div class="city-top-song">' + name + '</div>'
                         + '  <div class="city-top-artist">지금 위치와 어울리는 추천</div>'
                         + '</div>';
            addedCount++;
        }
    });
    $('#context-list').html(contextHtml);

 // 2. 취향/무드 데이터 수집
    const moodTags = [];
    <c:forEach var="mt" items="${homeMoodTags}">
        moodTags.push("${mt}");
    </c:forEach>

    // ✨ FOR YOUR MOOD 리스트 생성 (상위 5개로 제한)
    let personalHtml = '';
    
    // filter나 slice를 써도 되지만, forEach의 인덱스를 활용하는게 가장 간단합니다.
    moodTags.forEach((name, idx) => {
        if (idx < 5) { // 0, 1, 2, 3, 4번 인덱스만 출력 (총 5개)
            const no = tagNoMap[name] || 9;
            personalHtml += '<div class="location-card tag-' + no + '" onclick="goTag(\'' + name + '\')">'
                          + '  <span class="city-name">MY MOOD #' + (idx + 1) + '</span>'
                          + '  <div class="city-top-song">' + name + '</div>'
                          + '  <div class="city-top-artist">당신을 위한 맞춤 추천</div>'
                          + '</div>';
        }
    });
    
    $('#personalized-list').html(personalHtml);

    // 날씨 카드 업데이트 실행
    renderContextWeather();
}

function renderContextWeather() {
    if (!window.MusicApp) return;
    window.MusicApp.getWeatherData(function(data) {
        if (!data) return;
        const city = data.name.toUpperCase();
        const weatherId = data.weather[0].id;
        let tagName = "맑음";
        let bgImg = "${pageContext.request.contextPath}/img/Tag/14.png";

        if (weatherId < 600) { tagName = "비 오는 날"; bgImg = "${pageContext.request.contextPath}/img/Tag/8.png"; }
        else if (weatherId < 700) { tagName = "눈 오는 날"; bgImg = "${pageContext.request.contextPath}/img/Tag/16.png"; }
        else if (weatherId > 800) { tagName = "흐림"; bgImg = "${pageContext.request.contextPath}/img/Tag/15.png"; }

        $('#geo-city').text(city);
        $('#geo-weather-title').text(tagName);
        $('#geo-weather-desc').text(Math.round(data.main.temp) + "°C, 현재 날씨 맞춤형");
        $('#geo-weather-card').css('background-image', 'url(' + bgImg + ')').attr('onclick', "goTag('" + tagName + "')");
    });
}

$(document).ready(function() {
    const uNoStr = "${loginUser.UNo}"; // 필드명 확인 필요 (UNo 인지 uNo인지)
    const uNo = uNoStr !== "" ? parseInt(uNoStr) : 0;
    
    setTimeout(function() {
        if (window.MusicApp) window.MusicApp.init(uNo);
        loadTop10();
        loadRegionalPreviews();
        loadItunesMusic();
        drawTagCards(); 
    }, 200);
});
</script>
</body>
</html>