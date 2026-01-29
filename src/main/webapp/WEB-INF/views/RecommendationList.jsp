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
    let currentTag = urlParams.get('tagName') || "${topTags[0]}"; // 기본값 첫 번째 태그
    const uNo = "${sessionScope.loginUser.uNo}" || 0;

    // 초기 로드
    changeTag(currentTag, $('.tab-btn:contains("' + currentTag + '")'));
});

// 탭 변경 함수 (여기서 AJAX 호출)
function changeTag(tagName, btn) {
    $('.tab-btn').removeClass('active');
    $(btn).addClass('active');
    $('#hero-tag-name').text(tagName);
    
    const uNo = "${sessionScope.loginUser.uNo}" || 0;

    $.ajax({
        url: '${pageContext.request.contextPath}/api/recommendations/tag/' + encodeURIComponent(tagName) + '?u_no=' + uNo,
        method: 'GET',
        success: function(data) {
            renderMusicList(data);
            if(data.length > 0) {
                $('#hero-bg').css('background-image', 'url(' + (data[0].b_image || data[0].B_IMAGE) + ')');
            }
        }
    });
}

        function loadRecommendedMusic(tagName) {
            $.ajax({
                url: '${pageContext.request.contextPath}/api/recommendations/tag/' + encodeURIComponent(tagName) + '?u_no=' + currentUserNo,
                method: 'GET',
                success: function(data) {
                    renderMusicList(data);
                },
                error: function(error) {
                    console.error("Error loading music:", error);
                    $('#chart-body').html('<tr><td colspan="4">음악을 불러오지 못했습니다.</td></tr>');
                }
            });
        }

        function renderMusicList(musicList) {
            let html = '';
            if (!musicList || musicList.length === 0) {
                html = '<tr><td colspan="4">추천 음악이 없습니다.</td></tr>';
            } else {
                $.each(musicList, function(index, music) {
                    // 데이터 안전성 처리 (null 방지) 및 대소문자 방어
                    const mNo = music.m_no || music.M_NO;
                    const title = (music.m_title || music.M_TITLE || 'Unknown').replace(/'/g, "\\'");
                    const artist = (music.a_name || music.A_NAME || 'Unknown').replace(/'/g, "\\'");
                    const youtubeId = music.m_youtube_id || music.M_YOUTUBE_ID || '';
                    const albumImg = music.b_image || music.B_IMAGE || '${pageContext.request.contextPath}/images/default_album.png';

                    // 백틱(`) 대신 일반 따옴표(')와 문자열 연결(+) 사용
                    html += '<tr style="cursor:pointer;" onclick="MusicApp.playLatestYouTube(\'' + title + '\', \'' + artist + '\', \'' + albumImg + '\')">';
                    html += '<td>' + (index + 1) + '</td>';
                    html += '<td>';
                    html += '    <div style="display: flex; align-items: center; gap: 15px;">';
                    html += '        <img src="' + albumImg + '" width="50" height="50" alt="Album Art" style="border-radius: 4px;">';
                    html += '        <div>';
                    html += '            <strong style="display: block; color: #fff;">' + title + '</strong>';
                    html += '            <span style="color: #ccc; font-size: 0.9em;">' + artist + '</span>';
                    html += '        </div>';
                    html += '    </div>';
                    html += '</td>';
                    html += '<td style="text-align: center;">';
                    html += '    <i class="fa-regular fa-heart" style="cursor:pointer;"></i>';
                    html += '</td>';
                    html += '<td style="text-align: right; padding-right: 20px; color: #aaa;">';
                    html += '    <i class="fa-solid fa-play"></i>';
                    html += '</td>';
                    html += '</tr>';
                });
            }
            $('#chart-body').html(html);
        }
    });
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

<footer><%@ include file="/WEB-INF/views/common/Footer.jsp" %></footer>
</body>
</html>