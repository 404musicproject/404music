<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script src="https://www.youtube.com/iframe_api"></script>

<style type="text/css">
    /* [기본 레이아웃] */
    body { margin: 0; padding: 0; }
    .retro-popup-container { position: fixed; top: 20px; left: 20px; z-index: 10000; display: flex; flex-direction: column; gap: 20px; }
    .retro-popup { background: rgba(10, 10, 10, 0.95); border: 2px solid #ff0055; width: 350px; padding: 0; box-shadow: 0 0 15px #ff0055; font-family: 'Courier New', monospace; animation: neonSlideIn 0.5s ease-out; }
    .retro-header { background: #ff0055; color: #ffffff; padding: 5px 12px; font-size: 13px; font-weight: bold; display: flex; justify-content: space-between; }
    .retro-content { padding: 15px; max-height: 250px; overflow-y: auto; color: #00f2ff; font-size: 14px; line-height: 1.6; }
    @keyframes neonSlideIn { from { transform: translateX(-100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }

    .neon-footer { 
    width: 100%; 
    background-color: #000; 
    padding: 30px 0 120px 0; /* 플레이어 바 높이를 고려한 하단 여백 */
    border-top: 1px solid #333; 
    text-align: center; 
    font-family: 'Pretendard', sans-serif; 
	}
	
	.footer-container {
	    max-width: 1200px;
	    margin: 0 auto;
	    display: flex;
	    flex-direction: column;
	    gap: 15px;
	}
	
	.footer-copyright {
	    font-size: 0.85rem;
	    color: #555;
	}
	
	.footer-nav {
	    display: flex;
	    justify-content: center;
	    align-items: center;
	    gap: 15px;
	    font-size: 0.8rem;
	}
	
	/* 네온 링크 스타일 */
	.neon-link {
	    color: #888;
	    text-decoration: none;
	    transition: all 0.3s ease;
	}
	
	.neon-link:hover {
	    color: #ff0055; /* 마우스 올리면 핑크 네온 */
	    text-shadow: 0 0 8px #ff0055;
	}
	
	.sep {
	    color: #333;
	    user-select: none;
	}
    
    /* [하단 플레이어 바] */
    .fixed-player-bar { position: fixed; bottom: 0; left: 0; width: 100%; height: 90px; background: #050505; border-top: 2px solid #ff0055; z-index: 9999; display: flex; align-items: center; justify-content: space-between; padding: 0 30px; box-sizing: border-box; }
    .progress-container { position: absolute; top: -2px; left: 0; width: 100%; height: 4px; background: rgba(255,0,85,0.2); cursor: pointer; }
    .progress-bar { height: 100%; background: #00f2ff; width: 0%; box-shadow: 0 0 5px #00f2ff; transition: width 0.1s linear; }
    
    .fp-info { display: flex; align-items: center; width: 30%; gap: 15px; min-width: 250px; }
    .fp-art { width: 56px; height: 56px; border-radius: 4px; object-fit: cover; border: 1px solid #333; display: none; }
    .fp-text { display: flex; flex-direction: column; justify-content: center; min-height: 56px; }
    .fp-title { font-weight: bold; font-size: 0.95rem; color: #fff; display: block; max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .fp-artist { font-size: 0.8rem; color: #888; }
    
    .fp-ctrl { display: flex; gap: 20px; align-items: center; flex: 1; justify-content: center; }
    .fp-btn { background: none; border: none; color: #fff; font-size: 1.5rem; cursor: pointer; }
    .fp-side { width: 30%; display: flex; align-items: center; justify-content: flex-end; gap: 15px; }

    /* [재생목록 창 - 오른쪽] */
    .playlist-window {
	    position: fixed;
	    bottom: 110px;
	    right: 30px;
	    width: 380px;
	    height: 450px; /* 고정 높이 유지 */
	    background: rgba(10, 10, 10, 0.98);
	    border: 2px solid #ff0055;
	    border-radius: 12px;
	    box-shadow: 0 0 20px rgba(255, 0, 85, 0.4);
	    z-index: 9998;
	    display: none; 
	    flex-direction: column; /* 세로 배치 */
	    overflow: hidden; /* 내부 요소가 경계선을 넘지 않도록 */
	}
    .playlist-header { padding: 15px; background: #111; border-bottom: 1px solid #333; display: flex; justify-content: space-between; color: #ff0055; font-weight: bold; }
    
    /* 스크롤바 핵심 수정 */
    .playlist-body { flex: 1; overflow-y: auto !important; padding: 10px; max-height: 380px; }
    .playlist-body::-webkit-scrollbar { width: 8px !important; display: block !important; }
    .playlist-body::-webkit-scrollbar-track { background: #000; }
    .playlist-body::-webkit-scrollbar-thumb { background: #ff0055; border-radius: 10px; border: 2px solid #000; }

    .playlist-item { display: flex; align-items: center; justify-content: space-between; padding: 10px; border-bottom: 1px solid rgba(255,255,255,0.05); cursor: pointer; }
    .playlist-item.active { background: rgba(255, 0, 85, 0.15); border-left: 3px solid #ff0055; }
    .pl-info { flex: 1; display: flex; align-items: baseline; gap: 8px; overflow: hidden; }
    .pl-title { font-size: 0.85rem; color: #eee; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .pl-artist { font-size: 0.75rem; color: #666; }

    /* [챗봇 - 왼쪽 이동] */
    #chatbot-btn { position: fixed; bottom: 110px; left: 30px; width: 60px; height: 60px; border-radius: 50%; background: #000; border: 2px solid #00f2ff; color: #00f2ff; font-size: 30px; cursor: pointer; z-index: 10001; display: flex; justify-content: center; align-items: center; box-shadow: 0 0 15px rgba(0,242,255,0.5); }
    #chat-window { display: none; flex-direction: column; position: fixed; bottom: 180px; left: 30px; width: 350px; height: 500px; background: rgba(10,10,10,0.98); border: 2px solid #00f2ff; border-radius: 15px; z-index: 10001; overflow: hidden; }
    .chat-header { background: #111; padding: 15px; border-bottom: 1px solid #333; display: flex; justify-content: space-between; color: #00f2ff; font-weight: bold; }
    .chat-body { flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 10px; }
    .msg { max-width: 80%; padding: 10px; border-radius: 12px; font-size: 0.9rem; }
    .msg.bot { align-self: flex-start; background: #222; color: #ddd; }
    .msg.user { align-self: flex-end; background: #00f2ff; color: #000; font-weight: bold; }
    .chat-input-area { padding: 15px; border-top: 1px solid #333; display: flex; gap: 10px; }
    #chat-input { flex: 1; background: #111; border: 1px solid #333; color: #fff; padding: 10px; border-radius: 20px; outline: none; }

    #video-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.95); z-index: 10005; flex-direction: column; align-items: center; justify-content: center; }
    .video-box { width: 80%; max-width: 900px; aspect-ratio: 16/9; background: #000; border: 2px solid #ff0055; position: relative; }
    .player-hidden { position: absolute; top: -9999px; left: -9999px; width: 1px; height: 1px; }
</style>

<div class="retro-popup-container" id="popup-area"></div>

    <footer class="neon-footer">
        <div class="footer-container">
            <div class="footer-copyright">
                <!-- 현재 날짜 2026년 기준 저작권 표시 -->
                <p>Copyright © 2026 404Music Inc. 모든 권리 보유.</p>
            </div>
            
            <nav class="footer-nav">
                <!-- 개인정보처리방침은 법적 고지사항이므로 단독 페이지 유지 권장 -->
                <a href="${pageContext.request.contextPath}/terms" class="neon-link">개인정보처리방침</a>
                <span class="sep">|</span>
                
                <!-- [수정] 통합 고객 센터의 NOTICE 탭으로 연결 -->
                <a href="${pageContext.request.contextPath}/support?mode=notice" class="neon-link">공지사항</a>
                <span class="sep">|</span>
                
                <!-- [수정] 통합 고객 센터의 INQUIRY 탭으로 연결 -->
                <a href="${pageContext.request.contextPath}/support?mode=inquiry" class="neon-link">1:1 문의</a>
                <span class="sep">|</span>
                
                <!-- [추가] 통합 고객 센터의 FAQ 탭으로 연결 -->
                <a href="${pageContext.request.contextPath}/support?mode=faq" class="neon-link">FAQ</a>
            </nav>
        </div>
    </footer>

<div id="playlist-window" class="playlist-window">
    <div class="playlist-header"><span>CURRENT QUEUE</span><button onclick="togglePlaylist()" style="background:none; border:none; color:#888; cursor:pointer;">&times;</button></div>
    <div class="playlist-body" id="playlist-items"></div>
</div>
>>>>>>> branch 'master' of https://github.com/404musicproject/404music.git

<div class="fixed-player-bar">
    <div class="progress-container" onclick="PlayQueue.seek(event)"><div class="progress-bar" id="progress-bar"></div></div>
    <div class="fp-info">
        <img src="" class="fp-art" id="footer-art" onclick="toggleVideo(true)">
        <div class="fp-text">
            <span class="fp-title" id="footer-title">No Music</span>
            <span class="fp-artist" id="footer-artist">재생할 곡을 선택하세요</span>
        </div>
    </div>
    <div class="fp-ctrl">
        <button class="fp-btn" onclick="PlayQueue.prev()"><i class="fas fa-step-backward"></i></button>
        <button class="fp-btn" onclick="PlayQueue.togglePlay()"><i class="fas fa-play" id="play-icon"></i></button>
        <button class="fp-btn" onclick="PlayQueue.next()"><i class="fas fa-step-forward"></i></button>
    </div>
    <div class="fp-side">
        <button onclick="togglePlaylist()" style="background:none; border:none; color:#00f2ff; cursor:pointer; font-size:1.2rem;"><i class="fas fa-list-ul"></i></button>
        <span id="queue-status" style="color:#555; min-width:60px; text-align:right;">Queue: 0</span>
    </div>
</div>

<div id="video-overlay">
    <div class="video-box">
        <div id="youtube-player" class="player-hidden"></div>
        <button onclick="toggleVideo(false)" style="position:absolute; top:-40px; right:0; color:#fff; background:none; border:none; cursor:pointer;">&times; CLOSE VIDEO</button>
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
var player;
var isPlayerReady = false;

window.onYouTubeIframeAPIReady = function() {
    player = new YT.Player('youtube-player', {
        height: '100%', width: '100%',
        playerVars: { 'autoplay': 1, 'controls': 1, 'origin': window.location.origin, 'enablejsapi': 1 },
        events: { 
            'onReady': function() { isPlayerReady = true; console.log("Player Ready"); },
            'onStateChange': onPlayerStateChange 
        }
    });
};

function onPlayerStateChange(event) {
    if (event.data === YT.PlayerState.ENDED) PlayQueue.next();
    if (event.data === YT.PlayerState.PLAYING) { PlayQueue.isPlaying = true; $('#play-icon').attr('class', 'fas fa-pause'); } 
    else { PlayQueue.isPlaying = false; $('#play-icon').attr('class', 'fas fa-play'); }
}

var PlayQueue = {
    list: [], currentIndex: -1, isPlaying: false,
    init: function() {
        const saved = localStorage.getItem('music_queue');
        if (saved) { this.list = JSON.parse(saved); $('#queue-status').text('Queue: ' + this.list.length); renderPlaylist(); }
    },
    save: function() { localStorage.setItem('music_queue', JSON.stringify(this.list)); },
    addAndPlay: function(mNo, title, artist, img) {
        let exists = this.list.findIndex(s => s.title === title && s.artist === artist);
        if (exists !== -1) { this.playIndex(exists); return; }
        let query = (artist && artist !== 'Unknown') ? (artist + ' ' + title) : title;
        $.get('/api/music/youtube-search', { q: query }, (res) => {
            let vId = (typeof res === 'object') ? res.videoId : res;
            if(vId && vId !== 'fail') {
                this.list.push({ mNo, title, artist, img, videoId: vId });
                this.save(); $('#queue-status').text('Queue: ' + this.list.length);
                if (this.currentIndex === -1 || !this.isPlaying) this.retryPlay(this.list.length - 1, 0);
                else renderPlaylist();
            }
        });
    },
    retryPlay: function(idx, count) {
        if (isPlayerReady && player && typeof player.loadVideoById === 'function') this.playIndex(idx);
        else if (count < 20) setTimeout(() => this.retryPlay(idx, count + 1), 500);
    },
    addOnly: function(mNo, title, artist, img) {
        // 이미 큐에 있는 곡은 추가하지 않습니다. (선택 사항)
        // let exists = this.list.findIndex(s => s.title === title && s.artist === artist);
        // if (exists !== -1) { return; } 

        // playAllLibrary에서 넘겨준 videoId를 어떻게 처리할지 불분명합니다. 
        // playAllLibrary 함수에서 videoId를 가져오는 코드가 없으므로, 
        // addOnly는 비디오 ID 없이 객체를 저장하고, 재생 시에 ID를 가져오도록 설계해야 합니다.

        this.list.push({ mNo, title, artist, img, videoId: null }); // videoId는 null로 저장
        this.save(); 
        $('#queue-status').text('Queue: ' + this.list.length);
        renderPlaylist(); // 재생 목록 UI 업데이트
    },
    playIndex: function(idx) {
        if(idx < 0 || idx >= this.list.length) return;
        if (!isPlayerReady || !player || typeof player.loadVideoById !== 'function') { this.retryPlay(idx, 0); return; }
        this.currentIndex = idx;
        let song = this.list[idx];
        
        // --- [수정된 핵심 로직: videoId가 없으면 서버에서 가져오기] ---
        if (!song.videoId) {
            let query = (song.artist && song.artist !== 'Unknown') ? (song.artist + ' ' + song.title) : song.title;
            $.get('/api/music/youtube-search', { q: query }, (res) => {
                let vId = (typeof res === 'object') ? res.videoId : res;
                if(vId && vId !== 'fail') {
                    this.list[idx].videoId = vId; // videoId 저장
                    this.save();
                    this.playIndex(idx); // ID 가져온 후 다시 재생 시도
                } else {
                    console.error("비디오 ID를 찾을 수 없습니다. 다음 곡으로 넘어갑니다.");
                    this.next(); 
                }
            });
            return; // ID를 가져오는 동안 현재 재생 중단
        }
        // --- [수정된 핵심 로직 끝] ---
        
        
        
        
        $('#footer-title').text(song.title); $('#footer-artist').text(song.artist); 
        if (song.img) $('#footer-art').attr('src', song.img).show();
        else $('#footer-art').hide().removeAttr('src');
        try { player.loadVideoById(song.videoId); this.isPlaying = true; renderPlaylist(); } catch(e) { console.error(e); }
    },
    next: function() { if(this.currentIndex < this.list.length - 1) this.playIndex(this.currentIndex + 1); },
    prev: function() { if(this.currentIndex > 0) this.playIndex(this.currentIndex - 1); },
    togglePlay: function() { if(!isPlayerReady) return; if(player.getPlayerState() === 1) player.pauseVideo(); else player.playVideo(); },
    seek: function(e) { if(!isPlayerReady || !player.getDuration) return; let pct = e.offsetX / $('.progress-container').width(); player.seekTo(player.getDuration() * pct); },
    remove: function(idx, event) { if(event) event.stopPropagation(); this.list.splice(idx, 1); this.save(); if (this.currentIndex >= idx) this.currentIndex--; $('#queue-status').text('Queue: ' + this.list.length); renderPlaylist(); }
};

function togglePlaylist() { $('#playlist-window').fadeToggle(200); if($('#playlist-window').is(':visible')) renderPlaylist(); }
function renderPlaylist() {
    const $container = $('#playlist-items'); $container.empty();
    if (PlayQueue.list.length === 0) { $container.append('<div style="padding:20px; text-align:center; color:#555;">비어 있습니다.</div>'); return; }
    PlayQueue.list.forEach((song, idx) => {
        const isActive = (PlayQueue.currentIndex === idx) ? 'active' : '';
        const titleColor = isActive ? '#ff0055' : '#eee';
        $container.append(`<div class="playlist-item \${isActive}" onclick="PlayQueue.playIndex(\${idx})"><div class="pl-info"><span class="pl-title" style="color:\${titleColor}">\${song.title}</span><span class="pl-artist">- \${song.artist}</span></div><button onclick="PlayQueue.remove(\${idx}, event)" style="background:none; border:none; color:#444;"><i class="fas fa-trash-alt"></i></button></div>`);
    });
}

function toggleVideo(show) { if(show) { $('#video-overlay').css('display', 'flex'); $('#youtube-player').removeClass('player-hidden'); } else { $('#video-overlay').hide(); $('#youtube-player').addClass('player-hidden'); } }
function toggleChat() { $('#chat-window').fadeToggle(200).css('display', 'flex'); }
function sendChat() {
    let msg = $('#chat-input').val().trim(); if(!msg) return;
    $('#chat-body').append('<div class="msg user">'+msg+'</div>'); $('#chat-input').val('');
    $.post('/api/chat/send', { msg: msg }).done(function(res) { $('#chat-body').append('<div class="msg bot">'+res+'</div>'); $('#chat-body').scrollTop($('#chat-body')[0].scrollHeight); });
}

$(document).ready(function() {
    PlayQueue.init();
    $.get('/api/popup/list').done(function(list) {
        if(list && Array.isArray(list)) {
            list.forEach(p => {
                let html = `<div class="retro-popup" id="pop-\${p.pno}"><div class="retro-header"><span>NOTICE</span><button onclick="$('#pop-\${p.pno}').remove()" style="background:none; border:none; color:white;">&times;</button></div><div class="retro-content"><strong>\${p.ptitle}</strong><br>\${p.pcontent}</div></div>`;
                $('#popup-area').append(html);
            });
        }
    }).fail(function() { console.log("ℹ️ 팝업 API 준비 중..."); });
    
    setInterval(() => { if(isPlayerReady && player && player.getCurrentTime && PlayQueue.isPlaying) { let per = (player.getCurrentTime() / player.getDuration()) * 100; $('#progress-bar').css('width', per + '%'); } }, 500);
});
</script>