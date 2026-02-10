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
    /* 기본 레이아웃 - 너비를 1100px로 제한 */
    body { background-color: #050505; color: #fff; margin: 0; }
    .container { max-width: 1100px; margin: 0 auto; padding: 0 30px; box-sizing: border-box; }

/* 1. Hero 섹션 - 중앙 정렬 컨테이너 */
.tag-hero { 
    height: 500px; 
    background: #050505; 
    display: flex; 
    align-items: center; 
    justify-content: center;
    position: relative; 
    padding: 40px 0;
}

/* 이미지 박스: 텍스트의 부모가 되어야 하므로 position: relative 필수 */
.hero-image-box {
    position: relative;
    width: 100%;
    max-width: 1100px; 
    height: 100%;
    border-radius: 24px; 
    overflow: hidden;
    box-shadow: 0 20px 50px rgba(0,0,0,0.5);
    background-color: #111; /* 이미지 로딩 전 대비 */
}

#hero-bg-clear {
    position: absolute; 
    top: 0; left: 0; right: 0; bottom: 0;
    background-size: cover; 
    background-position: center;
    background-repeat: no-repeat;
    filter: brightness(0.8); 
    z-index: 1;
}

/* 글자 가독성을 위해 하단을 어둡게 깔아주는 레이어 */
.hero-overlay {
    position: absolute; 
    bottom: 0; left: 0; right: 0;
    height: 70%; /* 그라데이션 범위를 넉넉하게 */
    background: linear-gradient(to top, rgba(0,0,0,0.9) 0%, rgba(0,0,0,0.4) 50%, transparent 100%);
    z-index: 2;
}

/* 텍스트 컨테이너: 이미지 박스의 왼쪽 하단 구석에 딱 붙임 */
.hero-content-wrapper {
    position: absolute;
    left: 0;
    bottom: 0;
    width: 100%;
    padding: 40px 50px; /* 왼쪽과 아래 여백 */
    z-index: 3;
    box-sizing: border-box;
    text-align: left;
}

#hero-tag-desc {
    font-size: 1rem; 
    color: #00f2ff; 
    font-weight: 800;
    letter-spacing: 4px; 
    margin-bottom: 5px;
    text-shadow: 0 2px 10px rgba(0,0,0,0.9);
}

