<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404 Music - 실시간 차트 및 분석</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://www.youtube.com/iframe_api"></script>
    <style>
        body { font-family: 'Pretendard', sans-serif; background-color: #f8f9fa; color: #333; margin: 0; padding: 20px; }
        .container { max-width: 1100px; margin: 0 auto; display: grid; grid-template-columns: 1fr 1.2fr; gap: 20px; }
        
        /* 대시보드 스타일 */
        .dashboard-section { grid-column: span 2; background: #fff; padding: 20px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); margin-bottom: 10px; }
        .new-release-wrapper { display: flex; gap: 15px; overflow-x: auto; padding: 10px 5px; scrollbar-width: thin; }
        .new-song-card { min-width: 130px; text-align: center; cursor: pointer; transition: 0.3s; }
        .new-song-card:hover { transform: translateY(-5px); }
        .new-song-card img { width: 120px; height: 120px; border-radius: 15px; object-fit: cover; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
        .new-song-info { margin-top: 8px; font-size: 0.85rem; }
        .new-song-title { font-weight: bold; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .new-song-artist { color: #888; font-size: 0.75rem; }

        /* 섹션 스타일 */
        .section { background: #fff; padding: 20px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        h2 { font-size: 1.2rem; margin-top: 0; color: #1db954; border-bottom: 2px solid #f1f1f1; padding-bottom: 10px; display: flex; align-items: center; justify-content: space-between; }

        #musicList { max-height: 500px; overflow-y: auto; }
        .music-item { display: flex; align-items: center; padding: 12px; border-bottom: 1px solid #eee; cursor: pointer; transition: 0.2s; }
        .music-item:hover { background: #f9f9f9; transform: translateX(5px); }
        .search-empty { padding: 40px 20px; text-align: center; color: #999; font-size: 0.9rem; }

        /* 차트 스타일 */
        .chart-table { width: 100%; border-collapse: collapse; }
        .chart-table th { font-size: 0.85rem; color: #888; padding: 10px; border-bottom: 1px solid #eee; text-align: left; }
        .chart-table td { padding: 12px 10px; border-bottom: 1px solid #f9f9f9; font-size: 0.9rem; }
        .rank { font-weight: bold; width: 30px; color: #1db954; font-style: italic; }
        .album-art { width: 45px; height: 45px; border-radius: 4px; margin-right: 12px; border: 1px solid #eee; }
        .play-cnt { color: #ff3d00; font-weight: bold; font-size: 0.8rem; background: #fff5f2; padding: 2px 6px; border-radius: 4px; margin-left: 5px; }
        
        /* 유튜브 플레이어 스타일 */
        #player-container { position: fixed; bottom: 20px; right: 20px; background: #000; padding: 10px; border-radius: 12px; display: none; z-index: 1000; box-shadow: 0 10px 30px rgba(0,0,0,0.5); border: 1px solid #333; }
        #player-container h3 { color: #fff; font-size: 0.8rem; margin: 0 0 10px 0; font-weight: 400; }
        .preview-badge { font-size: 0.6rem; background: #ff1493; color: white; padding: 2px 5px; border-radius: 3px; margin-left: 5px; cursor: pointer; }
        .btn-play { background: #1db954; color: white; border: none; padding: 6px 10px; border-radius: 50%; cursor: pointer; width: 30px; height: 30px; }
        .btn-like { background: none; border: none; cursor: pointer; font-size: 1.2rem; color: #ccc; transition: 0.2s; }
        .btn-like.active { color: #ff1493; }
    </style>
</head>
<body>
<header>
<%@ include file="/WEB-INF/views/common/Header.jsp" %>
</header>

<div class="container">
    <div class="dashboard-section">
        <h2>✨ 한국 최신 발매 신곡</h2>
        <div id="new-release-list" class="new-release-wrapper">
            <p style="padding:20px; color:#888;">데이터 로딩 중...</p>
        </div>
    </div>

<div class="section">
    <h2>🔍 '${keyword}' 검색 결과</h2>
    <div id="musicList">
        <c:choose>
            <c:when test="${not empty musicList}">
                <c:forEach var="music" items="${musicList}">
                    <div class="music-item" onclick="handleMusicClick('${music.m_no}', '${music.m_youtube_id}', '${music.m_title}', '${music.a_name}')">
                        <b>${music.m_title} <small style="color:#888;">- ${music.a_name}</small></b>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="search-empty">
                    <p>검색 결과가 없습니다.</p>
                    <button onclick="registerNewMusic('${keyword}')">유튜브 자동 등록</button>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

    <div class="section">
        <h2>
            실시간 TOP 100 
            <small id="update-time" style="font-weight: normal; color: #888; font-size: 0.7rem;"></small>
        </h2>
        <table class="chart-table">
            <thead>
                <tr>
                    <th>순위</th>
                    <th>곡 정보</th>
                    <th>조회/좋아요</th>
                    <th>듣기</th>
                </tr>
            </thead>
            <tbody id="top100-body">
                <tr><td colspan="4" style="text-align:center; padding: 50px;">데이터를 불러오는 중...</td></tr>
            </tbody>
        </table>
    </div>
</div>

<div id="player-container">
    <div style="display: flex; justify-content: space-between; align-items: center;">
        <h3 id="now-playing-title">현재 재생 중</h3>
        <button onclick="stopYoutube()" style="background:none; border:none; color:white; cursor:pointer; font-size: 16px;">&times;</button>
    </div>
    <div id="player"></div>
</div>

<script>
    var player;
    var currentMusicNo = 0;
    var audioPlayer = new Audio(); 
    var currentUserNo = Number("${sessionScope.loginUser.uNo}") || 0;

    $(document).ready(function() {
        loadNewReleases(); 
        loadTop100(); 
        setInterval(loadTop100, 60000); 

        // 헤더 검색창 파라미터 체크 (헤더에서 /productSearchfh?searchKeyword=... 로 넘어왔을 때)
        const urlParams = new URLSearchParams(window.location.search);
        const keyword = urlParams.get('searchKeyword');
        if(keyword) {
            executeSearch(keyword);
        }
    });

    // 1. iTunes API 최신곡 로드
    function loadNewReleases() {
        var url = "https://itunes.apple.com/search?term=2026&country=KR&entity=song&limit=15&sort=recent";
        $.ajax({
            url: url, dataType: 'jsonp',
            success: function(data) {
                var html = '';
                if (!data.results || data.results.length === 0) {
                    $('#new-release-list').html('<p style="padding:20px;">데이터가 없습니다.</p>');
                    return;
                }
                $.each(data.results, function(i, item) {
                    var title = item.trackName || "Unknown";
                    var artist = item.artistName || "Unknown Artist";
                    var imgUrl = (item.artworkUrl100 || "").replace("http://", "https://");
                    var cleanTitle = title.replace(/'/g, "\\'");
                    var cleanArtist = artist.replace(/'/g, "\\'");
                    html += '<div class="new-song-card" onclick="executeSearch(\'' + cleanArtist + ' ' + cleanTitle + '\')">';
                    html += '    <img src="' + imgUrl + '" onerror="this.src=\'https://via.placeholder.com/120\'">';
                    html += '    <div class="new-song-info"><div class="new-song-title">' + title + '</div><div class="new-song-artist">' + artist + '</div></div></div>';
                });
                $('#new-release-list').html(html);
            }
        });
    }

    // 2. 통합 검색 함수 (기존 searchMusic 기능 복구)
    function executeSearch(keyword) {
        if(!keyword) return;
        $('#musicList').html('<div class="search-empty">데이터 확인 중...</div>');
        $.get('/api/music/search', { keyword: keyword }, function(data) {
            var html = '';
            if(!data || data.length === 0) { 
                html = '<div class="search-empty"><p>DB에 없는 곡입니다.</p><button onclick="registerNewMusic(\'' + keyword.replace(/'/g, "\\'") + '\')" style="padding:8px 15px; background:#1db954; color:white; border:none; border-radius:5px; cursor:pointer;">유튜브 자동 등록</button></div>';
            } else {
                $.each(data, function(index, music) {
                    var m_title = (music.m_title || "제목없음").replace(/'/g, ""); 
                    var artist = (music.a_name || "").replace(/'/g, "");
                    html += '<div class="music-item" onclick="handleMusicClick(' + music.m_no + ', \'' + music.m_youtube_id + '\', \'' + m_title + '\', \'' + artist + '\')">';
                    html += '    <b>' + m_title + ' <small style="color:#888;">- ' + artist + '</small></b></div>';
                });
            }
            $('#musicList').html(html);
        });
    }

    // 3. 신규 곡 등록 (Spotify 수집이 여기서 트리거됨)
    function registerNewMusic(keyword) {
        $('#musicList').html('<div class="search-empty">Spotify 및 유튜브 정보를 수집 중...</div>');
        $.post('/api/music/register', { keyword: keyword }, function(res) {
            alert("수집 및 분석이 완료되었습니다!");
            executeSearch(keyword); 
        });
    }

    // 4. 차트 로드
    function loadTop100() {
        $.get('/api/music/top100', { u_no: currentUserNo }, function(data) {
            var html = '';
            if(!data || data.length === 0) {
                html = '<tr><td colspan="4" style="text-align:center; padding: 40px;">데이터가 없습니다.</td></tr>';
            } else {
                $.each(data, function(index, item) {
                    var previewHtml = item.PREVIEW_URL ? '<span class="preview-badge" onclick="event.stopPropagation(); playPreview(\'' + item.PREVIEW_URL + '\', this)">미리듣기</span>' : '';
                    var likeClass = (item.MY_LIKE > 0) ? 'active' : '';
                    var heartIcon = (item.MY_LIKE > 0) ? '♥' : '♡';
                    html += '<tr><td class="rank">' + (index + 1) + '</td>';
                    html += '<td><div style="display:flex; align-items:center;"><img src="' + (item.ALBUM_IMG || 'https://via.placeholder.com/50') + '" class="album-art"><div><div style="font-weight:600;">' + item.TITLE + previewHtml + '</div><div style="font-size:0.8rem; color:#888;">' + item.ARTIST + '</div></div></div></td>';
                    html += '<td><button class="btn-like ' + likeClass + '" onclick="toggleLike(' + item.MNO + ', this)">' + heartIcon + '</button><span class="play-cnt">' + item.CNT + '회</span></td>';
                    html += '<td><button class="btn-play" onclick="handleMusicClick(\'' + item.MNO + '\', \'' + item.YOUTUBE_ID + '\', \'' + item.TITLE + '\', \'' + item.ARTIST + '\')">▶</button></td></tr>';
                });
            }
            $('#top100-body').html(html);
            $('#update-time').text('최근 업데이트: ' + new Date().toLocaleTimeString());
        });
    }

    // 5. 좋아요 & 재생 관리 (기존 코드 그대로 복구)
    function toggleLike(m_no, btn) {
        if (currentUserNo <= 0) { alert("로그인이 필요합니다."); return; }
        $.post('/api/music/toggle-like', { m_no: m_no, u_no: currentUserNo }, function(res) {
            if (res.status === 'liked') { $(btn).addClass('active').text('♥'); } 
            else { $(btn).removeClass('active').text('♡'); }
        });
    }

    function handleMusicClick(m_no, videoId, title, artist) {
        stopPreview();
        
     // [추가] 상세 정보 수집 서버 호출 (이때 Spotify 데이터와 가사가 들어갑니다!)
        $.get('/api/music/detail', { m_no: m_no }, function(detail) {
            console.log("분석 데이터 수집 완료:", detail);
            // 여기서 detail.energy, detail.valence 등을 콘솔에서 확인해보세요!
        });
        
        var fullTitle = artist + " " + title;
        $('#now-playing-title').text(fullTitle);
        if (!videoId || videoId === "null" || videoId === "") {
            $.get('/api/music/update-youtube', { m_no: m_no, title: fullTitle }, function(res) {
                if(res !== "fail") loadVideo(m_no, res);
            });
        } else { loadVideo(m_no, videoId); }
    }

    function loadVideo(m_no, videoId) {
        currentMusicNo = Number(m_no);
        $('#player-container').fadeIn();
        if (!player) {
            player = new YT.Player('player', { height: '200', width: '350', videoId: videoId, playerVars: { 'autoplay': 1 }, events: { 'onStateChange': onPlayerStateChange } });
        } else { player.loadVideoById(videoId); }
    }

    function playPreview(url, element) {
        if (!audioPlayer.paused && audioPlayer.src === url) { stopPreview(); return; }
        stopPreview();
        audioPlayer.src = url; audioPlayer.play();
        $(element).text("중지 ■").addClass("playing");
        audioPlayer.onended = function() { stopPreview(); };
    }

    function stopPreview() { audioPlayer.pause(); $('.preview-badge').text("미리듣기").removeClass("playing"); }
    function stopYoutube() { if(player) player.stopVideo(); $('#player-container').fadeOut(); }
    function onPlayerStateChange(event) { if (event.data == YT.PlayerState.PLAYING) { sendPlayLog(); } }

    function sendPlayLog() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(pos) {
                var lat = pos.coords.latitude;
                var lon = pos.coords.longitude;
                var apiKey = "9021ce9b1f7a9ae39654c4cb2f33250a"; 
                $.get("https://api.openweathermap.org/data/2.5/weather?lat=" + lat + "&lon=" + lon + "&appid=" + apiKey, function(res) {
                    $.post('/api/music/history', { u_no: currentUserNo, m_no: currentMusicNo, h_location: Math.floor(lat), h_weather: res.weather[0].id }, function() { loadTop100(); });
                });
            });
        }
    }
</script>
</body>
</html>