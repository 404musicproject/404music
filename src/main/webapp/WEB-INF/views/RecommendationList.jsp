<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" buffer="32kb" autoFlush="true" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | 추천 음악</title>
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/music-chart.css">
    <!-- 기타 CSS 및 JS 파일 포함 -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/music-service.js"></script> 

<script>
    $(document).ready(function() {
        const urlParams = new URLSearchParams(window.location.search);
        const tagName = urlParams.get('tagName'); 
        const currentUserNo = "${sessionScope.user.u_no}"; 

        if (tagName) {
            $('#chart-title').text(tagName + ' 추천 음악');
            loadRecommendedMusic(tagName);
        } else {
            $('#chart-title').text('잘못된 접근입니다.');
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

<main>
    <div class="container">
        <div class="section">
            <div class="chart-header">
                <div>
                    <h2 id="chart-title"></h2>
                </div>
            </div>

            <table class="chart-table">
                 <thead>
                    <tr>
                        <th>RANK</th>
                        <th>SONG INFO</th>
                        <th style="text-align: center;">LIKE</th>
                        <th style="text-align: right; padding-right: 20px;">PLAYS</th>
                    </tr>
                </thead>
                <tbody id="chart-body">
                    <!-- Music list will be rendered here by JavaScript -->
                </tbody>
            </table>
        </div>
    </div>
</main>

<!-- Player container (as per your original code) -->
<div id="player-container" style="display: none;">
     <!-- ... player HTML ... -->
</div>

<footer><%@ include file="/WEB-INF/views/common/Footer.jsp" %></footer>
</body>
</html>