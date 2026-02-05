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
		    /* 열을 2개로 고정 */
		    grid-template-columns: 1fr 1fr; 
		    /* 행을 5개로 고정 (반드시 지정해야 세로로 흐름) */
		    grid-template-rows: repeat(5, auto); 
		    /* 데이터가 위에서 아래로(세로) 먼저 채워지도록 설정 */
		    grid-auto-flow: column; 
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
		.top10-info { flex-grow: 1; min-width: 0; overflow: hidden; display: flex; flex-direction: column; justify-content: center;}
		.top10-title { font-weight: bold; font-size: 1rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; width: 100%; }
		.top10-artist { font-size: 0.8rem; color: #888; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; width: 100%; }
		.top10-play { color: #ff0055; font-size: 1.2rem; padding: 0 10px; }

        /* 2. 메뉴 그리드 */
        .menu-grid { max-width: 1000px; margin: -50px auto 50px; display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; padding: 0 20px; position: relative; z-index: 10; }
        .menu-card { background: #0a0a0a; border: 1px solid #00f2ff; padding: 30px 10px; text-align: center; text-decoration: none; color: #00f2ff; transition: all 0.3s; border-radius: 8px; display: flex; flex-direction: column; gap: 10px; cursor: pointer;z-index: 20; user-select: none; }
        .menu-card:hover { background: rgba(0, 242, 255, 0.1); transform: translateY(-10px); box-shadow: 0 0 20px rgba(0, 242, 255, 0.4); color: #fff; border-color: #fff; }
        .menu-card * {pointer-events: none;}
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
            .top10-list { 
		        display: grid;
		        grid-template-columns: 1fr; 
		        grid-template-rows: none;
		        grid-auto-flow: row; /* 모바일은 다시 순서대로 아래로 */
		    }
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
		
		/* 팝업 오버레이 스타일 추가 */
		.custom-popup-overlay {
		    position: fixed;
		    top: 0; left: 0; width: 100%; height: 100%;
		    background: rgba(0, 0, 0, 0.8);
		    display: flex; align-items: center; justify-content: center;
		    z-index: 10000;
		}
		.custom-popup-content {
		    background: #1a1a1a;
		    border: 2px solid #ff0055;
		    padding: 20px;
		    border-radius: 12px;
		    width: 400px;
		    color: #fff;
		    box-shadow: 0 0 20px rgba(255, 0, 85, 0.5);
		}
		.popup-footer {
		    margin-top: 15px;
		    display: flex;
		    justify-content: space-between;
		    align-items: center;
		}
		.popup-footer button {
		    background: #ff0055; border: none; color: #fff;
		    padding: 5px 15px; cursor: pointer; border-radius: 4px;
		}
		
		
/* 5. Kibana 프로모션 섹션 스타일 (바이올렛 & 핑크 테마) */
.Kibana {
    display: flex;
    justify-content: space-between;
    align-items: center;
    max-width: 1000px;
    margin: 80px auto; /* 간격 살짝 넓힘 */
    padding: 40px;
    /* 세련된 보라색에서 핑크로 이어지는 그라데이션 */
    background: linear-gradient(135deg, #6e00ff 0%, #ff0055 100%);
    border-radius: 20px;
    text-decoration: none;
    color: #fff; /* 밝은 배경이 아니므로 글자를 흰색으로 변경 */
    transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    position: relative;
    overflow: hidden;
    box-shadow: 0 10px 30px rgba(110, 0, 255, 0.3);
}

.Kibana:hover {
    transform: translateY(-5px) scale(1.01);
    box-shadow: 0 20px 40px rgba(255, 0, 85, 0.4);
}

/* 내부 광택 효과 */
.Kibana::before {
    content: "";
    position: absolute;
    top: -50%;
    left: -20%;
    width: 140%;
    height: 200%;
    background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, transparent 60%);
    pointer-events: none;
}

.Kibana h4 {
    margin: 0;
    font-size: 1.8rem;
    font-weight: 900;
    letter-spacing: -1px;
    color: #fff;
    text-shadow: 0 2px 10px rgba(0,0,0,0.2);
}

.Kibana p {
    margin: 10px 0 0 0;
    opacity: 0.9;
    font-size: 1.1rem;
    font-weight: 400;
    color: rgba(255, 255, 255, 0.8);
}

.Kibana span {
    background: rgba(0, 0, 0, 0.3); /* 반투명 블랙으로 고급스럽게 */
    color: #fff;
    padding: 15px 35px;
    border: 1px solid rgba(255, 255, 255, 0.3);
    border-radius: 40px;
    font-size: 1rem;
    font-weight: bold;
    transition: 0.3s;
    white-space: nowrap;
    backdrop-filter: blur(5px); /* 배경 흐림 효과 추가 */
}

.Kibana:hover span {
    background: #fff;
    color: #ff0055;
    border-color: #fff;
}

/* 모바일 대응 */
@media (max-width: 768px) {
    .Kibana {
        flex-direction: column;
        text-align: center;
        gap: 25px;
        padding: 40px 20px;
        margin: 40px 20px;
    }
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
		    <img id="top1-jacket" src="https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png" alt="Top Music">
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

    <section class="container">
        <div class="chart-header">
            <div>
                <h2 style="color: #00f2ff; text-shadow: 0 0 10px rgba(0, 242, 255, 0.5); margin:0;">K-POP TREND</h2>
                <p style="margin: 4px 0 0 0; color: #888; font-size: 0.8rem;">K-POP 트렌드 차트</p>
            </div>
            <button onclick="loadItunesMusic()" style="background: none; border: 1px solid #333; color: #888; cursor: pointer; padding: 5px 10px; border-radius: 4px;">REFRESH</button>
        </div>
        <div id="itunes-list"></div>
    </section>    

<section>
	    <a href="${pageContext.request.contextPath}/user/Kibana" class="Kibana">
        <div>
            <h4 style="margin: 0; font-size: 1.6rem; letter-spacing: -1px;">404 분석 데스크🤔</h4>
            <p style="margin: 10px 0 0 0; opacity: 0.8; font-size: 1.1rem;">404 Found</p>
        </div>
        <span style="background: #000; color: #fff; padding: 15px 30px; border-radius: 40px; font-size: 1rem;">
            분석 차트 보러가기 >
        </span>
    </a>
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
    if(!tagName || tagName === '-') return;
    const cleanTagName = tagName.replace(' 스타일', '').trim();
    location.href = contextPath + "/music/recommendationList?tagName=" + encodeURIComponent(cleanTagName);
}

function goRegional(city) { 
    location.href = contextPath + '/music/regional?city=' + city; 
}

function changeHeroAndPlay(title, artist, imgUrl) {
    // 1. [UI 변경] 즉시 화면 정보를 바꿉니다.
    const highImg = toHighResArtwork(imgUrl);
    $('#top1-bg').css('background-image', 'url(' + highImg + ')');
    $('#top1-jacket').attr('src', highImg);
    $('#top1-title').text(title);
    $('#top1-artist').text(artist);

    // 2. [핵심: 재생 실행] 이 코드가 있어야 노래가 나옵니다!
    if (window.MusicApp && typeof window.MusicApp.playLatestYouTube === 'function') {
        window.MusicApp.playLatestYouTube(title, artist, imgUrl);
    } else {
        console.error("MusicApp이 로드되지 않았거나 playLatestYouTube 함수를 찾을 수 없습니다.");
    }

    // 3. [로그 전송] 재생과 별개로 백그라운드에서 실행 (비동기)
    const userNo = "${loginUser != null ? loginUser.UNo : 0}";
    if (userNo !== "0") {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(position) {
                // 좌표 성공 시 전송
                $.post(contextPath + '/api/music/log', {
                    title: title,
                    artist: artist,
                    albumImg: imgUrl,
                    h_lat: position.coords.latitude,
                    h_lon: position.coords.longitude
                });
            }, function(error) {
                // 좌표 실패 시(권한 거부 등) 기본 정보만 전송
                $.post(contextPath + '/api/music/log', {
                    title: title,
                    artist: artist,
                    albumImg: imgUrl
                });
            }, { timeout: 3000 }); // 3초 대기 후 안되면 실패 처리
        } else {
            // Geolocation 지원 안 하는 브라우저
            $.post(contextPath + '/api/music/log', {
                title: title,
                artist: artist,
                albumImg: imgUrl
            });
        }
    }
}

function playTopOne() {
    if (cachedTopOne) {
        changeHeroAndPlay(cachedTopOne.TITLE || cachedTopOne.m_title, cachedTopOne.ARTIST || cachedTopOne.a_name, cachedTopOne.ALBUM_IMG || cachedTopOne.B_IMAGE);
    }
}

function loadTop10() {
    var userNo = "${loginUser != null ? loginUser.UNo : 0}";
    var $listContainer = $('#top10-list');

    $.get(contextPath + '/api/music/top100', { u_no: userNo, _t: Date.now() }, function(res) {
        let list = Array.isArray(res) ? res : (res.list || res.data || []);
        
        if (list.length === 0) {
            $listContainer.html('<p style="grid-column:1/-1; text-align:center;">데이터가 없습니다.</p>');
            return;
        }

        let html = '';
        list.forEach(function(item, i) {
            if (i >= 10) return;

            var title = (item.TITLE || item.m_title || 'Unknown');
            var artist = (item.ARTIST || item.a_name || 'Unknown');
            var rawImg = item.ALBUM_IMG || item.b_image || FALLBACK_IMG;
            var img = toHighResArtwork(rawImg);
            var rank = i + 1;

            var sTitle = title.replace(/'/g, "\\'");
            var sArtist = artist.replace(/'/g, "\\'");

            if (i === 0) {
                $('#top1-bg').css('background-image', 'url(' + img + ')');
                $('#top1-jacket').attr('src', img);
                $('#top1-title').text(title);
                $('#top1-artist').text(artist);
                cachedTopOne = item;
            }

            html += '<div class="top10-item" onclick="changeHeroAndPlay(\'' + sTitle + '\', \'' + sArtist + '\', \'' + img + '\')">';
            html += '    <div class="top10-rank">' + rank + '</div>';
            html += '    <img src="' + img + '" class="top10-img" onerror="this.src=\'' + FALLBACK_IMG + '\'">';
            html += '    <div class="top10-info">';
            html += '        <div class="top10-title">' + title + '</div>';
            html += '        <div class="top10-artist">' + artist + '</div>';
            html += '    </div>';
            html += '    <div class="top10-play"><i class="fa-solid fa-play"></i></div>';
            html += '</div>';
        });
        
        $listContainer.html(html);
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
    const rawContextTags = [];
    <c:forEach var="ct" items="${homeContextTags}">rawContextTags.push("${ct}");</c:forEach>
    const locationTags = ["바다", "산/등산", "카페/작업", "헬스장", "공원/피크닉"];
    
    let contextHtml = '<div id="geo-weather-card" class="location-card" style="background-image:url(\'${pageContext.request.contextPath}/img/Location/seoul.jpg\')">'
                    + '  <span class="city-name" id="geo-city">LOCATION</span>'
                    + '  <div class="city-top-song" id="geo-weather-title">날씨 확인 중...</div>'
                    + '  <div class="city-top-artist" id="geo-weather-desc">위치 정보를 불러오는 중</div>'
                    + '</div>';
    
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

    const moodTags = [];
    <c:forEach var="mt" items="${homeMoodTags}">moodTags.push("${mt}");</c:forEach>
    let personalHtml = '';
    moodTags.forEach((name, idx) => {
        if (idx < 5) {
            const no = tagNoMap[name] || 9;
            personalHtml += '<div class="location-card tag-' + no + '" onclick="goTag(\'' + name + '\')">'
                          + '  <span class="city-name">MY MOOD #' + (idx + 1) + '</span>'
                          + '  <div class="city-top-song">' + name + '</div>'
                          + '  <div class="city-top-artist">당신을 위한 맞춤 추천</div>'
                          + '</div>';
        }
    });
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
    // 1. [중요] 서버에서 팝업 목록 가져오기 로직 추가
    $.get(contextPath + '/api/getPopups', function(list) {
        console.log("받아온 팝업 목록:", list);
        if (list && list.length > 0) {
            list.forEach(function(popup) {
                // noticeNo 필드를 사용하여 쿠키 체크
                const no = popup.noticeNo || popup.noticeno || 1;
                const cookieKey = 'hide_popup_' + no;
                
                if (!getCookie(cookieKey)) {
                    showLayerPopup(popup);
                }
            });
        }
    });

    // 2. 메뉴 카드 클릭 시 강제 이동
    $('.menu-grid').on('click', '.menu-card', function(e) {
        var href = $(this).attr('href');
        if(href) location.href = href;
    });

    // 3. MusicApp 초기화 및 데이터 로드
    if (window.MusicApp) window.MusicApp.init("${loginUser.UNo}" || 0);
    
    loadRegionalPreviews();
    drawTagCards();
    loadItunesMusic();
    setTimeout(loadTop10, 300);
});

// --- 추가 함수: 팝업 생성 ---
// 팝업 생성 함수: 데이터 필드명을 더 꼼꼼하게 체크합니다.
// 1. 팝업 생성 함수
// 1. 팝업 생성 함수
// --- 팝업 관련 최종 통합 함수 (중복 제거용) ---

function showLayerPopup(popup) {
    const title = popup.ntitle || popup.nTitle || "공지사항"; 
    const content = popup.ncontent || popup.nContent || "내용이 없습니다.";
    const no = popup.noticeNo || popup.noticeno || 1;

    const modalHtml = `
        <div id="popup-modal-\${no}" class="custom-popup-sticker" 
             style="position: fixed; 
                    top: 150px;   /* 화면 상단에서 20px */
                    left: 120px;  /* 화면 왼쪽에서 20px */
                    width: 320px; 
                    background: #1a1a1a; 
                    border: 2px solid #ff0055; 
                    border-radius: 12px; 
                    box-shadow: 0 10px 30px rgba(0,0,0,0.7); 
                    z-index: 100002; /* 헤더보다 위에 오도록 설정 */
                    color: #fff;
                    overflow: hidden;
                    pointer-events: auto; /* 팝업 자체는 클릭 가능 */
             ">
            
            <div style="padding: 12px 15px; background: #222; border-bottom: 1px solid #333; display: flex; justify-content: space-between; align-items: center;">
                <strong style="color: #ff0055; font-size: 0.9rem;">\${title}</strong>
                <span onclick="closePopup(\${no})" style="cursor:pointer; color:#888; font-size: 1.2rem;">&times;</span>
            </div>

            <div style="padding: 15px; min-height: 60px; font-size: 0.9rem; line-height: 1.4; color: #eee;">
                \${content}
            </div>

            <div style="padding: 10px 15px; background: #1a1a1a; display: flex; justify-content: space-between; align-items: center; border-top: 1px solid #333;">
                <label style="font-size: 11px; color: #bbb; cursor: pointer; display: flex; align-items: center;">
                    <input type="checkbox" id="no-more-\${no}" style="margin-right: 5px;"> 오늘 하루 보지 않기
                </label>
                <button onclick="closePopup(\${no})" 
                        style="background: #ff0055; border: none; color: #fff; padding: 4px 12px; border-radius: 4px; cursor: pointer; font-size: 11px; font-weight: bold;">
                    닫기
                </button>
            </div>
        </div>
    `;
    
    $('body').append(modalHtml);
}

function closePopup(no) {
    console.log("닫기 실행 시도 - 번호:", no);
    
    // 1. 오늘 하루 보지 않기 체크 여부 확인
    if ($('#no-more-' + no).is(':checked')) {
        setCookie('hide_popup_' + no, 'true', 1);
        console.log("쿠키 저장 완료: hide_popup_" + no);
    }

    // 2. 팝업 제거 (두 가지 방법 병행)
    // 방법 A: ID로 정확히 타격
    const targetModal = $('#popup-modal-' + no);
    
    if (targetModal.length > 0) {
        targetModal.remove();
        console.log("ID 기반 삭제 성공");
    } else {
        // 방법 B: ID 매칭 실패 시, 현재 클릭된 버튼에서 가장 가까운 오버레이 제거
        $('.custom-popup-overlay').has('#no-more-' + no).remove();
        console.log("근접 요소 탐색으로 삭제 성공");
    }
}

// --- 추가 함수: 쿠키 유틸리티 ---
function setCookie(name, value, days) {
    let date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    document.cookie = name + '=' + value + ';expires=' + date.toUTCString() + ';path=/';
}

function getCookie(name) {
    let value = "; " + document.cookie;
    let parts = value.split("; " + name + "=");
    if (parts.length === 2) return parts.pop().split(";").shift();
}
</script>
</body>
</html>