<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script src="https://www.youtube.com/iframe_api"></script>
<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
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
    padding: 30px 0 120px 0; 
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
	
	.footer-copyright { font-size: 0.85rem; color: #555; }
	.footer-nav { display: flex; justify-content: center; align-items: center; gap: 15px; font-size: 0.8rem; }
	.neon-link { color: #888; text-decoration: none; transition: all 0.3s ease; }
	.neon-link:hover { color: #ff0055; text-shadow: 0 0 8px #ff0055; }
	.sep { color: #333; user-select: none; }
    
    /* [하단 플레이어 바] */
    .fixed-player-bar { position: fixed; bottom: 0; left: 0; width: 100%; height: 90px; background: #050505; border-top: 2px solid #ff0055; z-index: 9999; display: flex; align-items: center; justify-content: space-between; padding: 0 30px; box-sizing: border-box; }
    .progress-container { position: absolute; top: -2px; left: 0; width: 100%; height: 4px; background: rgba(255,0,85,0.2); cursor: pointer; }
    .progress-bar { height: 100%; background: #00f2ff; width: 0%; box-shadow: 0 0 5px #00f2ff; transition: width 0.1s linear; }
    /* 곡 정보 영역 (왼쪽) */
	.fp-info { 
	    display: flex; 
	    align-items: center; 
	    width: 25%; /* 너비 조정 */
	    gap: 15px; 
	    min-width: 200px; 
	}
	
	/* [신규] 좋아요/보관함 버튼 영역 (재생 버튼 왼쪽으로 이동) */
	.fp-actions {
	    display: flex;
	    gap: 20px;
	    align-items: center;
	    margin-right: 20px; /* 재생 컨트롤과의 간격 */
	}
	.fp-action-btn {
	    background: none;
	    border: none;
	    color: #555; /* 기본 색상 */
	    cursor: pointer;
	    font-size: 1.4rem; /* 크기 키움 */
	    transition: all 0.2s;
	    padding: 5px;
	    display: flex;
	    align-items: center;
	    justify-content: center;
	}
	.fp-action-btn:hover {
	    transform: scale(1.2);
	}
    .fp-art { width: 56px; height: 56px; border-radius: 4px; object-fit: cover; border: 1px solid #333; display: none; }
    .fp-text { display: flex; flex-direction: column; justify-content: center; min-height: 56px; }
    .fp-title { font-weight: bold; font-size: 0.95rem; color: #fff; display: block; max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .fp-artist { font-size: 0.8rem; color: #888; }
    .fp-ctrl { display: flex; gap: 20px; align-items: center; flex: 1; justify-content: center; }
    .fp-btn { background: none; border: none; color: #fff; font-size: 1.5rem; cursor: pointer; }
    .fp-side { width: 30%; display: flex; align-items: center; justify-content: flex-end; gap: 15px; }
	/* 하트가 활성화되었을 때 스타일 */
	/* 활성화 상태 */
	#player-like-btn.active { color: #ff0055 !important; filter: drop-shadow(0 0 5px #ff0055); }
	#player-lib-btn:hover { color: #00f2ff !important; filter: drop-shadow(0 0 5px #00f2ff); }
    /* [재생목록 창] */
    .playlist-window {
	    position: fixed;
	    bottom: 110px;
	    right: 30px;
	    width: 380px;
	    height: 450px;
	    background: rgba(10, 10, 10, 0.98);
	    border: 2px solid #ff0055;
	    border-radius: 12px;
	    box-shadow: 0 0 20px rgba(255, 0, 85, 0.4);
	    z-index: 9998;
	    display: none; 
	    flex-direction: column;
	    overflow: hidden;
	}
    .playlist-header { padding: 15px; background: #111; border-bottom: 1px solid #333; display: flex; justify-content: space-between; align-items: center; color: #ff0055; font-weight: bold; }
    
    .playlist-body { flex: 1; overflow-y: auto !important; padding: 10px; max-height: 380px; }
    .playlist-body::-webkit-scrollbar { width: 8px !important; display: block !important; }
    .playlist-body::-webkit-scrollbar-track { background: #000; }
    .playlist-body::-webkit-scrollbar-thumb { background: #ff0055; border-radius: 10px; border: 2px solid #000; }

    .playlist-item { display: flex; align-items: center; justify-content: space-between; padding: 10px; border-bottom: 1px solid rgba(255,255,255,0.05); cursor: pointer; }
    .playlist-item.active { background: rgba(255, 0, 85, 0.15); border-left: 3px solid #ff0055; }
    .pl-info { flex: 1; display: flex; align-items: baseline; gap: 8px; overflow: hidden; }
    .pl-title { font-size: 0.85rem; color: #eee; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .pl-artist { font-size: 0.75rem; color: #666; }

    /* [추가: 전체 삭제 버튼 스타일] */
    .clear-queue-btn {
        background: none; border: 1px solid #444; color: #888; font-size: 11px;
        padding: 3px 8px; border-radius: 4px; cursor: pointer; transition: all 0.2s;
        margin-right: 10px;
    }
    .clear-queue-btn:hover { border-color: #ff0055; color: #ff0055; box-shadow: 0 0 8px rgba(255,0,85,0.4); }

    /* [추가: 개별 삭제 버튼 마우스 오버] */
    .pl-remove-btn:hover { color: #ff0055 !important; transform: scale(1.1); }
	/* [재생목록 순서 변경 스타일] */
	/* 기존 playlist-item의 cursor는 기본으로 돌림 */
	/* [순서 변경 핸들 스타일] */
	.pl-handle {
	    cursor: grab;
	    color: #444;
	    padding: 0 10px 0 5px;
	    font-size: 1.1rem;
	    transition: color 0.2s;
	}
	.pl-handle:hover {
	    color: #ff0055; /* 호버 시 네온 핑크로 강조 */
	}
	.pl-handle:active {
	    cursor: grabbing;
	}
	.playlist-item {
	    cursor: default; 
	}

	/* 드래그 중인 아이템 스타일 */
	.ui-sortable-helper {
	    background: rgba(255, 0, 85, 0.3) !important;
	    box-shadow: 0 0 15px rgba(255, 0, 85, 0.5);
	    border: 1px solid #ff0055;
	}
	/* 이동될 위치 표시 */
	.ui-sortable-placeholder {
	    visibility: hidden !important; /* 공간은 차지하되 내용은 보이지 않음 */
	    height: 45px;
	}
    /* [챗봇] */
    #chatbot-btn { position: fixed; bottom: 110px; left: 30px; width: 60px; height: 60px; border-radius: 50%; background: #000; border: 2px solid #00f2ff; color: #00f2ff; font-size: 30px; cursor: pointer; z-index: 10001; display: flex; justify-content: center; align-items: center; box-shadow: 0 0 15px rgba(0,242,255,0.5); }
    #chat-window { 
	    display: none; 
	    flex-direction: column; 
	    position: fixed; 
	    bottom: 180px; 
	    left: 30px; 
	    width: 350px; 
	    height: 500px; 
	    background: rgba(10,10,10,0.98); 
	    border: 2px solid #00f2ff; 
	    border-radius: 15px; 
	    z-index: 10001; 
	    overflow: hidden; 
	}
	#chat-window.active {
	    display: flex !important;
	}
    .chat-header { background: #111; padding: 15px; border-bottom: 1px solid #333; display: flex; justify-content: space-between; color: #00f2ff; font-weight: bold; }
    .chat-body { flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 10px; }
    .msg { max-width: 80%; padding: 10px; border-radius: 12px; font-size: 0.9rem; }
    .msg.bot { align-self: flex-start; background: #222; color: #ddd; }
    .msg.user { align-self: flex-end; background: #00f2ff; color: #000; font-weight: bold; }
    .chat-input-area { padding: 15px; border-top: 1px solid #333; display: flex; gap: 10px; }
    #chat-input { flex: 1; background: #111; border: 1px solid #333; color: #fff; padding: 10px; border-radius: 20px; outline: none; }

 /* 컨테이너 가로 배치 설정 */
.video-box.side-by-side {
    width: 95%;          /* 화면 넓게 사용 */
    max-width: 1200px;
    height: 60vh;        /* 화면 높이의 60% 정도 사용 */
    display: flex;
    flex-direction: row; /* 가로 정렬 */
    background: #000;
    border: 2px solid #ff0055;
    box-shadow: 0 0 30px rgba(255, 0, 85, 0.4);
}

/* 왼쪽 영상 (유연하게 조절) */
.video-player-wrapper {
    flex: 1.5;           /* 영상 영역 비율 높임 */
    background: #000;
    display: flex;
    align-items: center;
    justify-content: center;
}

/* 오른쪽 가사창 */
.lyrics-view-side {
    flex: 1;             /* 가사 영역 비율 */
    background: #0a0a0a;
    border-left: 1px solid #ff0055;
    display: flex;
    flex-direction: column;
    overflow: hidden;
}

.lyrics-header {
    padding: 10px;
    background: #ff0055;
    color: #fff;
    font-size: 0.8rem;
    font-weight: bold;
    letter-spacing: 2px;
    text-align: center;
}

/* [가사창 스크롤바 디자인 - 플레이리스트와 동일하게] */
#lyricsContent {
    flex: 1;
    overflow-y: auto;
    overflow-x: hidden;
    /* 스크롤바 공간을 미리 확보하여 텍스트가 가려지지 않게 함 */
    padding: 40px 10px 40px 20px; 
    color: #fff;
    text-align: center;
    line-height: 2.8;
    font-size: 1.05rem;
    /* Firefox용 설정 */
    scrollbar-width: thin;
    scrollbar-color: #ff0055 transparent;
}
/* 1. 스크롤바 전체 너비 (플레이리스트와 동일하게 8px) */
#lyricsContent::-webkit-scrollbar {
    width: 8px !important;
    display: block !important;
}

/* 2. 스크롤바 트랙 (배경) - 투명하게 처리하여 붕 떠 있는 느낌 강조 */
#lyricsContent::-webkit-scrollbar-track {
    background: transparent; 
}

/* 3. 스크롤바 핸들 (움직이는 부분) - 네온 핑크 + 검정 테두리 */
#lyricsContent::-webkit-scrollbar-thumb {
    background: #ff0055;
    border-radius: 10px;
    /* 검정색 테두리를 살짝 주어 배경과 분리된 느낌을 줍니다 */
    border: 2px solid #0a0a0a; 
}

/* 마우스 올렸을 때 더 밝게 (옵션) */
#lyricsContent::-webkit-scrollbar-thumb:hover {
    background: #ff3377;
}
    /* 기본 상태: 화면 밖 (백그라운드 재생용) */
/* 1. 오버레이 기본 상태를 확실하게 숨김 */
#video-overlay {
    display: none; /* JS에서 제어하기 전까지는 절대 안 보이게 */
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background: rgba(0, 0, 0, 0.95);
    z-index: 10005;
    flex-direction: column;
    align-items: center;
    justify-content: center;
}

/* 2. 삐져나오는 현상 방지를 위해 플레이어 기본값 수정 */
.player-hidden { 
    display: none !important; /* 화면 밖으로 빼는 대신 아예 렌더링에서 제외 */
}

/* 3. 오버레이가 열렸을 때 내부 플레이어는 다시 보이게 */
#video-overlay #youtube-player {
    display: block !important;
    width: 100%;
    height: 100%;
}

/* 4. 컨테이너 높이 명시 (삐져나가지 않게) */
.video-box.side-by-side {
    display: flex;
    width: 90%;
    max-width: 1100px;
    height: 550px; /* 높이를 고정값으로 설정해서 레이아웃 붕괴 방지 */
    background: #000;
    border: 2px solid #ff0055;
    overflow: hidden; /* 내부 요소가 넘치지 않게 */
}
</style>

<div class="retro-popup-container" id="popup-area"></div>

<footer class="neon-footer">
    <div class="footer-container">
        <nav class="footer-nav">
            <a href="${pageContext.request.contextPath}/support/PrivacyPolicy" class="neon-link">개인정보처리방침</a>
            <span class="sep">|</span>
            <a href="${pageContext.request.contextPath}/support?mode=notice" class="neon-link">공지사항</a>
            <span class="sep">|</span>
            <a href="${pageContext.request.contextPath}/support?mode=inquiry" class="neon-link">1:1 문의</a>
            <span class="sep">|</span>
            <a href="${pageContext.request.contextPath}/support?mode=faq" class="neon-link">FAQ</a>
        </nav>
        <div class="footer-copyright"><p>Copyright © 2026 404Music Inc. 모든 권리 보유.</p></div>
    </div>
</footer>

<div id="playlist-window" class="playlist-window">
    <div class="playlist-header">
        <span>CURRENT QUEUE</span>
        <div style="display:flex; align-items:center;">
            <button class="clear-queue-btn" onclick="PlayQueue.clearAll()">CLEAR ALL</button>
            <button onclick="togglePlaylist()" style="background:none; border:none; color:#888; cursor:pointer; font-size:20px;">&times;</button>
        </div>
    </div>
    <div class="playlist-body" id="playlist-items"></div>
</div>

<div class="fixed-player-bar">
    <div class="progress-container" onclick="PlayQueue.seek(event)">
        <div class="progress-bar" id="progress-bar"></div>
    </div>
    
    <div class="fp-info">
        <img src="" class="fp-art" id="footer-art" onclick="toggleVideo(true)">
        <div class="fp-text">
            <span class="fp-title" id="footer-title">No Music</span>
            <span class="fp-artist" id="footer-artist">재생할 곡을 선택하세요</span>
        </div>
    </div>

    <div style="display: flex; align-items: center; justify-content: center; flex: 1;">
        <div class="fp-actions">
            <button id="player-like-btn" class="fp-action-btn" onclick="MusicAction.toggleLike(event)" title="좋아요">
			    <i class="far fa-heart"></i>
			</button>
			<button id="player-lib-btn" class="fp-action-btn" onclick="MusicAction.addToLibrary(event)" title="보관함 추가">
			    <i class="fas fa-plus-square"></i>
			</button>
        </div>

        <div class="fp-ctrl">
            <button class="fp-btn" onclick="PlayQueue.prev()"><i class="fas fa-step-backward"></i></button>
            <button class="fp-btn" onclick="PlayQueue.togglePlay()"><i class="fas fa-play" id="play-icon"></i></button>
            <button class="fp-btn" onclick="PlayQueue.next()"><i class="fas fa-step-forward"></i></button>
        </div>
    </div>

    <div class="fp-side">
        <button onclick="togglePlaylist()" style="background:none; border:none; color:#00f2ff; cursor:pointer; font-size:1.2rem;"><i class="fas fa-list-ul"></i></button>
        <span id="queue-status" style="color:#555; min-width:60px; text-align:right;">Queue: 0</span>
    </div>
</div>

<div id="video-overlay">
    <button onclick="toggleVideo(false)" style="align-self: flex-end; margin-right: 5%; color:#fff; background:none; border:none; cursor:pointer; font-size: 1.5rem; margin-bottom: 10px;">
        <i class="fas fa-times"></i> CLOSE VIDEO
    </button>

    <div class="video-box side-by-side">
        <div class="video-player-wrapper">
            <div id="youtube-player" class="player-hidden"></div>
        </div>
        
        <div id="lyricsView" class="lyrics-view-side">
            <div class="lyrics-header">LYRICS</div>
            <div id="lyricsContent" class="lyrics-content">
                가사를 불러오는 중...
            </div>
        </div>
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
var player = null;
var isPlayerReady = false;
var loginUserNo = "${loginUser != null ? loginUser.UNo : 0}";
var currentLyrics = []
// 1. YouTube IFrame API
window.onYouTubeIframeAPIReady = function () {
  player = new YT.Player("youtube-player", {
    height: "100%", width: "100%",
    playerVars: { autoplay: 1, controls: 1, origin: window.location.origin, enablejsapi: 1 },
    events: {
      onReady: function () { isPlayerReady = true; },
      onStateChange: onPlayerStateChange
    }
  });
};

function onPlayerStateChange(event) {
  if (event.data === YT.PlayerState.ENDED) { PlayQueue.next(); return; }
  if (event.data === YT.PlayerState.PLAYING) {
    PlayQueue.isPlaying = true;
    $("#play-icon").attr("class", "fas fa-pause");
  } else if (event.data === YT.PlayerState.PAUSED) {
    PlayQueue.isPlaying = false;
    $("#play-icon").attr("class", "fas fa-play");
  }
}

// 2. Music Action (좋아요 & 보관함)
var MusicAction = {
    checkLikeStatus: function(mNo) {
        var uNo = (typeof loginUserNo !== 'undefined') ? loginUserNo : 0;
        if (uNo == 0 || !mNo) {
            $("#player-like-btn").removeClass("active").find("i").attr("class", "far fa-heart");
            return;
        }

        $.get("/api/music/check-like", { m_no: mNo, u_no: uNo })
        .done(function(res) {
            var $btn = $("#player-like-btn");
            if (res.status === "liked" || res === "liked") {
                $btn.addClass("active").find("i").attr("class", "fas fa-heart");
            } else {
                $btn.removeClass("active").find("i").attr("class", "far fa-heart");
            }
        }).fail(function() {
            $("#player-like-btn").removeClass("active").find("i").attr("class", "far fa-heart");
        });
    },

    toggleLike: function(e) {
        if (e) e.stopPropagation(); 
        var currentSong = PlayQueue.list[PlayQueue.currentIndex];
        var uNo = (typeof loginUserNo !== 'undefined') ? loginUserNo : 0;

        if (uNo == 0) { alert("로그인이 필요합니다."); return; }
        if (!currentSong || !currentSong.mNo) { alert("곡 정보가 없습니다."); return; }

        $.post("/api/music/toggle-like", { m_no: currentSong.mNo, u_no: uNo })
        .done(function(res) {
            var $btn = $("#player-like-btn");
            if (res.status === "liked") {
                $btn.addClass("active").find("i").attr("class", "fas fa-heart");
            } else {
                $btn.removeClass("active").find("i").attr("class", "far fa-heart");
            }
        });
    },

    addToLibrary: function(e) {
        if (e) e.stopPropagation();
        var currentSong = PlayQueue.list[PlayQueue.currentIndex];
        var uNo = (typeof loginUserNo !== 'undefined') ? loginUserNo : 0;

        if (uNo == 0) { alert("로그인이 필요합니다."); return; }
        if (!currentSong || !currentSong.mNo) return;

        $.post("/api/music/add-library", { m_no: currentSong.mNo, u_no: uNo })
        .done(function(res) {
            if (res === "success") alert("보관함에 추가되었습니다! 🎵");
            else alert("이미 보관함에 있거나 추가에 실패했습니다.");
        });
    }
};

// 3. Play Queue
var PlayQueue = {
  list: [], currentIndex: -1, isPlaying: false,

  init: function () {
    var saved = localStorage.getItem("music_queue");
    if (saved) {
      try { this.list = JSON.parse(saved) || []; } catch (e) { this.list = []; }
      $("#queue-status").text("Queue: " + this.list.length);
      renderPlaylist();
    }
  },

  save: function () { localStorage.setItem("music_queue", JSON.stringify(this.list)); },

  addAndPlay: function (mNo, title, artist, img) {
    var exists = this.list.findIndex(function (s) { return s.title === title && s.artist === artist; });
    if (exists !== -1) { this.playIndex(exists); return; }

    var query = (artist && artist !== "Unknown") ? (artist + " " + title) : title;
    var self = this;

    $.get("/api/music/youtube-search", { q: query, title: title, artist: artist }, function (res) {
      var vId = (typeof res === "object") ? res.videoId : res;
      var finalMNo = (typeof res === "object" && res.mNo) ? res.mNo : mNo;

      if (vId && vId !== "fail") {
        self.list.push({ mNo: finalMNo, title: title, artist: artist, img: img, videoId: vId });
        self.save();
        $("#queue-status").text("Queue: " + self.list.length);
        self.playIndex(self.list.length - 1);
      } else { alert("영상을 찾을 수 없습니다."); }
    });
  },

  playIndex: function (idx) {
      if (idx < 0 || idx >= this.list.length) return;
      
      // 1. 플레이어 준비 상태 확인
      if (!isPlayerReady || !player || typeof player.loadVideoById !== "function") {
        this.retryPlay(idx, 0); 
        return;
      }
      
      this.currentIndex = idx;
      var song = this.list[idx];
      var targetMNo = song.mNo || song.m_no;

      // 2. 하단 플레이어 UI 업데이트
      $("#footer-title").text(song.title);
      $("#footer-artist").text(song.artist);
      if (song.img) $("#footer-art").attr("src", song.img).show();
      else $("#footer-art").hide();

      // 3. 좋아요 상태 체크 (비회원일 때는 내부 로직에서 처리됨)
      MusicAction.checkLikeStatus(targetMNo);

      // 4. ★ 재생 로그 기록 (비회원 0번도 전송하도록 수정) ★
      // uNo가 0이든 아니든 targetMNo(곡 번호)만 있다면 서버로 보냅니다.
      if (targetMNo) {
          $.post("/api/music/history", { 
              m_no: targetMNo, 
              u_no: loginUserNo // 0인 상태 그대로 전송
          }).done(function() {
              console.log("재생 기록 완료 (uNo: " + loginUserNo + ")");
          }).fail(function() {
              console.warn("로그 기록 실패 - 재생은 계속 진행됩니다.");
          });
      }

      // PlayQueue.playIndex 함수 내부
		if (targetMNo) {
		    $.get("/api/music/lyrics", { m_no: targetMNo })
		    .done(function(res) {
		    	if (res && res.lyrics_text) {
		    	    const cleanLyrics = res.lyrics_text
		    	                        .replace(/\[\d{2}:\d{2}\.\d{2,3}\]/g, "")
		    	                        .replace(/\n/g, "<br>");
		    	    
		    	    $("#lyricsContent").html(cleanLyrics);
		    	    $("#lyricsContent").scrollTop(0); // 부모가 아닌 실제 데이터가 담긴 div를 스크롤
		    	} else {
		            $("#lyricsContent").html("등록된 가사가 없습니다.");
		        }
		    })
		    .fail(function() {
		        $("#lyricsContent").html("가사 정보를 가져올 수 없습니다.");
		    });
		}
      var self = this;
      var playWithId = function (videoId) {
        try {
          player.loadVideoById(videoId);
          self.isPlaying = true;
          renderPlaylist(); // 현재 곡 강조 표시 업데이트
        } catch (e) { 
          console.error("재생 엔진 오류:", e); 
          self.next();
        }
      };

      // 5. 비디오 ID 유무에 따른 재생 분기
      if (!song.videoId) {
        // ID가 없으면 유튜브 검색 후 재생
        var query = (song.artist && song.artist !== "Unknown") ? (song.artist + " " + song.title) : song.title;
        $.get("/api/music/youtube-search", { q: query, title: song.title, artist: song.artist })
        .done(function (res) {
            var vId = (typeof res === "object") ? res.videoId : res;
            if (vId && vId !== "fail") {
              self.list[idx].videoId = vId;
              if (res.mNo) self.list[idx].mNo = res.mNo;
              self.save();
              playWithId(vId);
            } else { 
              console.error("영상을 찾을 수 없음");
              self.next(); 
            }
        });
      } else {
        // 이미 ID가 있으면 즉시 재생
        playWithId(song.videoId);
      }
    },
	//순서 변경 후 리스트 업데이트
  updateOrder: function() {
    var newList = [];
    var self = this;
    var currentSong = this.currentIndex !== -1 ? this.list[this.currentIndex] : null;

    // DOM 순서를 읽어와서 실제 리스트 재구성
    $("#playlist-items .playlist-item").each(function() {
        var originalIdx = $(this).data("idx");
        newList.push(self.list[originalIdx]);
    });

    this.list = newList;
    
    // 현재 재생 중인 곡의 인덱스 재찾기 (순서가 바뀌어도 재생은 유지)
    if (currentSong) {
        this.currentIndex = this.list.findIndex(s => s.videoId === currentSong.videoId);
    }
    
    this.save(); // 로컬스토리지 저장
    renderPlaylist(); // 인덱스 번호 동기화를 위해 다시 그림
  },
  retryPlay: function (idx, count) {
    if (isPlayerReady) this.playIndex(idx);
    else if (count < 20) setTimeout(() => this.playIndex(idx), 500);
  },

  next: function () { if (this.currentIndex < this.list.length - 1) this.playIndex(this.currentIndex + 1); },
  prev: function () { if (this.currentIndex > 0) this.playIndex(this.currentIndex - 1); },
  togglePlay: function () {
    if (!player || !player.getPlayerState) return;
    player.getPlayerState() === 1 ? player.pauseVideo() : player.playVideo();
  },
  seek: function (e) {
    var dur = player.getDuration();
    if (!dur) return;
    var pct = (e.clientX - $(".progress-container").offset().left) / $(".progress-container").width();
    player.seekTo(dur * pct, true);
  },
  remove: function (idx, e) {
    if (e) e.stopPropagation();
    this.list.splice(idx, 1);
    if (this.currentIndex >= idx) this.currentIndex--;
    if (this.currentIndex < 0 && this.list.length > 0) this.currentIndex = 0;
    this.save();
    $("#queue-status").text("Queue: " + this.list.length);
    renderPlaylist();
  },
  clearAll: function() {
    if(this.list.length === 0) return;
    if(!confirm("목록을 비우시겠습니까?")) return;
    if(player && typeof player.stopVideo === "function") player.stopVideo();
    this.list = []; this.currentIndex = -1; this.isPlaying = false;
    this.save();
    $("#footer-title").text("No Music"); $("#footer-artist").text("재생할 곡을 선택하세요"); 
    $("#footer-art").hide(); $("#queue-status").text("Queue: 0");
    renderPlaylist();
  }
};

// 4. UI Functions
function renderPlaylist() {
  var $container = $("#playlist-items").empty();
  if (PlayQueue.list.length === 0) {
    $container.append('<div style="padding:20px; text-align:center; color:#555;">비어 있습니다.</div>');
    return;
  }

  PlayQueue.list.forEach((song, idx) => {
    var isActive = (PlayQueue.currentIndex === idx);
    var $item = $("<div>").addClass("playlist-item").toggleClass("active", isActive)
                .attr("data-idx", idx);
    
    // [1] 왼쪽 순서 변경 핸들 추가 (≡ 아이콘)
    var $handle = $("<div>").addClass("pl-handle").html('<i class="fas fa-bars"></i>');
    
    // [2] 곡 정보 영역
    var $info = $("<div>").addClass("pl-info")
                .css("cursor", "pointer") // 정보 클릭 시 재생됨을 암시
                .append($("<span>").addClass("pl-title").text(song.title))
                .append($("<span>").addClass("pl-artist").text("- " + song.artist))
                .on("click", () => PlayQueue.playIndex(idx)); // 정보 클릭 시 재생
    
    // [3] 삭제 버튼
    var $removeBtn = $("<button>").addClass("pl-remove-btn")
                    .css({ background: "none", border: "none", color: "#444", cursor: "pointer" })
                    .html('<i class="fas fa-trash-alt"></i>')
                    .on("click", (e) => {
                        e.stopPropagation();
                        PlayQueue.remove(idx, e);
                    });

    // 아이템 구성: [핸들] + [정보] + [삭제]
    $item.append($handle).append($info).append($removeBtn);
    $container.append($item);
  });

  // [핵심] jQuery UI Sortable 설정 변경
  $container.sortable({
    axis: "y",
    handle: ".pl-handle", // ★ 이제 '≡' 아이콘을 잡아야만 이동 가능!
    placeholder: "ui-sortable-placeholder",
    update: function(event, ui) {
        PlayQueue.updateOrder();
    }
  }).disableSelection();
}

function togglePlaylist() { $("#playlist-window").fadeToggle(200); }
function toggleVideo(show) { 
    if(show) {
        // 열기: 숨김 클래스 제거 후 flex 적용
        $("#youtube-player").removeClass("player-hidden");
        $("#video-overlay").css("display", "flex").hide().fadeIn(300);
        $("#lyricsContent").scrollTop(0);
    } else {
        // 닫기: 페이드 아웃 후 완전히 숨김
        $("#video-overlay").fadeOut(300, function() {
            $(this).css("display", "none");
            $("#youtube-player").addClass("player-hidden");
        });
    }
}

//5. Chatbot Functions
function toggleChat() {
    $("#chat-window").fadeToggle(200).css("display", function(_, current) {
        return current === "none" ? "none" : "flex"; // flex 레이아웃 유지
    });
}

function sendChat() {
    var $input = $("#chat-input");
    var msg = $input.val().trim();
    if (msg === "") return;

    appendMessage("user", msg);
    $input.val("");

    // 로딩 표시 (선택 사항)
    var loadingId = "bot-loading-" + Date.now();
    $("#chat-body").append('<div class="msg bot" id="' + loadingId + '">생각 중... 🤖</div>');

    // [수정] 실제 Spring Boot 컨트롤러 호출
    $.ajax({
        url: "/api/chat/send", // 컨트롤러 @RequestMapping과 일치해야 함
        type: "POST",
        data: { msg: msg },    // 컨트롤러 @RequestParam("msg")와 일치해야 함
        success: function(response) {
            $("#" + loadingId).remove(); // 로딩 메시지 제거
            appendMessage("bot", response);
        },
        error: function(xhr) {
            $("#" + loadingId).remove();
            console.error("Chat Error:", xhr.responseText);
            appendMessage("bot", "⛔ 통신 중 오류가 발생했습니다. 다시 시도해주세요.");
        }
    });
}
function appendMessage(sender, text) {
    var $chatBody = $("#chat-body");
    var $msgDiv = $("<div>").addClass("msg " + sender).text(text);
    $chatBody.append($msgDiv);
    
    // 스크롤 최하단 이동
    $chatBody.scrollTop($chatBody[0].scrollHeight);
}

$(document).ready(function () {
	  PlayQueue.init();
	  let lastText = ""; // 이전 가사를 기억하기 위한 변수

	  setInterval(() => {
	    if (player && player.getCurrentTime && player.getDuration() > 0) {
	      const curr = player.getCurrentTime();
	      
	      // 재생바 업데이트
	      const pct = (curr / player.getDuration()) * 100;
	      $("#progress-bar").css("width", pct + "%");

	      // [가사 동기화]
	      if (currentLyrics.length > 0) {
	        let activeLine = currentLyrics.filter(l => l.time <= curr).pop();
	        if (activeLine && activeLine.text !== lastText) {
	          $("#lyric-display").text(activeLine.text);
	          lastText = activeLine.text; // 가사가 바뀔 때만 업데이트
	        }
	      }
	    }
	  }, 200);
	});

function parseLyrics(lyricStr) {
    if (!lyricStr) return [];
    const lines = lyricStr.split('\n');
    const pattern = /\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)/;
    const result = [];

    lines.forEach(line => {
        const match = line.match(pattern);
        if (match) {
            // 시간을 초 단위로 변환: (분 * 60) + 초 + (밀리초 / 1000)
            const time = parseInt(match[1]) * 60 + parseInt(match[2]) + parseInt(match[3]) / 1000;
            const text = match[4].trim();
            result.push({ time, text });
        }
    });
    return result;
}
</script>