/**
 * 사이버 뮤직 차트 통합 서비스 모듈 (Full Version - Library Fix)
 */
window.MusicApp = {
    player: null,
    currentMode: 'top100',
    selectedCity: '',
    currentUserNo: 0,
    latestLimit: 8,
    basePath: window.location.origin,
    FALLBACK_IMG: 'https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png',

	init: function(uNo) {
	    this.currentUserNo = uNo || 0;
	    
	    const isSearchPage = window.location.pathname.includes('musicSearch');
	    const isLibraryPage = window.location.pathname.includes('myLibrary');
	    const isArtistPage = window.location.pathname.includes('artist/detail');
	    const isAlbumPage = window.location.pathname.includes('album/detail');
	    
	    if ($('#chart-body').length && !isSearchPage && !isLibraryPage && !isArtistPage && !isAlbumPage) { 
	        this.loadChart(); 
	    }

	    // [여기에 추가!] 페이지가 로드될 때 iTunes 신곡 데이터를 가져오도록 명령
		if ($('#itunes-list').length) {
		        this.loadItunesMusic();
		    }
		    
		    // 이 줄에서 에러가 난다면 아래에 함수 정의가 있는지 확인하세요!
		    if (typeof this.initEventListeners === 'function') {
		        this.initEventListeners();
		    }
		},

		initEventListeners: function() { 
		    console.log("MusicApp Integrated Service Started..."); 
		},

    toHighResArtwork: function(url) {
        if (!url) return this.FALLBACK_IMG;
        return String(url).replace(/100x100bb/g, '600x600bb').replace(/100x100/g, '600x600');
    },

    // ---------------------------------------------------------
    // 1. 차트 관련 기능 (렌더링 로직)
    // ---------------------------------------------------------
    loadChart: function() {
        const endpoint = this.selectedCity ? 'regional' : this.currentMode;
        $.get(this.basePath + '/api/music/' + endpoint, { u_no: this.currentUserNo, city: this.selectedCity }, (data) => {
            let html = '';
            if (!data || data.length === 0) {
                html = '<tr><td colspan="4" style="text-align:center; padding: 50px; color:#555;">데이터가 없습니다.</td></tr>';
            } else {
                data.forEach((item, index) => { html += this.renderRow(item, index); });
            }
            $('#chart-body').html(html);
        });
    },

    renderRow: function(item, index) {
        const isLiked = item.MY_LIKE > 0;
        const cleanTitle = (item.TITLE || '').replace(/'/g, "\\'");
        const cleanArtist = (item.ARTIST || '').replace(/'/g, "\\'");
        const imgUrl = this.toHighResArtwork(item.ALBUM_IMG || '');

        return `
            <tr onclick="MusicApp.playLatestYouTube('${cleanTitle}', '${cleanArtist}', '${item.ALBUM_IMG}')">
                <td class="rank">${index + 1}</td>
                <td>
                    <div style="display:flex; align-items:center;">
                        <img src="${imgUrl}" class="album-art" onerror="this.src='${this.FALLBACK_IMG}'">
                        <div class="song-info">
                            <div class="song-title">${item.TITLE}</div>
                            <div class="artist-name">${item.ARTIST}</div>
                        </div>
                    </div>
                </td>
                <td style="text-align: center;">
                    <button class="btn-like ${isLiked ? 'active' : ''}" onclick="event.stopPropagation(); MusicApp.toggleLike(${item.MNO}, this)">
                        ${isLiked ? '♥' : '♡'}
                    </button>
                </td>
				<td style="text-align: center;">
													    <button class="btn-add-lib" title="라이브러리에 추가"
													            style="background:none; border:none; color:#00f2ff; cursor:pointer; font-size: 1.1rem;"
													            onclick="event.stopPropagation(); MusicApp.addToLibrary(${item.MNO}, this)">
													        <i class="fa-solid fa-plus-square"></i>
													    </button>
													</td>
                <td style="text-align: right; padding-right: 20px;">
                    <span class="play-cnt">${Number(item.CNT).toLocaleString()}</span>
                </td>
            </tr>`;
    },

    // ---------------------------------------------------------
    // 2. 좋아요 기능 (보관함 삭제 로직 제거)
    // ---------------------------------------------------------
	// music-service.js 내부의 toggleLike 수정 제안
	toggleLike: function(mNo, btn) {
	    if (this.currentUserNo <= 0) return alert("로그인이 필요합니다.");
	    
	    $.post(this.basePath + '/api/music/toggle-like', { m_no: mNo, u_no: this.currentUserNo }, (res) => {
	        const $btn = $(btn);
	        const $icon = $btn.find('i'); // 아이콘 요소 찾기
	        
	        if (res.status === 'liked') {
	            $btn.addClass('active').css('color', '#ff0055');
	            // FontAwesome 아이콘 클래스 교체 (빈 하트 -> 채워진 하트)
	            if($icon.length) {
	                $icon.removeClass('fa-regular').addClass('fa-solid');
	            } else {
	                $btn.text('♥');
	            }
	        } else {
	            $btn.removeClass('active').css('color', '#666');
	            // FontAwesome 아이콘 클래스 교체 (채워진 하트 -> 빈 하트)
	            if($icon.length) {
	                $icon.removeClass('fa-solid').addClass('fa-regular');
	            } else {
	                $btn.text('♡');
	            }
	        }
	    });
	},

    // ---------------------------------------------------------
    // 3. 재생 및 로그 통합 기능
    // ---------------------------------------------------------
	playLatestYouTube: function(title, artist, imgUrl) {
	    const query = (artist && artist !== 'Unknown') ? (artist + ' ' + title) : title;
	    console.log("유튜브 검색 쿼리:", query);

	    $.ajax({
	        url: this.basePath + '/api/music/youtube-search', 
	        type: 'GET',
	        data: { q: query, title: title, artist: artist, albumImg: imgUrl },
	        success: (res) => {
	            console.log("서버 응답 데이터:", res);
	            
	            // 응답이 'fail'이거나 데이터가 없을 때
	            if (!res || res === 'fail' || res.videoId === 'fail') {
	                console.error("유튜브 검색 결과가 없습니다.");
	                alert('현재 유튜브 검색 서버가 응답하지 않습니다. (API 할당량 초과 등)');
	                return;
	            }

	            const videoId = (typeof res === 'string') ? res : (res.videoId || res);
	            const mNo = res.mNo || 0; 

	            // 정상적인 Video ID가 왔을 때만 재생
	            if (window.PlayQueue && typeof window.PlayQueue.addAndPlay === 'function') {
	                window.PlayQueue.addAndPlay(
	                    mNo, 
	                    title, 
	                    artist, 
	                    this.toHighResArtwork(imgUrl)
	                );
	            }
	            
	            if (mNo > 0) this.sendPlayLog(mNo);
	        },
	        error: (xhr) => {
	            console.error("서버 통신 에러:", xhr.status);
	            alert("서버와 연결할 수 없습니다.");
	        }
	    });
	},

	sendPlayLog: function(mNo) {
	    const postData = {
	        u_no: this.currentUserNo, 
	        m_no: mNo,
	        h_location: 'UNKNOWN', 
	        h_weather: 800, 
	        h_lat: 0, 
	        h_lon: 0
	    };

	    const options = {
	        enableHighAccuracy: true, // 최대한 GPS/Wi-Fi 기반 정확도 높임
	        timeout: 5000,            // 5초 이내 응답 없으면 실패 처리
	        maximumAge: 0             // 캐시된 데이터 사용 안 함
	    };

	    if (navigator.geolocation) {
	        navigator.geolocation.getCurrentPosition(
	            (pos) => {
	                postData.h_lat = pos.coords.latitude;
	                postData.h_lon = pos.coords.longitude;
	                
	                // [선택 사항] 좌표를 행정구역(예: 서울 강남구)으로 변환하고 싶다면 
	                // 여기서 카카오 API 등을 호출한 뒤 _submitLog를 실행하세요.
	                this._submitLog(postData, mNo);
	            }, 
	            (err) => {
	                console.error("위치 획득 실패:", err.message);
	                this._submitLog(postData, mNo); // 실패 시 UNKNOWN으로 전송
	            },
	            options
	        );
	    } else {
	        this._submitLog(postData, mNo);
	    }
	},

    _submitLog: function(data, mNo) {
        $.post(this.basePath + '/api/music/history', data, () => {
            const $row = $(`tr[onclick*="'${mNo}'"]`); 
            const $cnt = $row.find('.play-cnt');
            if ($cnt.length) {
                let num = parseInt($cnt.text().replace(/,/g, '')) || 0;
                $cnt.text((num + 1).toLocaleString());
            }
        });
    },
	
	addToLibrary: function(mNo) {
	       // 이미 init에서 저장된 currentUserNo 사용
	       if (!this.currentUserNo || this.currentUserNo === 0) {
	           alert("로그인이 필요한 서비스입니다.");
	           return;
	       }

	       $.post(this.basePath + '/api/music/add-library', { 
	           m_no: mNo,
	           u_no: this.currentUserNo
	       })
	       .done((res) => {
	           alert("라이브러리에 추가되었습니다! 🎵");
	       })
	       .fail((err) => {
	           alert("이미 추가되었거나 오류가 발생했습니다.");
	       });
	   },
	   // --- 추가해야 할 코드 ---
	   // music-service.js 파일 내부 수정
	   loadItunesMusic: function() {
	       const $container = $('#itunes-list');
	       
	       // 1. 요청을 보내기 "직전"에 화면을 비웁니다. (섞임 방지 핵심)
	       $container.empty(); 

	       $.get(this.basePath + "/api/music/rss/new-releases", { limit: 8 }, (data) => {
	           // 2. 데이터가 없거나 서버 에러(500)로 빈 값이 왔을 때 처리
	           if (!data || data.length === 0) {
	               $container.html('<div style="color:#666; padding:20px;">현재 Apple 차트 서버 점검 중입니다.</div>');
	               return;
	           }
	           
	           let html = '';
	           data.forEach((m) => {
	               const t = (m.TITLE || 'Unknown').replace(/'/g, "\\'");
	               const a = (m.ARTIST || 'Unknown').replace(/'/g, "\\'");
	               const img = this.toHighResArtwork(m.ALBUM_IMG);
	               
	               html += `
	                   <div class="itunes-card" onclick="MusicApp.playLatestYouTube('${t}', '${a}', '${m.ALBUM_IMG}')">
	                       <img src="${img}" style="width:100%; aspect-ratio:1/1; object-fit:cover; border-radius:8px;" onerror="this.src='${this.FALLBACK_IMG}'">
	                       <div class="city-top-song" style="margin-top:10px;">${m.TITLE}</div>
	                       <div class="city-top-artist" style="color:#00f2ff;">${m.ARTIST}</div>
	                   </div>`;
	           });
	           
	           // 3. 새로 만든 8개만 삽입
	           $container.html(html);
	       }).fail(() => {
	           $container.html('<div style="color:#666; padding:20px;">차트를 불러올 수 없습니다.</div>');
	       });
	   }
};