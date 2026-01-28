<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script src="https://www.youtube.com/iframe_api"></script>

<style type="text/css">
    /* [기본 스타일] */
    body { margin: 0; padding: 0; }
    
    /* 1. 레트로 팝업 (공지사항 등) */
    .retro-popup-container { position: fixed; top: 20px; left: 20px; z-index: 10000; display: flex; flex-direction: column; gap: 20px; }
    .retro-popup { background: rgba(10, 10, 10, 0.95); border: 2px solid #ff0055; width: 350px; padding: 0; box-shadow: 0 0 15px #ff0055; font-family: 'Courier New', monospace; animation: neonSlideIn 0.5s ease-out; }
    .retro-header { background: #ff0055; color: #ffffff; padding: 5px 12px; font-size: 13px; font-weight: bold; display: flex; justify-content: space-between; }
    .retro-content { padding: 15px; max-height: 250px; overflow-y: auto; color: #00f2ff; font-size: 14px; line-height: 1.6; }
    @keyframes neonSlideIn { from { transform: translateX(-100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }

    /* 2. 하단 네온 푸터 */
    .neon-footer { width: 100%; background-color: #000; padding: 20px 0 110px 0; border-top: 1px solid #333; text-align: center; color: #666; font-family: 'Pretendard', sans-serif; }
    .footer-nav { display: flex; gap: 15px; justify-content: center; font-size: 0.85rem; margin-bottom: 10px; }
    .neon-link { color: #888; text-decoration: none; transition: 0.3s; }
    .neon-link:hover { color: #00f2ff; text-shadow: 0 0 5px #00f2ff; }

    /* 3. 고정 플레이어 바 */
    .fixed-player-bar { position: fixed; bottom: 0; left: 0; width: 100%; height: 90px; background: #050505; border-top: 2px solid #ff0055; z-index: 9999; display: flex; align-items: center; justify-content: space-between; padding: 0 30px; box-sizing: border-box; }
    .progress-container { position: absolute; top: -2px; left: 0; width: 100%; height: 4px; background: rgba(255,0,85,0.2); cursor: pointer; }
    .progress-bar { height: 100%; background: #00f2ff; width: 0%; box-shadow: 0 0 5px #00f2ff; }
    .fp-info { display: flex; align-items: center; width: 30%; gap: 15px; }
    .fp-art { width: 56px; height: 56px; border-radius: 4px; object-fit: cover; border: 1px solid #333; cursor: pointer; }
    .fp-art:hover { border-color: #00f2ff; }
    .fp-title { font-weight: bold; font-size: 0.95rem; color: #fff; display: block; max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .fp-artist { font-size: 0.8rem; color: #888; }
    .fp-ctrl { display: flex; gap: 20px; align-items: center; flex: 1; justify-content: center; }
    .fp-btn { background: none; border: none; color: #fff; font-size: 1.5rem; cursor: pointer; }
    .fp-btn:hover { color: #00f2ff; }

    /* 4. 영상 팝업 레이어 */
    #video-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.95); z-index: 10005; flex-direction: column; align-items: center; justify-content: center; }
    .video-box { width: 80%; max-width: 900px; aspect-ratio: 16/9; background: #000; border: 2px solid #ff0055; position: relative; }
    #youtube-player { width: 100%; height: 100%; }
    /* 평상시 유튜브 숨김 처리 */
    .player-hidden { position: absolute; top: -9999px; left: -9999px; width: 1px; height: 1px; }

    /* 5. 챗봇 */
    #chatbot-btn { position: fixed; bottom: 110px; right: 30px; width: 60px; height: 60px; border-radius: 50%; background: #000; border: 2px solid #00f2ff; color: #00f2ff; font-size: 30px; cursor: pointer; z-index: 10001; display: flex; justify-content: center; align-items: center; box-shadow: 0 0 15px rgba(0,242,255,0.5); }
    #chat-window { display: none; flex-direction: column; position: fixed; bottom: 180px; right: 30px; width: 350px; height: 500px; background: rgba(10,10,10,0.98); border: 1px solid #00f2ff; border-radius: 15px; z-index: 10001; overflow: hidden; }
    .chat-header { background: #111; padding: 15px; border-bottom: 1px solid #333; display: flex; justify-content: space-between; color: #00f2ff; font-weight: bold; }
    .chat-body { flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 10px; }
    .msg { max-width: 80%; padding: 10px; border-radius: 12px; font-size: 0.9rem; }
    .msg.bot { align-self: flex-start; background: #222; color: #ddd; }
    .msg.user { align-self: flex-end; background: #00f2ff; color: #000; font-weight: bold; }
    .chat-input-area { padding: 15px; border-top: 1px solid #333; display: flex; gap: 10px; }
    #chat-input { flex: 1; background: #111; border: 1px solid #333; color: #fff; padding: 10px; border-radius: 20px; outline: none; }
</style>

<div class="retro-popup-container" id="popup-area"></div>

<footer class="neon-footer">
    <div class="footer-nav">
        <a href="#" class="neon-link">개인정보처리방침</a> <span style="color:#333">|</span>
        <a href="#" class="neon-link">공지사항</a> <span style="color:#333">|</span>
        <a href="#" class="neon-link">1:1 문의</a>
    </div>
    <p style="font-size:0.8rem;">Copyright © 2026 404Music Inc. All Rights Reserved.</p>
</footer>

<div class="fixed-player-bar">
    <div class="progress-container" onclick="PlayQueue.seek(event)">
        <div class="progress-bar" id="progress-bar"></div>
    </div>
    <div class="fp-info">
        <img src="https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png" class="fp-art" id="footer-art" onclick="toggleVideo(true)" title="영상 보기">
        <div class="fp-text">
            <span class="fp-title" id="footer-title">No Music</span>
            <span class="fp-artist" id="footer-artist">재생할 곡을 선택하세요</span>
            <button onclick="toggleVideo(true)" style="background:none; border:1px solid #ff0055; color:#ff0055; font-size:9px; cursor:pointer; margin-top:3px; padding:2px 5px;">WATCH VIDEO</button>
        </div>
    </div>
    <div class="fp-ctrl">
        <button class="fp-btn" onclick="PlayQueue.prev()"><i class="fas fa-step-backward"></i></button>
        <button class="fp-btn" onclick="PlayQueue.togglePlay()"><i class="fas fa-play" id="play-icon"></i></button>
        <button class="fp-btn" onclick="PlayQueue.next()"><i class="fas fa-step-forward"></i></button>
    </div>
    <div style="width: 30%; text-align: right; color: #555; font-size: 0.8rem;">
        <span id="queue-status">Queue: 0</span>
    </div>
</div>

<div id="video-overlay">
    <div class="video-box">
        <div id="youtube-player" class="player-hidden"></div>
        <button onclick="toggleVideo(false)" style="position:absolute; top:-40px; right:0; color:#fff; background:none; border:none; font-size:20px; cursor:pointer;">&times; CLOSE VIDEO</button>
    </div>
</div>

<div id="chatbot-btn" onclick="toggleChat()"><i class="fas fa-robot"></i></div>
<div id="chat-window">
    <div class="chat-header"><span>404 ASSISTANT</span><button onclick="toggleChat()" style="color:#666; border:none; background:none; cursor:pointer;">&times;</button></div>
    <div class="chat-body" id="chat-body"><div class="msg bot">안녕하세요! 404Music AI 비서입니다. 🎵</div></div>
    <div class="chat-input-area">
        <input type="text" id="chat-input" placeholder="메시지 입력..." onkeypress="if(event.keyCode==13) sendChat()">
        <button onclick="sendChat()" style="background:#00f2ff; border:none; width:40px; height:40px; border-radius:50%; cursor:pointer;"><i class="fas fa-paper-plane"></i></button>
    </div>
</div>

<script>
// [1. 유튜브 플레이어 로직]
var player;
function onYouTubeIframeAPIReady() {
    player = new YT.Player('youtube-player', {
        height: '100%', width: '100%',
        playerVars: { 'autoplay': 1, 'controls': 1, 'origin': window.location.origin },
        events: { 'onStateChange': onPlayerStateChange, 'onReady': onPlayerReady }
    });
}

function onPlayerReady(event) { console.log("Youtube Player Ready"); }

function onPlayerStateChange(event) {
    if (event.data === YT.PlayerState.ENDED) PlayQueue.next();
    if (event.data === YT.PlayerState.PLAYING) {
        PlayQueue.isPlaying = true;
        $('#play-icon').attr('class', 'fas fa-pause');
    } else {
        PlayQueue.isPlaying = false;
        $('#play-icon').attr('class', 'fas fa-play');
    }
}

// [2. 재생 큐 로직]
var PlayQueue = {
    list: [], currentIndex: -1, isPlaying: false,
    
    addAndPlay: function(mNo, title, artist, img) {
        let query = artist + " " + title;
        $.get('${pageContext.request.contextPath}/api/music/youtube-search', { 
            q: query, title: title, artist: artist, albumImg: img 
        }, function(res) {
            let vId = res.videoId || res;
            if(vId && vId !== 'fail') {
                // 1. 대기열에 추가
                PlayQueue.list.push({ title, artist, img, videoId: vId });
                $('#queue-status').text('Queue: ' + PlayQueue.list.length);
                
                // 2. [수정 포인트] 클릭하면 무조건 방금 추가한 마지막 곡(idx)으로 이동해서 재생
                PlayQueue.playIndex(PlayQueue.list.length - 1);
            }
        });
    },

    playIndex: function(idx) {
        if(idx < 0 || idx >= this.list.length) return;
        this.currentIndex = idx;
        let song = this.list[idx];

        // UI 업데이트
        $('#footer-title').text(song.title); 
        $('#footer-artist').text(song.artist); 
        $('#footer-art').attr('src', song.img);
        
        // 유튜브 재생 (강제 로드)
        if(player && player.loadVideoById) {
            player.loadVideoById(song.videoId);
            this.isPlaying = true; // 재생 상태 강제 설정
            $('#play-icon').attr('class', 'fas fa-pause'); // 아이콘 즉시 변경
        }
    },
    next: function() { if(this.currentIndex < this.list.length - 1) this.playIndex(this.currentIndex + 1); },
    prev: function() { if(this.currentIndex > 0) this.playIndex(this.currentIndex - 1); },
    togglePlay: function() {
        if(!player) return;
        if(player.getPlayerState() === 1) player.pauseVideo(); else player.playVideo();
    },
    seek: function(e) {
        if(!player || !player.getDuration) return;
        let pct = e.offsetX / $('.progress-container').width();
        player.seekTo(player.getDuration() * pct);
    }
};

// [3. 영상 팝업 토글]
function toggleVideo(show) {
    if(show) {
        $('#video-overlay').css('display', 'flex');
        $('#youtube-player').removeClass('player-hidden');
    } else {
        $('#video-overlay').hide();
        $('#youtube-player').addClass('player-hidden');
    }
}

// [4. 챗봇 로직]
function toggleChat() { $('#chat-window').fadeToggle(200).css('display', 'flex'); }
function sendChat() {
    let msg = $('#chat-input').val().trim(); if(!msg) return;
    $('#chat-body').append('<div class="msg user">'+msg+'</div>');
    $('#chat-input').val('');
    $.post('${pageContext.request.contextPath}/api/chat/send', { msg: msg }).done(function(res) {
        $('#chat-body').append('<div class="msg bot">'+res+'</div>');
        $('#chat-body').scrollTop($('#chat-body')[0].scrollHeight);
    });
}

// [5. 레트로 팝업 로직]
$(document).ready(function() {
    $.get('${pageContext.request.contextPath}/api/popup/list', function(list) {
        list.forEach(p => {
            let html = `<div class="retro-popup" id="pop-${p.pno}">
                <div class="retro-header"><span>NOTICE</span><button onclick="$('#pop-${p.pno}').remove()" style="background:none; border:none; color:white; cursor:pointer;">&times;</button></div>
                <div class="retro-content"><strong>${p.ptitle}</strong>${p.pcontent}</div>
            </div>`;
            $('#popup-area').append(html);
        });
    });
    
    // 재생바 업데이트
    setInterval(() => {
        if(player && player.getCurrentTime && PlayQueue.isPlaying) {
            let per = (player.getCurrentTime() / player.getDuration()) * 100;
            $('#progress-bar').css('width', per + '%');
        }
    }, 500);
});
</script>