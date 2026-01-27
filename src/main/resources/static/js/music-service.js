/**
 * 사이버 뮤직 차트 통합 서비스 모듈 (수정본)
 */
const MusicApp = {
    player: null,
    audioPlayer: new Audio(),
    currentMode: 'top100',
    selectedCity: '',
    currentUserNo: 0,
    latestLimit: 8,
    basePath: (window.contextPath || ''),
    FALLBACK_IMG: 'https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png',

    toHighResArtwork: function(url) {
        if (!url) return this.FALLBACK_IMG;
        return String(url).replace(/100x100bb/g, '600x600bb').replace(/100x100/g, '600x600');
    },

    init: function(uNo) {
        this.currentUserNo = uNo || 0;
        if ($('#chart-body').length) this.loadChart();
        if ($('#itunes-list').length) this.loadLatestSongs();
        this.initEventListeners();
    },

    initEventListeners: function() { console.log("MusicApp Service Started..."); },

    ensureYouTubeApi: function() {
        if (window.YT && window.YT.Player) return;
        if (!document.getElementById('yt-iframe-api')) {
            const tag = document.createElement('script');
            tag.id = 'yt-iframe-api';
            tag.src = 'https://www.youtube.com/iframe_api';
            document.head.appendChild(tag);
        }
    },

    loadLatestSongs: function() {
        const $container = $('#itunes-list');
        if (!$container.length) return;
        $container.html('<p style="color:#666; text-align:center; grid-column: 1/-1;">최신 데이터를 불러오는 중...</p>');

        $.ajax({
            url: this.basePath + '/api/music/rss/most-played',
            type: 'GET',
            data: { storefront: 'kr', limit: this.latestLimit },
            success: (data) => {
                if (!data || data.length === 0) {
                    $container.html('<p style="color:#888; text-align:center; grid-column: 1/-1;">데이터가 없습니다.</p>');
                    return;
                }
                let html = '';
                data.slice(0, this.latestLimit).forEach((music) => {
                    const title = music.TITLE || music.name || 'Unknown';
                    const artist = music.ARTIST || music.artistName || 'Unknown';
                    const rawImg = music.ALBUM_IMG || music.artworkUrl100 || music.b_image || '';
                    
                    // ✅ Home.jsp에서 보낼 때 이미지 URL도 포함하도록 수정 대응
                    html += '<div class="itunes-card" onclick="MusicApp.playLatestYouTube(\'' + title.replace(/'/g, "\\'") + '\', \'' + artist.replace(/'/g, "\\'") + '\', \'' + rawImg + '\')">'
                          + '  <div style="width: 100%; aspect-ratio: 1/1; border-radius: 8px; margin-bottom: 12px; background: #222; overflow: hidden;">'
                          + '    <img src="' + this.toHighResArtwork(rawImg) + '" style="width:100%; height:100%; object-fit:cover;" onerror="this.src=\'' + this.FALLBACK_IMG + '\';">'
                          + '  </div>'
                          + '  <div style="font-weight: bold; font-size: 0.85rem; color: #fff; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">' + title + '</div>'
                          + '  <div style="font-size: 0.75rem; color: #00f2ff; margin-top: 4px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">' + artist + '</div>'
                          + '</div>';
                });
                $container.hide().html(html).fadeIn(300);
            }
        });
    },

    // ✅ 핵심 수정: 검색 결과를 서버에 저장하도록 변경
    playLatestYouTube: function(title, artist, imgUrl) {
        const query = (artist && artist !== 'Unknown') ? (artist + ' ' + title) : title;
        this.ensureYouTubeApi();

        // 1. 서버의 youtube-search API는 검색과 동시에 DB에 곡 정보를 INSERT/UPDATE 해야 함
        $.ajax({
            url: this.basePath + '/api/music/youtube-search',
            type: 'GET',
            data: { q: query, title: title, artist: artist, albumImg: imgUrl }, // 상세 정보 함께 전송
            success: (res) => {
                const videoId = (typeof res === 'string') ? res : (res && res.videoId);
                const mNo = res.mNo || 0; // 서버에서 저장 후 반환된 mNo

                if (!videoId || videoId === 'fail') return alert('영상을 찾지 못했습니다.');

                // 2. 재생 실행
                this.playYoutube(mNo, videoId, title, artist);
                
                // 3. 히스토리 로그 강제 전송 (mNo가 있을 경우)
                if (mNo > 0) {
                    this.sendPlayLog(mNo);
                }
            }
        });
    },

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
        // (날씨 로직 동일하여 생략, 기존 코드 유지)
    },

    renderRow: function(item, index) {
        const isLiked = item.MY_LIKE > 0;
        const cleanTitle = (item.TITLE || '').replace(/'/g, "\\'");
        const cleanArtist = (item.ARTIST || '').replace(/'/g, "\\'");
        const imgUrl = this.toHighResArtwork(item.ALBUM_IMG || '');

        return `
            <tr onclick="MusicApp.playYoutube(${item.MNO}, '${item.YOUTUBE_ID}', '${cleanTitle}', '${cleanArtist}')">
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

    stopAll: function() {
        if (this.player && this.player.stopVideo) this.player.stopVideo();
        this.audioPlayer.pause();
        if ($('#player-container').length) $('#player-container').fadeOut();
    },

    playYoutube: function(mNo, yId, title, artist) {
        this.stopAll();
        if (!yId || yId === 'null') return;
        $('#now-playing-title').text(`${artist} - ${title}`);
        $('#player-container').fadeIn();

        if (!this.player) {
            this.player = new YT.Player('player', {
                height: '180', width: '320', videoId: yId,
                playerVars: { 'autoplay': 1 }
            });
        } else {
            this.player.loadVideoById(yId);
        }
        if (mNo > 0) this.sendPlayLog(mNo);
    },

    toggleLike: function(mNo, btn) {
        if (this.currentUserNo <= 0) return alert("로그인이 필요합니다.");
        $.post(this.basePath + '/api/music/toggle-like', { m_no: mNo, u_no: this.currentUserNo }, (res) => {
            if (res.status === 'liked') $(btn).addClass('active').text('♥');
            else $(btn).removeClass('active').text('♡');
        });
    },

    sendPlayLog: function(mNo) {
        const postData = {
            u_no: this.currentUserNo, m_no: mNo,
            h_location: this.selectedCity || 'UNKNOWN',
            h_weather: 800, h_lat: 0, h_lon: 0
        };
        const self = this;
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(pos) {
                postData.h_lat = pos.coords.latitude;
                postData.h_lon = pos.coords.longitude;
                $.get(`https://api.openweathermap.org/data/2.5/weather?lat=${postData.h_lat}&lon=${postData.h_lon}&appid=9021ce9b1f7a9ae39654c4cb2f33250a`, function(res) {
                    let lat = postData.h_lat;
                    if (lat >= 36.5) postData.h_location = 'SEOUL';
                    else if (lat >= 35.9) postData.h_location = 'DAEJEON';
                    else if (lat >= 35.5) postData.h_location = 'DAEGU';
                    else if (lat < 34.5) postData.h_location = 'JEJU';
                    else postData.h_location = 'BUSAN';
                    postData.h_weather = res.weather[0].id;
                    self._submitLog(postData, mNo);
                }).fail(() => self._submitLog(postData, mNo));
            }, () => self._submitLog(postData, mNo));
        } else {
            self._submitLog(postData, mNo);
        }
    },

    _submitLog: function(data, mNo) {
        $.post(this.basePath + '/api/music/history', data, () => {
            // 차트 페이지라면 숫자 업데이트
            const $row = $(`tr[onclick*="MusicApp.playYoutube(${mNo}"]`);
            const $cnt = $row.find('.play-cnt');
            if ($cnt.length) {
                let num = parseInt($cnt.text().replace(/,/g, '')) || 0;
                $cnt.text((num + 1).toLocaleString());
            }
        });
    }
};