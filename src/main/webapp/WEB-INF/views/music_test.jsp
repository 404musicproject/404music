<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>실시간 음악 차트 및 빅데이터 분석</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://www.youtube.com/iframe_api"></script>
    <style>
        body { font-family: 'Pretendard', sans-serif; background-color: #f8f9fa; color: #333; margin: 0; padding: 20px; }
        .container { max-width: 1100px; margin: 0 auto; display: grid; grid-template-columns: 1fr 1.2fr; gap: 20px; }
        
        /* 대시보드 스타일 */
        .dashboard-section { grid-column: span 2; background: #fff; padding: 20px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); margin-bottom: 10px; }
        .new-release-wrapper {
            display: flex;
            gap: 15px;
            overflow-x: auto;
            padding: 10px 5px;
            min-height: 180px;
            scrollbar-width: thin;
        }
        .new-song-card { min-width: 130px; max-width: 130px; text-align: center; cursor: pointer; transition: 0.3s; flex-shrink: 0; }
        .new-song-card:hover { transform: translateY(-5px); }
        .new-song-card img { 
            width: 120px; 
            height: 120px; 
            border-radius: 15px; 
            object-fit: cover; 
            display: block; 
            margin: 0 auto;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }
        .new-song-info { margin-top: 8px; font-size: 0.85rem; width: 120px; margin: 8px auto 0; }
        .new-song-title { font-weight: bold; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .new-song-artist { color: #888; font-size: 0.75rem; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

        /* 공통 섹션 스타일 */
        .section { background: #fff; padding: 20px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        h2 { font-size: 1.2rem; margin-top: 0; color: #1db954; border-bottom: 2px solid #f1f1f1; padding-bottom: 10px; }

        .search-box { margin-bottom: 20px; display: flex; gap: 10px; }
        input[type="text"] { flex: 1; padding: 10px; border: 1px solid #ddd; border-radius: 5px; }
        button.btn-search { background: #1db954; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; }

        #musicList { max-height: 500px; overflow-y: auto; }
        .music-item { display: flex; align-items: center; padding: 12px; border-bottom: 1px solid #eee; cursor: pointer; transition: 0.2s; }
        .music-item:hover { background: #f9f9f9; transform: translateX(5px); }
        .music-item b { flex: 1; }

        .chart-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .chart-table th { font-size: 0.85rem; color: #888; padding: 10px; border-bottom: 1px solid #eee; text-align: left; }
        .chart-table td { padding: 12px 10px; border-bottom: 1px solid #f9f9f9; font-size: 0.9rem; }
        .rank { font-weight: bold; width: 30px; color: #1db954; font-style: italic; }
        .album-art { width: 45px; height: 45px; border-radius: 4px; margin-right: 12px; border: 1px solid #eee; }
        .play-cnt { color: #ff3d00; font-weight: bold; font-size: 0.8rem; background: #fff5f2; padding: 2px 6px; border-radius: 4px; margin-left: 5px; }
        
        #player-container { position: fixed; bottom: 20px; right: 20px; background: #000; padding: 10px; border-radius: 12px; display: none; z-index: 1000; box-shadow: 0 10px 30px rgba(0,0,0,0.5); border: 1px solid #333; }
        #player-container h3 { color: #fff; font-size: 0.8rem; margin: 0 0 10px 0; font-weight: 400; }

        .btn-play { background: #1db954; color: white; border: none; padding: 6px 10px; border-radius: 50%; cursor: pointer; width: 30px; height: 30px; line-height: 1; transition: 0.2s; }
        .btn-play:hover { background: #18a34a; transform: scale(1.1); }
        
        .preview-badge { font-size: 0.6rem; background: #ff1493; color: white; padding: 2px 5px; border-radius: 3px; margin-left: 5px; cursor: pointer; vertical-align: middle; }
        .preview-badge.playing { background: #333; font-weight: bold; }
        
        .btn-like { background: none; border: none; cursor: pointer; font-size: 1.2rem; color: #ccc; transition: 0.2s; padding: 0 5px; vertical-align: middle; outline: none; }
        .btn-like.active { color: #ff1493; }
    </style>
</head>
<body>

<div class="container">
    <div class="dashboard-section">
        <h2>✨ 한국 최신 발매 신곡 (iTunes Live)</h2>
        <div id="new-release-list" class="new-release-wrapper">
            <p style="padding:20px; color:#888;">최신 음악을 불러오는 중...</p>
        </div>
    </div>

    <div class="section">
        <h2>음악 검색 및 수집</h2>
        <div class="search-box">
            <input type="text" id="keyword" placeholder="가수 또는 곡명 입력">
            <button class="btn-search" onclick="searchMusic()">검색</button>
        </div>
        <div id="musicList">검색어를 입력하고 버튼을 눌러주세요.</div>
    </div>

    <div class="section">
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <h2>실시간 TOP 100 <small style="font-weight: normal; color: #888; font-size: 0.7rem;">(24시간 집계)</small></h2>
            <span id="update-time" style="font-size: 0.7rem; color: #999;"></span>
        </div>
        <table class="chart-table">
            <thead>
                <tr>
                    <th>순위</th>
                    <th>곡 정보</th>
                    <th>좋아요/조회</th>
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
    });

    // 1. iTunes API를 통한 최신곡 로드
    function loadNewReleases() {
        var url = "https://itunes.apple.com/search?term=2026&country=KR&entity=song&limit=15&sort=recent";

        $.ajax({
            url: url,
            dataType: 'jsonp',
            success: function(data) {
                var html = '';
                if (!data.results || data.results.length === 0) {
                    $('#new-release-list').html('<p style="padding:20px;">데이터가 없습니다.</p>');
                    return;
                }

                $.each(data.results, function(i, item) {
                    var title = item.trackName || "Unknown";
                    var artist = item.artistName || "Unknown Artist";
                    
                    var rawImg = item.artworkUrl100 || "";
                    var imgUrl = rawImg.replace("http://", "https://");
                    
                    // 이미지 차단 대비 대체 아바타
                    var fallbackImg = "https://ui-avatars.com/api/?background=random&color=fff&size=120&name=" + encodeURIComponent(artist);

                    var cleanTitle = title.replace(/'/g, "\\'");
                    var cleanArtist = artist.replace(/'/g, "\\'");

                    html += '<div class="new-song-card" onclick="quickSearch(\'' + cleanArtist + '\', \'' + cleanTitle + '\')">';
                    html += '    <img src="' + imgUrl + '" onerror="this.onerror=null; this.src=\'' + fallbackImg + '\';">';
                    html += '    <div class="new-song-info">';
                    html += '        <div class="new-song-title">' + title + '</div>';
                    html += '        <div class="new-song-artist">' + artist + '</div>';
                    html += '    </div>';
                    html += '</div>';
                });
                $('#new-release-list').html(html);
            }
        });
    }

    // 2. 대시보드 클릭 시 검색 연동
    function quickSearch(artist, title) {
	    // 1. 제목에서 (Feat. ), (Prod. ) 등 부가 정보 제거 (수집 성공률 향상)
	    // 괄호와 그 안의 내용을 지워주는 정규식입니다.
	    var cleanTitle = title.split('(')[0].split('-')[0].trim();
	    
	    // 2. 검색창에는 깔끔하게 '가수명 제목'만 입력
	    var searchKeyword = artist + " " + cleanTitle;
	    
	    $('#keyword').val(searchKeyword);
	    
	    // 3. 바로 검색 실행
	    searchMusic();
	}

    // 3. 음악 검색 (DB 연동)
    function searchMusic() {
	    var keyword = $('#keyword').val();
	    if(!keyword) { alert("검색어를 입력하세요."); return; }
	    
	    $('#musicList').html('<div style="padding:20px; text-align:center;">서버 데이터 확인 중...</div>');
	
	    $.get('/api/music/search', { keyword: keyword }, function(data) {
	        var html = '';
	        // 데이터가 아예 없거나 빈 배열일 때
	        if(!data || data.length === 0) { 
	            html = '<div style="padding:20px; text-align:center;">';
	            html += '    <p>우리 DB에 등록되지 않은 신곡입니다.</p>';
	            html += '    <button onclick="registerNewMusic(\'' + keyword.replace(/'/g, "\\'") + '\')" style="padding:8px 15px; background:#1db954; color:white; border:none; border-radius:5px; cursor:pointer;">';
	            html += '        유튜브에서 찾아오기 (자동 등록)';
	            html += '    </button>';
	            html += '</div>';
	        } else {
	            $.each(data, function(index, music) {
	                var m_no = music.m_no;
	                var m_title = (music.m_title || "제목없음").replace(/'/g, ""); 
	                var artist = (music.a_name || "").replace(/'/g, "");
	                var y_id = music.m_youtube_id || "";
	                
	                html += '<div class="music-item" onclick="handleMusicClick(' + m_no + ', \'' + y_id + '\', \'' + m_title + '\', \'' + artist + '\')">';
	                html += '    <b>' + m_title + ' <small style="color:#888;">- ' + artist + '</small></b>';
	                html += '</div>';
	            });
	        }
	        $('#musicList').html(html);
	    });
	}
	
	// DB에 없는 곡을 등록해주는 함수 (예시)
	function registerNewMusic(keyword) {
	    $('#musicList').html('<div style="padding:20px; text-align:center;">유튜브에서 정보를 수집 중입니다. 잠시만 기다려주세요...</div>');
	    
	    // 이 부분은 작성하신 백엔드 컨트롤러의 '등록' 주소에 맞게 수정해야 합니다.
	    // 예시: /api/music/register-by-keyword
	    $.post('/api/music/register', { keyword: keyword }, function(res) {
	        alert("신규 곡 등록이 완료되었습니다!");
	        searchMusic(); // 등록 후 다시 검색 시도
	    }).fail(function() {
	        alert("등록 중 오류가 발생했습니다. 수동 등록 기능을 이용해 주세요.");
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
                    var isLiked = item.MY_LIKE > 0;
                    var likeClass = isLiked ? 'active' : '';
                    var heartIcon = isLiked ? '♥' : '♡';

                    html += '<tr>';
                    html += '<td class="rank">' + (index + 1) + '</td>';
                    html += '<td><div style="display:flex; align-items:center;"><img src="' + (item.ALBUM_IMG || 'https://via.placeholder.com/50') + '" class="album-art" onerror="this.src=\'https://via.placeholder.com/50\'"><div><div style="font-weight:600; color:#333;">' + item.TITLE + previewHtml + '</div><div style="font-size:0.8rem; color:#888;">' + item.ARTIST + '</div></div></div></td>';
                    html += '<td><button class="btn-like ' + likeClass + '" onclick="toggleLike(' + item.MNO + ', this)">' + heartIcon + '</button><span class="play-cnt">' + item.CNT + '회</span></td>';
                    html += '<td><button class="btn-play" onclick="handleMusicClick(\'' + item.MNO + '\', \'' + item.YOUTUBE_ID + '\', \'' + item.TITLE + '\', \'' + item.ARTIST + '\')">▶</button></td>';
                    html += '</tr>';
                });
            }
            $('#top100-body').html(html);
            $('#update-time').text('최근 업데이트: ' + new Date().toLocaleTimeString());
        });
    }

    // 5. 좋아요 기능
    function toggleLike(m_no, btn) {
        if (currentUserNo <= 0) { alert("로그인이 필요한 서비스입니다."); return; }
        $(btn).css("transform", "scale(1.3)");
        $.post('/api/music/toggle-like', { m_no: m_no, u_no: currentUserNo }, function(res) {
            setTimeout(() => $(btn).css("transform", "scale(1)"), 200);
            if (res.status === 'liked') { $(btn).addClass('active').text('♥'); } 
            else if (res.status === 'unliked') { $(btn).removeClass('active').text('♡'); }
        });
    }

    // 6. 음악 클릭 시 재생 및 상세 정보 업데이트
    function handleMusicClick(m_no, videoId, title, artist) {
        stopPreview();
        var fullTitle = artist ? artist + " " + title : title;
        $('#now-playing-title').text(fullTitle);
        
        // 아이튠즈 정보 동기화 (장르, 이미지 등)
        updateMusicFromItunes(m_no, fullTitle);

        if (!videoId || videoId === "null" || videoId === "") {
            $.get('/api/music/update-youtube', { m_no: m_no, title: fullTitle }, function(res) {
                if(res !== "fail") loadVideo(m_no, res);
                else alert("영상을 찾을 수 없습니다.");
            });
        } else { loadVideo(m_no, videoId); }
    }

    function loadVideo(m_no, videoId) {
        currentMusicNo = Number(m_no);
        $('#player-container').fadeIn();
        if (!player) {
            player = new YT.Player('player', {
                height: '200', width: '350', videoId: videoId,
                playerVars: { 'autoplay': 1, 'enablejsapi': 1 },
                events: { 'onStateChange': onPlayerStateChange }
            });
        } else { player.loadVideoById(videoId); }
    }

    // 7. 미리듣기 기능
    function playPreview(url, element) {
        if (!audioPlayer.paused && audioPlayer.src === url) { stopPreview(); return; }
        stopPreview();
        if (player && player.getPlayerState && player.getPlayerState() === 1) { player.pauseVideo(); }
        audioPlayer.src = url;
        audioPlayer.play();
        $(element).text("중지 ■").addClass("playing");
        audioPlayer.onended = function() { stopPreview(); };
    }

    function stopPreview() {
        audioPlayer.pause();
        audioPlayer.src = "";
        $('.preview-badge').text("미리듣기").removeClass("playing");
    }

    function stopYoutube() {
        if(player) player.stopVideo();
        $('#player-container').fadeOut();
    }

    function onPlayerStateChange(event) {
        if (event.data == YT.PlayerState.PLAYING) { sendPlayLog(); }
    }

    // 8. 빅데이터 수집 (위치, 날씨 등)
    function sendPlayLog() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(pos) {
                var lat = pos.coords.latitude;
                var lon = pos.coords.longitude;
                var apiKey = "9021ce9b1f7a9ae39654c4cb2f33250a"; 
                var weatherUrl = "https://api.openweathermap.org/data/2.5/weather?lat=" + lat + "&lon=" + lon + "&appid=" + apiKey;
                $.get(weatherUrl, function(res) {
                    var weatherCode = res.weather[0].id; 
                    var locationCode = Math.floor(lat);
                    var logData = { u_no: parseInt(currentUserNo) || 0, m_no: parseInt(currentMusicNo) || 0, h_location: locationCode, h_weather: weatherCode };
                    $.post('/api/music/history', logData, function() { loadTop100(); });
                }).fail(function() { saveWithDefault(Math.floor(lat)); });
            });
        }
    }

    function saveWithDefault(loc) {
        var logData = { u_no: parseInt(currentUserNo) || 0, m_no: parseInt(currentMusicNo) || 0, h_location: loc, h_weather: 800 };
        $.post('/api/music/history', logData);
    }

    function updateMusicFromItunes(m_no, keyword) {
        const itunesUrl = "https://itunes.apple.com/search?term=" + encodeURIComponent(keyword) + "&entity=song&limit=1";
        $.ajax({
            url: itunesUrl, dataType: 'jsonp',
            success: function(data) {
                if (data.results.length > 0) {
                    const info = data.results[0];
                    const highResArt = info.artworkUrl100.replace("100x100bb", "600x600bb");
                    const updateData = { m_no: m_no, m_preview_url: info.previewUrl, b_image: highResArt, a_genres: info.primaryGenreName };
                    $.post('/api/music/update-extra', updateData);
                }
            }
        });
    }
</script>
</body>
</html>