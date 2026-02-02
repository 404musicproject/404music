<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" buffer="32kb" autoFlush="true" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | 추천 음악</title>
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/music-chart.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/music-service.js"></script> 

<style>
    /* 기본 레이아웃 - 너비를 1100px로 제한하여 집중도 향상 */
    body { background-color: #050505; color: #fff; margin: 0; }
    .container { max-width: 1100px; margin: 0 auto; padding: 0 30px; }

    /* 1. Hero 섹션: 높이와 텍스트 크기 축소 */
    .tag-hero { 
        height: 400px; background: #000; display: flex; 
        align-items: flex-end; position: relative; 
        overflow: hidden; padding: 0; 
    }
    
/* 2중 배경 레이어 */
#hero-bg-blur, #hero-bg-clear {
    position: absolute; top: 0; left: 0; 
    width: 100%; height: 100%;
    background-size: cover; 
    background-position: center;
    background-repeat: no-repeat;
    transition: background-image 1s ease-in-out;
}

#hero-bg-blur {
    filter: brightness(0.3) blur(20px); /* 배경을 더 어둡고 흐리게 */
    transform: scale(1.1);
    z-index: 0;
}

#hero-bg-clear {
    filter: brightness(0.5); 
    z-index: 1;
    mask-image: radial-gradient(circle, black 25%, transparent 75%);
}

