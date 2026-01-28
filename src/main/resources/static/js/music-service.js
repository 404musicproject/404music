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
        
        // 검색 페이지나 보관함 페이지가 아닐 때만 차트를 자동 로드 (충돌 방지)
        const isSearchPage = window.location.pathname.includes('musicSearch');
        const isLibraryPage = window.location.pathname.includes('myLibrary');
        
        if ($('#chart-body').length && !isSearchPage && !isLibraryPage) { 
            this.loadChart(); 
        }
        
        this.initEventListeners();
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
    toggleLike: function(mNo, btn) {
        if (this.currentUserNo <= 0) return alert("로그인이 필요합니다.");
        
        $.post(this.basePath + '/api/music/toggle-like', { m_no: mNo, u_no: this.currentUserNo }, (res) => {
            const icon = $(btn).find('i'); // FontAwesome 아이콘 대응
            
            if (res.status === 'liked') {
                $(btn).addClass('active');
                // 아이콘 방식이면 아이콘 변경, 텍스트 방식이면 텍스트 변경 (둘 다 대응)
                if(icon.length) icon.removeClass('fa-regular').addClass('fa-solid').css('color', '#ff0055');
                else $(btn).text('♥');
            } else {
                $(btn).removeClass('active');
                if(icon.length) icon.removeClass('fa-solid').addClass('fa-regular').css('color', '#666');
                else $(btn).text('♡');
                
                // [수정] 보관함에서 사라지는 fadeOut 로직을 제거했습니다.
                // 이제 하트를 눌러도 목록에서 사라지지 않고 아이콘만 바뀝니다.
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
            u_no: this.currentUserNo, m_no: mNo,
            h_location: 'UNKNOWN', h_weather: 800, h_lat: 0, h_lon: 0
        };
        
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition((pos) => {
                postData.h_lat = pos.coords.latitude;
                postData.h_lon = pos.coords.longitude;
                this._submitLog(postData, mNo);
            }, () => this._submitLog(postData, mNo));
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
	   }
};