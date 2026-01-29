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
	lastWeatherData : null,
	lastWeatherId : 800,
	
	// 날씨 정보를 가져오는 함수
	getWeatherData: function(callback) {
	        if (navigator.geolocation) {
	            navigator.geolocation.getCurrentPosition((pos) => {
	                const lat = pos.coords.latitude;
	                const lon = pos.coords.longitude;
	                
	                // 서버의 날씨 API 호출
	                $.get(this.basePath + '/api/music/weather', { lat: lat, lon: lon }, (data) => {
	                    this.lastWeatherData = data;
	                    this.lastWeatherId = data.weather[0].id;

	                    // [추가] 화면 텍스트 업데이트 로직
	                    this.updateWeatherDisplay(data);

	                    if(callback) callback(data);
	                });
	            }, (err) => {
	                console.error("위치 정보 권한 거부", err);
	                $('#geo-weather-title').text("위치 비활성");
	                $('#geo-weather-desc').text("권한을 허용해주세요");
	            });
	        }
	    },

	    // [신규] 실제로 HTML 텍스트를 갈아끼우는 함수
	    updateWeatherDisplay: function(data) {
	        const city = data.name ? data.name.toUpperCase() : "UNKNOWN";
	        const weatherId = data.weather[0].id;
	        
	        let tagName = "맑음"; // 기본값
	        if (weatherId < 600) tagName = "비 오는 날";
	        else if (weatherId < 700) tagName = "눈 오는 날";
	        else if (weatherId > 800) tagName = "흐림";

	        // JSP에 설정한 ID들을 조준해서 텍스트 교체
	        $('#geo-city').text(city);
	        $('#geo-weather-title').text(tagName);
	        $('#geo-weather-desc').text("실시간 기상 맞춤 선곡");
	        
	        // 클릭 시 RecommendationController로 연결되도록 URL 업데이트
	        // Controller의 @GetMapping("/music/recommendationList") 경로 사용
	        const targetUrl = `${this.basePath}/music/recommendationList?tagName=${encodeURIComponent(tagName)}`;
	        $('#geo-weather-card').attr('onclick', `location.href='${targetUrl}'`);
	        
	        console.log("날씨 UI 업데이트 완료: ", tagName);
	    },
	
	init: function(uNo) {
	    this.currentUserNo = uNo || 0;
	    
	    // 제외할 페이지 경로에 artist/detail 추가
	    const isSearchPage = window.location.pathname.includes('musicSearch');
	    const isLibraryPage = window.location.pathname.includes('myLibrary');
	    const isArtistPage = window.location.pathname.includes('artist/detail'); // 추가
	    const isAlbumPage = window.location.pathname.includes('album/detail');   // 미리 추가 (나중을 위해)
	    
	    // 아티스트 페이지와 앨범 페이지도 차트 자동 로드에서 제외
	    if ($('#chart-body').length && !isSearchPage && !isLibraryPage && !isArtistPage && !isAlbumPage) { 
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
	        // 주소 앞에 슬래시(/)를 확인하세요. 
	        url: this.basePath + '/api/music/youtube-search', 
	        type: 'GET',
	        data: { q: query, title: title, artist: artist },
	        success: (res) => {
	            console.log("서버 응답 데이터:", res);
	            
	            // Controller가 Map을 리턴하므로 res.videoId로 접근
	            const videoId = res.videoId;
	            const mNo = res.mNo || 0; 

	            if (!videoId || videoId === 'fail') {
	                alert('유튜브 영상을 찾을 수 없습니다.');
	                return;
	            }

	            // 1. 즉시 재생 실행
	            if (window.PlayQueue && typeof window.PlayQueue.addAndPlay === 'function') {
	                console.log("즉시 재생 시작 - 비디오 ID:", videoId);
	                window.PlayQueue.addAndPlay(
	                    mNo, 
	                    title, 
	                    artist, 
	                    this.toHighResArtwork(imgUrl),
	                    videoId
	                );
	            }
	            
	            // 2. 상세 정보 로딩 및 재생 로그 전송 (백그라운드)
	            if (mNo > 0) {
	                // 상세 정보 수집 (Spotify 등)
	                $.get(this.basePath + '/api/music/detail', { m_no: mNo })
	                 .done(() => console.log("상세 정보 업데이트 완료"))
	                 .fail(() => console.log("상세 정보 수집 생략"));
	                
	                // 재생 로그 저장 (히스토리)
	                this.sendPlayLog(mNo);
	            }
	        },
	        error: (xhr) => {
	            console.error("API 호출 에러:", xhr.status, xhr.responseText);
	            alert("음악 검색 중 오류가 발생했습니다. (Error: " + xhr.status + ")");
	        }
	    });
	},

    sendPlayLog: async function(mNo) { 
		// 서버가 필요한 최소한의 정보(사용자, 곡ID, 위치)만 준비
		    const postData = {
		        u_no: this.currentUserNo, 
		        m_no: mNo,
		        h_lat: 0, 
		        h_lon: 0
		    };
		    
			   const API_KEY = '9021ce9b1f7a9ae39654c4cb2f33250a'; // 본인의 API Key 입력

			    // 1. 위치 정보 가져오기 (Promise화)
			    const getPosition = () => {
			        return new Promise((resolve, reject) => {
			            navigator.geolocation.getCurrentPosition(resolve, reject, {
			                enableHighAccuracy: true,
			                timeout: 5000
			            });
			        });
			    };

			    try {
			        // 위치 획득 시도
			        const pos = await getPosition();
			        postData.h_lat = pos.coords.latitude;
			        postData.h_lon = pos.coords.longitude;

			        // 2. 획득한 좌표로 OpenWeather API 호출
			        // [OpenWeather Current Weather API](https://openweathermap.org) 사용
					const weatherUrl =
					  `https://api.openweathermap.org/data/2.5/weather`
					  + `?lat=${postData.h_lat}`
					  + `&lon=${postData.h_lon}`
					  + `&appid=${API_KEY}`;
					  
			        const response = await fetch(weatherUrl);
			        if (response.ok) {
			            const weatherData = await response.json();
			            postData.h_weather = weatherData.weather[0].id; // 날씨 상태 코드 (예: 800)
			            postData.h_location = weatherData.name; // 도시 이름 (예: Seoul)
			        }

			    } catch (error) {
			        console.warn("위치 또는 날씨 정보를 가져오는데 실패했습니다.", error);
			        // 실패해도 초기 설정된 기본값(800, 0, 0)으로 로그는 남깁니다.
			    } finally {
			        // 3. 최종 로그 전송
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