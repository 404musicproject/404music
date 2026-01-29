<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" buffer="32kb" autoFlush="true" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | 추천 음악</title>
    
    <style>
        /* 네온 탭 스타일 추가 */
        .chart-tabs { display: flex; gap: 10px; margin-bottom: 20px; overflow-x: auto; padding: 10px 0; }
        .tab-btn { 
            padding: 10px 25px; background: transparent; border: 1px solid #444; color: #888; 
            cursor: pointer; border-radius: 20px; font-weight: bold; transition: 0.3s; white-space: nowrap;
        }
        .tab-btn.active { border-color: #00f2ff; color: #00f2ff; box-shadow: 0 0 15px rgba(0, 242, 255, 0.4); }
        .tag-hero { 
            height: 300px; background: #050505; display: flex; align-items: center; justify-content: center; 
            position: relative; border-bottom: 2px solid #00f2ff; overflow: hidden;
        }
        #hero-bg { position: absolute; width: 100%; height: 100%; background-size: cover; filter: blur(30px) brightness(0.3); opacity: 0.7; }
        .hero-content { position: relative; z-index: 2; text-align: center; }
        #hero-tag-name { font-size: 4rem; color: #ff0055; text-shadow: 0 0 20px #ff0055; text-transform: uppercase; }
    </style>
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/music-chart.css">
    <!-- 기타 CSS 및 JS 파일 포함 -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/music-service.js"></script> 

<script>
$(document).ready(function() {
    const urlParams = new URLSearchParams(window.location.search);
    const paramTag = urlParams.get('tagName');
    // 컨트롤러에서 넘어온 tagName이 있으면 그걸 쓰고, 없으면 JSTL topTags의 첫 번째 사용
    let currentTag = paramTag || "${topTags[0]}"; 

    // 초기 로딩: 현재 태그와 일치하는 버튼을 찾아 클릭 효과를 줌
    const $targetBtn = $('.tab-btn').filter(function() {
        return $(this).text().trim() === currentTag;
    });

    if ($targetBtn.length > 0) {
        changeTag(currentTag, $targetBtn);
    } else {
        // 일치하는 버튼이 없더라도 데이터는 불러오도록 처리
        changeTag(currentTag, null);
    }
});

// [중요] 함수를 $(document).ready 바깥으로 꺼내야 HTML onclick에서 인식합니다.
function changeTag(tagName, btn) {
    $('.tab-btn').removeClass('active');
    if(btn) $(btn).addClass('active');
    
    $('#hero-tag-name').text(tagName);
    $('#hero-tag-desc').text("Listing tracks for mood: " + tagName);
    
    const uNo = "${sessionScope.loginUser.uNo}" || 0;

    $.ajax({
        url: '${pageContext.request.contextPath}/api/recommendations/tag/' + encodeURIComponent(tagName) + '?u_no=' + uNo,
        method: 'GET',
        success: function(data) {
            renderMusicList(data);
            if(data && data.length > 0) {
                const bgImg = data[0].b_image || data[0].B_IMAGE || '';
                if(bgImg) $('#hero-bg').css('background-image', 'url(' + bgImg + ')');
            }
        },
        error: function() {
            $('#chart-body').html('<tr><td colspan="5" style="text-align:center;">데이터를 가져오는 중 오류가 발생했습니다.</td></tr>');
        }
    });
}

function renderMusicList(musicList) {
    let html = '';
    if (!musicList || musicList.length === 0) {
        html = '<tr><td colspan="5" style="text-align:center; padding:50px;">추천 음악이 없습니다.</td></tr>';
    } else {
        $.each(musicList, function(index, music) {
            const mNo = music.m_no || music.M_NO;
            const title = (music.m_title || music.M_TITLE || 'Unknown').replace(/'/g, "\\'");
            const artist = (music.a_name || music.A_NAME || 'Unknown').replace(/'/g, "\\'");
            const albumImg = music.b_image || music.B_IMAGE || '${pageContext.request.contextPath}/images/default_album.png';

            html += '<tr style="cursor:pointer;" onclick="MusicApp.playLatestYouTube(\'' + title + '\', \'' + artist + '\', \'' + albumImg + '\')">';
            html += '<td>' + (index + 1) + '</td>';
            html += '<td>';
            html += '    <div style="display: flex; align-items: center; gap: 15px;">';
            html += '        <img src="' + albumImg + '" width="50" height="50" style="border-radius: 4px; object-fit:cover;">';
            html += '        <div>';
            html += '            <strong style="display: block; color: #fff;">' + title + '</strong>';
            html += '            <span style="color: #ccc; font-size: 0.9em;">' + artist + '</span>';
            html += '        </div>';
            html += '    </div>';
            html += '</td>';
            html += '<td style="text-align: center;"><i class="fa-regular fa-heart"></i></td>';
            html += '<td style="text-align: center;"><i class="fa-solid fa-plus-square" style="color:#00f2ff;"></i></td>';
            html += '<td style="text-align: right; padding-right: 20px; color: #ff0055;"><i class="fa-solid fa-play"></i></td>';
            html += '</tr>';
        });
    }
    $('#chart-body').html(html);
}
</script>
</head>
<body>
<header><%@ include file="/WEB-INF/views/common/Header.jsp" %></header>

<section class="tag-hero">
    <div id="hero-bg"></div>
    <div class="hero-content">
        <h1 id="hero-tag-name">MOOD</h1>
        <div id="hero-tag-desc">Analyzing your music taste...</div>
    </div>
</section>

<main>
    <div class="container">
        <!-- 태그 탭 영역 (동적으로 5~10개 배치) -->
        <div class="chart-tabs">
            <c:forEach var="t" items="${topTags}">
                <button class="tab-btn ${t == tagName ? 'active' : ''}" onclick="changeTag('${t}', this)">${t}</button>
            </c:forEach>
            <button class="tab-btn" onclick="location.href='${pageContext.request.contextPath}/home'" style="margin-left: auto; border-color: #444; color: #888 !important;">← BACK</button>
        </div>

        <div class="section">
            <div class="chart-header">
                <h2 style="margin:0; color:#00f2ff;">RECOMMENDED LIST</h2>
            </div>
            <table class="chart-table">
                <thead>
                    <tr><th>RANK</th><th>SONG INFO</th><th style="text-align: center;">LIKE</th><th style="text-align: center;">LIB</th><th style="text-align: right; padding-right: 20px;">PLAY</th></tr>
                </thead>
                <tbody id="chart-body"></tbody>
            </table>
        </div>
    </div>
</main>

<div id="player-container" style="position: fixed; bottom: 30px; right: 30px; background: #000; padding: 12px; border-radius: 12px; display: none; z-index: 1001; border: 2px solid #00f2ff;">
    <div id="player"></div>
</div>

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

<footer><%@ include file="/WEB-INF/views/common/Footer.jsp" %></footer>
</body>
</html>