#hero-tag-name { 
    font-size: 5rem; 
    font-weight: 900; 
    margin: 0;
    color: #fff;
    line-height: 1;
    text-shadow: 0 5px 25px rgba(0,0,0,0.9);
    text-transform: uppercase;
}
    /* 2. 플로팅 탭 메뉴 - 왼쪽 정렬 및 그리드 너비 일치 */
		.chart-tabs { 
		    position: sticky; 
		    top: 10px; 
		    z-index: 100;
		    background: rgba(15, 15, 15, 0.9); 
		    backdrop-filter: blur(20px);
		    
		    margin-top: -40px; 
		    /* 중요: padding을 30px로 설정하여 .container의 여백과 일치시킴 */
		    padding: 20px 30px 20px 30px;
		    
		    border-radius: 20px; 
		    border: 1px solid rgba(255, 255, 255, 0.1);
		    box-shadow: 0 15px 30px rgba(0,0,0,0.5);
		    
		    /* 너비 설정 */
		    width: 100%; 
		    box-sizing: border-box; 
		    
		    /* 내부 요소 왼쪽 정렬 (가운데 정렬 해제) */
		    display: flex; 
		    flex-direction: column; 
		    align-items: flex-start; 
		    gap: 15px;
		}
		/* BACK 버튼 위치 및 크기 정상화 */
		.chart-tabs .tab-btn[onclick*="home"] {
		    position: absolute;
		    right: 20px;
		    top: 20px; /* 상단 여백에 맞춰 위치 조정 */
		    margin-left: 0;
		    
		    /* 기존 과도한 padding(35px)을 제거하고 일반 버튼 크기로 복구 */
		    padding: 8px 16px; 
		    
		    background: rgba(255, 0, 85, 0.1); /* 배경에 살짝 붉은 빛 추가 (선택사항) */
		    border: 1px solid rgba(255, 0, 85, 0.3);
		    color: #ff0055 !important; /* 글자색 강조 */
		    font-size: 0.8rem;
		    border-radius: 20px;
		    transition: 0.3s;
		}
		.chart-tabs .tab-btn[onclick*="home"]:hover {
		    background: #ff0055;
		    color: #fff !important;
		}

    /* 섹션 간의 간격을 조절합니다 */
		.tab-section { 
		    margin-bottom: 5px; /* 기존 20px에서 35px로 간격 확대 */
		}
		
		/* 마지막 섹션은 아래 여백이 필요 없으므로 0으로 유지합니다 */
		.tab-section:last-child { 
		    margin-bottom: 0; 
		}
		
		/* 타이틀과 버튼들 사이의 간격도 살짝 조정하면 더 깔끔합니다 */
		.section-title {
		    display: block; 
		    font-size: 0.75rem; 
		    font-weight: 800;
		    color: #00f2ff; 
		    margin-bottom: 15px; /* 기존 12px에서 15px로 미세 조정 */
		    letter-spacing: 2px;
		    opacity: 0.7;
		}

    .tab-group { 
	    display: flex; 
	    flex-wrap: wrap; 
	    gap: 10px; 
	    justify-content: flex-start; /* 왼쪽 정렬 명시 */
	    width: 100%;
	}

    .tab-btn { 
        padding: 8px 18px; background: rgba(255,255,255,0.05); 
        border: 1px solid rgba(255,255,255,0.1); 
        color: #777; font-size: 0.9rem; font-weight: 600; cursor: pointer; border-radius: 20px; 
        transition: 0.3s;
    }
    .tab-btn:hover { color: #fff; background: rgba(255,255,255,0.1); }
    .tab-btn.active { background: #00f2ff; color: #000 !important; border-color: #00f2ff; }

    /* 3. 뮤직 카드 그리드 */
    .music-grid {
        display: grid; 
        grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
        gap: 20px; margin: 40px 0;
        width: 100%;
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

    /* 하단 배너 */
    .recommend-banner {
        display: flex; align-items: center; justify-content: space-between; 
        background: linear-gradient(90deg, #00f2ff 0%, #0066ff 100%); 
        color: black; padding: 30px; border-radius: 15px; 
        text-decoration: none; margin: 60px 0;
        transition: transform 0.3s ease;
    }
    .recommend-banner:hover { transform: translateY(-5px); }
</style>

</head>
<body>
<header><%@ include file="/WEB-INF/views/common/Header.jsp" %></header>

<section class="tag-hero">
    <div class="hero-image-box">
        <div id="hero-bg-clear"></div>
        <div class="hero-overlay"></div> 
        
        <div class="hero-content-wrapper"> 
            <div id="hero-tag-desc">CURATED PLAYLIST FOR</div>
            <h1 id="hero-tag-name">MOOD</h1>
        </div>
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
const tagNoMap = {
		  "행복한 기분": 1, "파티": 2, "더운 여름": 3, "자신감 뿜뿜": 4, "운동": 5,
		  "스트레스 해소": 6, "슬픔": 7, "비 오는 날": 8, "새벽 감성": 9, "로맨틱": 10,
		  "휴식": 11, "요리할 때": 12, "집중": 13, "맑음": 14, "흐림": 15,
		  "눈 오는 날": 16, "바다": 17, "산/등산": 18, "카페/작업": 19, "헬스장": 20, "공원/피크닉": 21
		};

$(document).ready(function() {
    var activeTag = '${tagName}'; 
    var userTagsFromServer = [];
    
    // 1. 이전 페이지 주소 확인 (홈에서 왔는지 카테고리에서 왔는지)
    var referrer = document.referrer;
    var isFromCategory = referrer.indexOf('recommendationCategories') !== -1;

    // 2. 서버에서 받은 추천 태그들을 배열에 담기
    <c:forEach var="tag" items="${userTags}">
        userTagsFromServer.push("${tag}");
    </c:forEach>

    // 3. 카테고리에서 클릭한 태그가 추천 리스트에 없다면 강제로 추가
    if (activeTag && activeTag !== 'undefined' && userTagsFromServer.indexOf(activeTag) === -1) {
        userTagsFromServer.push(activeTag);
    }

    var contextGroup = []; 
    var moodGroup = [];    
    var locationTags = ["바다", "산/등산", "카페/작업", "헬스장", "공원/피크닉"];
    var weatherList = ["맑음", "흐림", "비 오는 날", "눈 오는 날", "더운 여름"];

    // 4. 확장된 리스트를 바탕으로 탭 분류 실행
    userTagsFromServer.forEach(function(tagVal) {
        if(locationTags.indexOf(tagVal) !== -1) {
            if(contextGroup.length < 10) contextGroup.push(tagVal);
        } else if(weatherList.indexOf(tagVal) === -1) {
            if(moodGroup.length < 5) moodGroup.push(tagVal);
        }
    });

    // 5. UI 분기 처리 (카테고리 진입 시 탭 숨기기 및 버튼 변경)
    if (isFromCategory) {
        $('#dynamic-tabs').hide(); // 탭 숨김
        var $backBtn = $('.tab-btn[onclick*="location.href"]');
        $backBtn.text('🔙 카테고리로 돌아가기');
        $backBtn.attr('onclick', 'history.back()'); // history.back 적용
    }

 // [6번 수정] 날씨 데이터 확인 및 5개 강제 고정 로직
    if (window.MusicApp) {
        window.MusicApp.getWeatherData(function(data) {
            var weatherTag = "맑음";
            if (data) {
                var weatherId = data.weather[0].id;
                if (weatherId < 600) weatherTag = "비 오는 날";
                else if (weatherId < 700) weatherTag = "눈 오는 날";
                else if (weatherId > 800) weatherTag = "흐림";
            }
            
            if (!isFromCategory) {
                // 1. 날씨 중복 제거
                contextGroup = contextGroup.filter(function(t) { 
                    return weatherList.indexOf(t) === -1 && t !== weatherTag; 
                });

                // 2. 현재 선택된 태그가 있다면 최우선 배치
                if (locationTags.indexOf(activeTag) !== -1) {
                    contextGroup = contextGroup.filter(function(t) { return t !== activeTag; });
                    contextGroup.unshift(activeTag);
                }

                // 3. [추가] 만약 필터링 후 장소 태그가 4개 미만이라면 기본 태그로 채우기 (홈 화면 방식)
                if (contextGroup.length < 4) {
                    for (var i = 0; i < locationTags.length; i++) {
                        var fallback = locationTags[i];
                        if (contextGroup.indexOf(fallback) === -1 && fallback !== weatherTag && contextGroup.length < 4) {
                            contextGroup.push(fallback);
                        }
                    }
                }

                // 4. 최종 4개 절삭 후 날씨 추가 (1 + 4 = 5개 확정)
                contextGroup = contextGroup.slice(0, 4);
                contextGroup.unshift(weatherTag);
                
                renderSplitTabs(contextGroup, moodGroup, activeTag);
            } else {
                changeTag(activeTag, null);
            }
        });
    }
});

// 섹션별 탭 렌더링
function renderSplitTabs(contexts, moods, activeTag) {
    var html = '';
    if(contexts.length > 0) {
        html += '<div class="tab-section"><span class="section-title">📍 NOW & HERE</span><div class="tab-group">';
        for(var i=0; i<contexts.length; i++) {
            var tag = contexts[i];
            var isActive = (tag === activeTag) ? 'active' : '';
            html += '<button class="tab-btn ' + isActive + '" onclick="changeTag(\'' + tag + '\', this)">#' + tag + '</button>';
        }
        html += '</div></div>';
    }
    if(moods.length > 0) {
        html += '<div class="tab-section"><span class="section-title">✨ FOR YOUR MOOD</span><div class="tab-group">';
        for(var j=0; j<moods.length; j++) {
            var mTag = moods[j];
            var mActive = (mTag === activeTag) ? 'active' : '';
            html += '<button class="tab-btn ' + mActive + '" onclick="changeTag(\'' + mTag + '\', this)">#' + mTag + '</button>';
        }
        html += '</div></div>';
    }
    $('#dynamic-tabs').html(html).css('display', 'block');
    
    // 초기 로딩용 changeTag 호출
    if (activeTag && activeTag !== 'undefined') {
        var target = $('.tab-btn').filter(function() { return $(this).text().trim() === '#' + activeTag; })[0];
        changeTag(activeTag, target);
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
            
            // --- 배경 이미지 변경 로직 (태그 이미지로 교체) ---
            var tagNo = tagNoMap[tagName] || 19; // 맵에 없으면 기본값 19(카페)
            var tagImgPath = contextPath + '/img/Tag/' + tagNo + '.png'; // 홈화면과 동일한 경로
            
            // 히어로 배경 업데이트
            $('#hero-bg-clear').css('background-image', 'url(' + tagImgPath + ')');
        },
        error: function() {
            $('#chart-body').html('<div style="grid-column: 1/-1; text-align:center; padding:100px; color:#666;">데이터를 불러올 수 없습니다.</div>');
        }
    });
}
function renderMusicList(musicList) {
    var html = '';
    if (!musicList || musicList.length === 0) {
        html = '<div style="grid-column: 1/-1; text-align:center; padding:100px; color:#666;">추천 음악이 없습니다.</div>';
    } else {
        var limitedList = musicList.slice(0, 30); 
        $.each(limitedList, function(index, music) {
            var title = (music.m_title || music.M_TITLE || 'Unknown').replace(/'/g, "\\'");
            var artist = (music.a_name || music.A_NAME || 'Unknown').replace(/'/g, "\\'");
            var imgPath = music.b_image || music.B_IMAGE || '';
            var albumImg = imgPath.indexOf('http') === 0 ? imgPath : contextPath + (imgPath.indexOf('/') === 0 ? '' : '/') + imgPath;
            html += '<div class="music-card" onclick="handlePlay(\'' + title + '\', \'' + artist + '\', \'' + albumImg + '\')">'
                 + '<div class="card-img-wrap"><img src="' + albumImg + '" onerror="this.src=\'https://placehold.co/400x400/111/00f2ff?text=Error\'">'
                 + '<div class="card-play-overlay"><i class="fa-solid fa-play" style="font-size: 2rem; color: #00f2ff;"></i></div></div>'
                 + '<div class="card-title" title="' + title + '">' + title + '</div>'
                 + '<div class="card-artist">' + artist + '</div></div>';
        });
    }
    $('#chart-body').html(html);
}

function handlePlay(title, artist, img) {
    if(typeof MusicApp !== 'undefined') MusicApp.playLatestYouTube(title, artist, img);
}
</script>
</body>
</html>