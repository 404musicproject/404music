/**
 * 사이버 뮤직 차트 통합 서비스 모듈 (Full Version)
 */
window.MusicApp = {  // <--- const MusicApp 대신 이렇게 수정하세요!
    player: null,
    currentMode: 'top100',
    selectedCity: '',
    currentUserNo: 0,
    latestLimit: 8,
    basePath: (window.contextPath || ''),
    FALLBACK_IMG: 'https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png',

    init: function(uNo) {
        this.currentUserNo = uNo || 0;
        if ($('#chart-body').length) this.loadChart();
        this.initEventListeners();
    },

    initEventListeners: function() { console.log("MusicApp Integrated Service Started..."); },

    toHighResArtwork: function(url) {
        if (!url) return this.FALLBACK_IMG;
        return String(url).replace(/100x100bb/g, '600x600bb').replace(/100x100/g, '600x600');
    },

    // ---------------------------------------------------------
    // 1. 차트 관련 기능 (기존 기능 100% 유지)
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

        // 기존 차트 페이지에서 클릭 시에도 풋터 플레이어(PlayQueue)를 사용하도록 수정
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
                <td style="text-align: right; padding-right: 20px;">
                    <span class="play-cnt">${Number(item.CNT).toLocaleString()}</span>
                </td>
            </tr>`;
    },

    toggleLike: function(mNo, btn) {
        if (this.currentUserNo <= 0) return alert("로그인이 필요합니다.");
        $.post(this.basePath + '/api/music/toggle-like', { m_no: mNo, u_no: this.currentUserNo }, (res) => {
            if (res.status === 'liked') $(btn).addClass('active').text('♥');
            else $(btn).removeClass('active').text('♡');
        });
    },

    // ---------------------------------------------------------
    // 2. 재생 및 로그 통합 기능 (핵심)
    // ---------------------------------------------------------
    playLatestYouTube: function(title, artist, imgUrl) {
        const query = (artist && artist !== 'Unknown') ? (artist + ' ' + title) : title;
        
        $.ajax({
            url: this.basePath + '/api/music/youtube-search',
            type: 'GET',
            data: { q: query, title: title, artist: artist, albumImg: imgUrl },
			success: (res) => {
			    const videoId = (typeof res === 'string') ? res : (res && res.videoId);
			    const mNo = res.mNo || 0; 

			    if (!videoId || videoId === 'fail') return alert('영상을 찾지 못했습니다.');

			    // ✅ 푸터의 PlayQueue 시스템으로 데이터 전송
			    if (window.PlayQueue) {
			        // 푸터의 PlayQueue 구조에 맞춰 호출 (addAndPlay 사용)
			        window.PlayQueue.addAndPlay(
			            mNo, 
			            title, 
			            artist, 
			            this.toHighResArtwork(imgUrl)
			        );
			    }
			    
			    // ✅ DB에 로그 저장
			    if (mNo > 0) this.sendPlayLog(mNo);
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
                // 오픈웨더 API 호출 로직 (생략 가능하나 기존에 있었다면 유지)
                this._submitLog(postData, mNo);
            }, () => this._submitLog(postData, mNo));
        } else {
            this._submitLog(postData, mNo);
        }
    },

    _submitLog: function(data, mNo) {
        $.post(this.basePath + '/api/music/history', data, () => {
            // 차트 페이지의 숫자 실시간 업데이트
            const $row = $(`tr[onclick*="'${mNo}'"]`); 
            const $cnt = $row.find('.play-cnt');
            if ($cnt.length) {
                let num = parseInt($cnt.text().replace(/,/g, '')) || 0;
                $cnt.text((num + 1).toLocaleString());
            }
        });
    }
};