/* 검은 안개 오버레이 (텍스트 가독성용) */
.hero-overlay {
    position: absolute; top: 0; left: 0; width: 100%; height: 100%;
    background: linear-gradient(to top, #050505 10%, transparent 80%);
    z-index: 2; /* 배경들보다 위 */
}
    .hero-content-wrapper {
        width: 100%;
        max-width: 1100px; /* 컨테이너와 통일 */
        margin: 0 auto;
        padding: 0 30px;
        padding-bottom: 60px;
        position: relative;
        z-index: 3;
    }
    #hero-tag-name { 
        font-size: 5rem; font-weight: 900; margin: 0; line-height: 1.15;
        text-transform: uppercase; letter-spacing: -2px;
        background: linear-gradient(to bottom, #fff, #888);
        -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        margin-left: -3px;

    }
    #hero-tag-desc {
        font-size: 0.9rem; color: #00f2ff; font-family: monospace;
        letter-spacing: 4px; opacity: 0.8;
    }

    /* 2. 플로팅 탭 메뉴 - 더 콤팩트하게 */
    .chart-tabs { 
        position: sticky; top: 15px; z-index: 100;
        background: rgba(15, 15, 15, 0.8); backdrop-filter: blur(15px);
        margin-top: -30px; padding: 8px 20px;
        border-radius: 40px; border: 1px solid rgba(255, 255, 255, 0.1);
        display: flex; align-items: center; gap: 5px;
        box-shadow: 0 15px 30px rgba(0,0,0,0.5);
    }
    .tab-btn { 
        padding: 8px 18px; background: transparent; border: none; 
        color: #777; font-size: 0.9rem; font-weight: 600; cursor: pointer; border-radius: 20px; 
        transition: 0.3s;
    }
    .tab-btn:hover { color: #fff; }
    .tab-btn.active { background: #00f2ff; color: #000 !important; }

    /* 3. 뮤직 카드 그리드 - 보기 편한 5열/4열 구성 */
    .music-grid {
        display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
        gap: 20px; margin: 40px 0;
    }
    .music-card {
        background: #111; border-radius: 10px; padding: 12px;
        transition: 0.3s ease; border: 1px solid #1a1a1a; cursor: pointer;
    }
    .music-card:hover { transform: translateY(-7px); background: #181818; border-color: #333; }
    .card-img-wrap {
        position: relative; width: 100%; aspect-ratio: 1/1; 
        border-radius: 6px; overflow: hidden; margin-bottom: 12px;
    }
    .card-img-wrap img { width: 100%; height: 100%; object-fit: cover; }
    .card-play-overlay {
        position: absolute; top:0; left:0; width:100%; height:100%;
        background: rgba(0,0,0,0.5); display:flex; align-items:center; justify-content:center;
        opacity:0; transition: 0.3s;
    }
    .music-card:hover .card-play-overlay { opacity: 1; }
    .card-title { font-weight: bold; font-size: 1rem; margin-bottom: 4px; color: #fff; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .card-artist { color: #888; font-size: 0.85rem; }
    .card-actions { display: flex; justify-content: space-between; margin-top: 12px; color: #444; font-size: 0.9rem; }

    /* 하단 배너 - 너비 밸런스 최적화 */
    .recommend-banner {
        display: flex; align-items: center; justify-content: space-between; 
        background: linear-gradient(90deg, #00f2ff 0%, #0066ff 100%); 
        color: black; padding: 30px; border-radius: 15px; 
        text-decoration: none; margin: 60px 0;
        transition: transform 0.3s ease;
    }
    .recommend-banner:hover { transform: translateY(-5px); }
    .recommend-banner h4 { margin: 0; font-size: 1.3rem; letter-spacing: -0.5px; }
    .recommend-banner p { margin: 5px 0 0 0; opacity: 0.8; font-size: 0.95rem; }
    .recommend-banner span { background: #000; color: #fff; padding: 10px 20px; border-radius: 30px; font-size: 0.9rem; font-weight: bold; }
	.chart-tabs {
    position: sticky; top: 15px; z-index: 100;
    background: rgba(15, 15, 15, 0.9); backdrop-filter: blur(20px);
    margin-top: -50px; padding: 25px;
    border-radius: 20px; border: 1px solid rgba(255, 255, 255, 0.1);
}

.tab-section { margin-bottom: 20px; }
.tab-section:last-child { margin-bottom: 0; }

.section-title {
    display: block; font-size: 0.75rem; font-weight: 800;
    color: #00f2ff; margin-bottom: 12px; letter-spacing: 2px;
    opacity: 0.7;
}

.tab-group {
    display: flex; flex-wrap: wrap; gap: 10px;
}

.tab-btn {
    padding: 8px 16px; background: rgba(255,255,255,0.05);
    border: 1px solid rgba(255,255,255,0.1); color: #ccc;
    border-radius: 30px; cursor: pointer; transition: 0.3s;
}

.tab-btn.active {
    background: #00f2ff; color: #000; border-color: #00f2ff;
    font-weight: bold;
}

</style>

</head>
<body>
<header><%@ include file="/WEB-INF/views/common/Header.jsp" %></header>

<section class="tag-hero">
	<div id="hero-bg-blur"></div>
    <div id="hero-bg-clear"></div>
    <div class="hero-overlay"></div> 
    <div class="hero-content-wrapper"> <div id="hero-tag-desc">CURATED PLAYLIST FOR</div>
        <h1 id="hero-tag-name">MOOD</h1>
    </div>
</section>

<main class="container">
<div class="chart-tabs">
    <div id="dynamic-tabs" style="display: flex; gap: 5px;">
        </div>
    <button class="tab-btn" onclick="location.href='${pageContext.request.contextPath}/home'" style="margin-left: auto; color: #ff0055;">BACK ✕</button>
</div>

    <div class="music-grid" id="chart-body"></div>

    <a href="${pageContext.request.contextPath}/recommendationCategories" class="recommend-banner">
        <div>
            <h4 style="margin: 0; font-size: 1.6rem; letter-spacing: -1px;">원하는 분위기가 없나요? 🤔</h4>
            <p style="margin: 10px 0 0 0; opacity: 0.8; font-size: 1.1rem;">날씨, 장소, 장르별 상세 카테고리에서 추천받아보세요.</p>
        </div>
        <span style="background: #000; color: #fff; padding: 15px 30px; border-radius: 40px; font-size: 1rem;">
            카테고리 전체보기 >
        </span>
    </a>
</main>

<footer><%@ include file="/WEB-INF/views/common/Footer.jsp" %></footer>

<script>
// 전역 변수 설정
var contextPath = '${pageContext.request.contextPath}'; 

$(document).ready(function() {
    var activeTag = '${tagName}';
    
    var contextGroup = []; 
    var moodGroup = [];    
    
    var locationTags = ["바다", "산/등산", "카페/작업", "헬스장", "공원/피크닉"];
    var weatherList = ["맑음", "흐림", "비 오는 날", "눈 오는 날", "더운 여름"];

    // (1) 모든 분류를 userTags(유저 활동 기반)에서만 수행합니다.
    var moodCount = 0;
    var locCount = 0;

    <c:forEach var="tag" items="${userTags}">
        (function() {
            var tagVal = "${tag}";
            
            // 장소/상황 태그 분류 (최대 4개 - 날씨 자리를 비워둠)
            if(locationTags.indexOf(tagVal) !== -1) {
                if(locCount < 4 && contextGroup.indexOf(tagVal) === -1) {
                    contextGroup.push(tagVal);
                    locCount++;
                }
            } 
            // 무드/활동 태그 분류 (최대 5개)
            else if(weatherList.indexOf(tagVal) === -1) { 
                if(moodCount < 5 && moodGroup.indexOf(tagVal) === -1) {
                    moodGroup.push(tagVal);
                    moodCount++;
                }
            }
        })();
    </c:forEach>

    // (2) 실시간 날씨 데이터 반영 (이 로직이 contextGroup의 첫 번째 칸을 차지합니다)
    if (window.MusicApp) {
        window.MusicApp.getWeatherData(function(data) {
            var weatherTag = "맑음";
            if (data) {
                var weatherId = data.weather[0].id;
                if (weatherId < 600) weatherTag = "비 오는 날";
                else if (weatherId < 700) weatherTag = "눈 오는 날";
                else if (weatherId > 800) weatherTag = "흐림";
            }
            
            // 기존에 섞여 들어갔을지 모르는 날씨 태그 제거
            contextGroup = contextGroup.filter(function(t) { return weatherList.indexOf(t) === -1; });
            
            // 현재 날씨를 맨 앞에 추가
            contextGroup.unshift(weatherTag);
            
            // 혹시 날씨 포함 5개가 넘어가면 자르기
            if(contextGroup.length > 5) contextGroup = contextGroup.slice(0, 5);

            renderSplitTabs(contextGroup, moodGroup, activeTag);
        });
    } else {
        renderSplitTabs(contextGroup, moodGroup, activeTag);
    }
});

// 섹션별 탭 렌더링
function renderSplitTabs(contexts, moods, activeTag) {
    var html = '';

    if(contexts.length > 0) {
        html += '<div class="tab-section"><span class="section-title">📍 NOW & HERE</span>';
        html += '<div class="tab-group">';
        for(var i=0; i<contexts.length; i++) {
            var tag = contexts[i];
            var isActive = (tag === activeTag) ? 'active' : '';
            html += '<button class="tab-btn ' + isActive + '" onclick="changeTag(\'' + tag + '\', this)">#' + tag + '</button>';
        }
        html += '</div></div>';
    }

    if(moods.length > 0) {
        html += '<div class="tab-section"><span class="section-title">✨ FOR YOUR MOOD</span>';
        html += '<div class="tab-group">';
        for(var j=0; j<moods.length; j++) {
            var mTag = moods[j];
            var mActive = (mTag === activeTag) ? 'active' : '';
            html += '<button class="tab-btn ' + mActive + '" onclick="changeTag(\'' + mTag + '\', this)">#' + mTag + '</button>';
        }
        html += '</div></div>';
    }

    $('#dynamic-tabs').html(html).css('display', 'block');

    if (activeTag) {
        var target = $('.tab-btn').filter(function() { 
            return $(this).text().trim() === '#' + activeTag; 
        })[0];
        if(target) changeTag(activeTag, target);
    }
}

function changeTag(tagName, btn) {
    if (!tagName || tagName === 'undefined') return;

    $('.tab-btn').removeClass('active');
    if(btn) $(btn).addClass('active');
    
    $('#hero-tag-name').text(tagName);
    
    var uNo = "${loginUser.UNo}" || "${loginUser.uNo}" || 0;

    $.ajax({
        url: contextPath + '/api/recommendations/tag',
        data: { tagName: tagName, u_no: uNo },
        method: 'GET',
        success: function(data) {
            renderMusicList(data);
            if(data && data.length > 0) {
                var bg = data[0].b_image || data[0].B_IMAGE || '';
                if(bg) {
                    var fullImg = bg.indexOf('http') === 0 ? bg : contextPath + '/' + bg;
                    $('#hero-bg-blur, #hero-bg-clear').css('background-image', 'url(' + fullImg + ')');
                }
            }
        },
        error: function(xhr) {
            $('#chart-body').html('<div style="grid-column: 1/-1; text-align:center; padding:100px; color:#666;">데이터를 불러올 수 없습니다.</div>');
        }
    });
}

function renderMusicList(musicList) {
    var html = '';
    if (!musicList || musicList.length === 0) {
        html = '<div style="grid-column: 1/-1; text-align:center; padding:100px; color:#666;">추천 음악이 없습니다.</div>';
    } else {
        $.each(musicList, function(index, music) {
            var title = (music.m_title || music.M_TITLE || 'Unknown').replace(/'/g, "\\'");
            var artist = (music.a_name || music.A_NAME || 'Unknown').replace(/'/g, "\\'");
            var imgPath = music.b_image || music.B_IMAGE || '';
            var albumImg = imgPath.indexOf('http') === 0 ? imgPath : contextPath + (imgPath.indexOf('/') === 0 ? '' : '/') + imgPath;
            
            html += '<div class="music-card" onclick="handlePlay(\'' + title + '\', \'' + artist + '\', \'' + albumImg + '\')">';
            html += '<div class="card-img-wrap"><img src="' + albumImg + '" onerror="this.src=\'https://placehold.co/400x400/111/00f2ff?text=Error\'">';
            html += '<div class="card-play-overlay"><i class="fa-solid fa-play" style="font-size: 2rem; color: #00f2ff;"></i></div></div>';
            html += '<div class="card-title" title="' + title + '">' + title + '</div>';
            html += '<div class="card-artist">' + artist + '</div></div>';
        });
    }
    $('#chart-body').html(html);
}

function handlePlay(title, artist, img) {
    if(typeof MusicApp !== 'undefined') {
        MusicApp.playLatestYouTube(title, artist, img);
    }
}
</script>
</body>
</html>