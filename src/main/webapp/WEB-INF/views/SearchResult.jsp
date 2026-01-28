<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404 Music - 검색 결과</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://www.youtube.com/iframe_api"></script>
        <script src="${pageContext.request.contextPath}/js/music-service.js"></script>
    <style>
        body { font-family: 'Pretendard', sans-serif; background-color: #f8f9fa; color: #333; margin: 0; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; }
        
        .section { background: #fff; padding: 25px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        h2 { font-size: 1.4rem; margin-top: 0; color: #1db954; border-bottom: 2px solid #f1f1f1; padding-bottom: 15px; }

        .music-item { 
            display: flex; justify-content: space-between; align-items: center; 
            padding: 15px; border-bottom: 1px solid #eee; cursor: pointer; transition: 0.2s; 
        }
        .music-item:hover { background: #f9f9f9; transform: translateX(5px); }
        .artist-name { color: #888; font-size: 0.9rem; margin-left: 10px; }
        
        /* 📺 유튜브 플레이어 스타일 (고정형) */
        #player-container { 
            position: fixed; bottom: 20px; right: 20px; 
            background: #000; padding: 10px; border-radius: 12px; 
            display: none; z-index: 1000; box-shadow: 0 10px 30px rgba(0,0,0,0.5); 
        }
        #player-container h3 { color: #fff; font-size: 0.8rem; margin: 0 0 10px 0; font-weight: 400; }

        .btn-register { 
            margin-top: 15px; padding: 10px 20px; background: #1db954; 
            color: white; border: none; border-radius: 25px; cursor: pointer; font-weight: bold;
        }
        .search-empty { padding: 60px 20px; text-align: center; color: #999; }
    </style>
</head>
<body>
<header>
    <%@ include file="/WEB-INF/views/common/Header.jsp" %>
</header>

<div class="container">
    <div class="section">
        <h2>🔍 '${keyword}' 검색 결과</h2>
        <div id="musicList">
            <c:choose>
                <c:when test="${not empty musicList}">
                    <c:forEach var="music" items="${musicList}">
                        <div class="music-item" onclick="handleMusicClick('${music.m_no}', '${music.m_youtube_id}', '${music.m_title}', '${music.a_name}')">
                            <div class="music-info">
                                <b>${music.m_title}</b>
                                <span class="artist-name">${music.a_name}</span>
                            </div>
                            <div style="color: #1db954;">▶ 재생</div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="search-empty">
                        <p>검색 결과가 없습니다.</p>
                        <button class="btn-register" onclick="registerNewMusic('${keyword}')">유튜브 및 정보 자동 등록</button>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
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
    // 1. MusicApp 설정 (이게 없으면 JS가 경로를 못 찾고 유저를 모릅니다)
    window.contextPath = '${pageContext.request.contextPath}';
    
    $(document).ready(function() {
        // 세션에서 유저 번호 가져오기 (없으면 0)
        var userNo = "${sessionScope.user.u_no}" || "${sessionScope.userNo}" || 0;
        MusicApp.init(userNo); 
    });

    var player;
    var currentMusicNo = 0; 

    // 2. 곡 클릭 시 처리
function handleMusicClick(m_no, videoId, title, artist) {
    currentMusicNo = m_no; 
    var fullTitle = artist + " - " + title;
    $('#now-playing-title').text(fullTitle);

    // [중요] 서버에 상세 정보(가사, 특징) 요청 및 ES 업데이트 트리거
    // Controller의 @GetMapping("/detail")에서 파라미터명이 m_no이므로 이를 맞춰줍니다.
    $.get(window.contextPath + '/api/music/detail', { m_no: m_no }, function(data) {
        console.log("상세 정보 수집 및 ES 업데이트 완료:", data);
        // 필요하다면 여기서 가사를 화면에 뿌려주는 코드를 추가하세요.
        // 예: $('#lyrics-div').text(data.lyrics_text);
    }).fail(function() {
        console.error("상세 정보 수집 실패");
    });

    // 기존 유튜브 로직
    if (!videoId || videoId === "null" || videoId === "") {
        $.get(window.contextPath + '/api/music/update-youtube', { m_no: m_no, title: fullTitle }, function(newId) {
            if(newId !== "fail") loadVideo(newId);
            else alert("영상을 찾을 수 없습니다.");
        });
    } else {
        loadVideo(videoId);
    }
}
    function fetchMusicDetail(mNo) {
        $.get(window.contextPath + '/api/music/detail', { mNo: mNo }, function(data) {
            if (data) {
                console.log("상세 정보 수신 성공:", data);
                // 여기서 수신한 가사와 특징 데이터를 화면의 특정 영역에 넣어주어야 합니다.
                // 예: $('#lyrics-area').text(data.lyrics_text);
                // 예: $('#energy-val').text(data.energy);
            } else {
                console.log("상세 정보를 가져올 수 없습니다.");
            }
        }).fail(function() {
            console.error("상세 정보 요청 중 서버 에러 발생");
        });
    }

    function loadVideo(videoId) {
        $('#player-container').fadeIn();
        if (!player) {
            player = new YT.Player('player', {
                height: '200',
                width: '350',
                videoId: videoId,
                playerVars: { 'autoplay': 1 },
                events: { 'onStateChange': onPlayerStateChange }
            });
        } else {
            player.loadVideoById(videoId);
        }
    }

    // 3. [핵심] 재생 시작 시 MusicApp의 sendPlayLog 호출
    function onPlayerStateChange(event) {
        if (event.data == YT.PlayerState.PLAYING) {
            console.log("재생 로그 기록 시도... 곡 번호: " + currentMusicNo);
            
            if (currentMusicNo && currentMusicNo !== 0) {
                // 이미 선언된 MusicApp의 함수를 그대로 사용
                MusicApp.sendPlayLog(currentMusicNo);
            }
        }
    }

    function stopYoutube() { if(player) player.stopVideo(); $('#player-container').fadeOut(); }

    function registerNewMusic(keyword) {
        if(!keyword) return;
        $('#musicList').html('<div class="search-empty">데이터를 수집 중입니다...</div>');
        $.post(window.contextPath + '/api/music/register', { keyword: keyword }, function() {
            location.reload();
        });
    }
</script>
</body>
</html>