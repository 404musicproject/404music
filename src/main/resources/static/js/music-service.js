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
	    // [수정] 데이터 키값 통합 (대소문자/언더바 대응)
	    const mNo = item.m_no || item.MNO || item.mNo || 0;
	    const rawTitle = item.m_title || item.TITLE || item.mTitle || 'Unknown';
	    const rawArtist = item.a_name || item.ARTIST || item.aName || 'Unknown';
	    
	    // 재생 시 전달할 이스케이프 문자 처리
	    const cleanTitle = rawTitle.replace(/'/g, "\\'");
	    const cleanArtist = rawArtist.replace(/'/g, "\\'");
	    
	    // 이미지 경로 처리
	    const imgUrl = item.b_image || item.ALBUM_IMG || item.bImage || '';
	    const highResImg = this.toHighResArtwork(imgUrl);

	    const isLiked = (item.isLiked === 'Y' || (item.MY_LIKE && item.MY_LIKE > 0));

	    return `
	        <tr onclick="MusicApp.playLatestYouTube('${cleanTitle}', '${cleanArtist}', '${imgUrl}')">
	            <td class="rank">${index + 1}</td>
	            <td>
	                <div style="display:flex; align-items:center;">
	                    <img src="${highResImg}" class="album-art" onerror="this.src='${this.FALLBACK_IMG}'">
	                    <div class="song-info">
	                        <div class="song-title">${rawTitle}</div>
	                        <div class="artist-name">${rawArtist}</div>
	                    </div>
	                </div>
	            </td>
	            <td style="text-align: center;">
	                <button class="btn-like ${isLiked ? 'active' : ''}" 
	                        style="color: ${isLiked ? '#ff0055' : '#666'}"
	                        onclick="event.stopPropagation(); MusicApp.toggleLike(${mNo}, this)">
	                    <i class="fa-${isLiked ? 'solid' : 'regular'} fa-heart"></i>
	                </button>
	            </td>
	            <td style="text-align: center;">
	                <button class="btn-add-lib" 
	                        style="background:none; border:none; color:#00f2ff; cursor:pointer;"
	                        onclick="event.stopPropagation(); MusicApp.addToLibrary(${mNo}, this)">
	                    <i class="fa-solid fa-plus-square"></i>
	                </button>
	            </td>
	            <td style="text-align: right; padding-right: 20px;">
	                <span class="play-cnt">${Number(item.CNT || 0).toLocaleString()}</span>
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
	            
				// 2. 상세 정보 로딩 (기존 곡이 있을 때만)
				            if (mNo > 0) {
				                $.get(this.basePath + '/api/music/detail', { m_no: mNo })
				                 .done(() => console.log("상세 정보 업데이트 완료"));
				            }
				            
				            // 3. [핵심] mNo가 0이든 아니든 무조건 로그 전송!
				            // title, artist, imgUrl을 함께 보내서 서버가 신규 등록을 할 수 있게 함
				            this.sendPlayLog(mNo, title, artist, imgUrl);
				            
				        },
	        error: (xhr) => {
	            console.error("API 호출 에러:", xhr.status, xhr.responseText);
	            alert("음악 검색 중 오류가 발생했습니다. (Error: " + xhr.status + ")");
	        }
	    });
	},
	parseMusicData: function(item) {
	    return {
	        mNo: item.m_no || item.MNO || item.mNo || 0,
	        title: item.TITLE || item.m_title || item.mTitle || 'Unknown Title', // 대문자 우선 체크
	        artist: item.ARTIST || item.a_name || item.aName || 'Unknown Artist', // 대문자 우선 체크
	        img: item.ALBUM_IMG || item.b_image || item.bImage || ''
	    };
	},
	// MusicApp 객체 내부의 sendPlayLog 함수 수정
	sendPlayLog: async function(mNo, title, artist, imgUrl) {
	    // this가 유실되지 않도록 미리 잡아둠
	    const self = this; 
	    
	    const postData = {
	        u_no: this.currentUserNo, 
	        m_no: mNo,
			title: title,    // [추가]
			artist: artist,  // [추가]
			imgUrl: imgUrl,  // [추가]
	        h_lat: 0, 
	        h_lon: 0,
	        h_weather: 800, // 기본값 설정
	        h_location: 'Unknown'
	    };

	    const getPosition = () => {
	        return new Promise((resolve, reject) => {
	            navigator.geolocation.getCurrentPosition(resolve, reject, {
	                enableHighAccuracy: true,
	                timeout: 5000
	            });
	        });
	    };

	    try {
	        const pos = await getPosition();
	        postData.h_lat = pos.coords.latitude;
	        postData.h_lon = pos.coords.longitude;

	        // [중요] 외부 API 대신 우리 서버의 /api/music/weather 호출
	        // (MusicController에 @GetMapping("/weather")를 추가한 상태여야 함)
	        const response = await fetch(`${this.basePath}/api/music/weather?lat=${postData.h_lat}&lon=${postData.h_lon}`);
	        
	        if (response.ok) {
	            const weatherData = await response.json();
	            // weatherData 구조는 OpenWeatherMap 응답 기준
	            postData.h_weather = weatherData.weather[0].id; 
	            postData.h_location = weatherData.name;
	        }

		} catch (error) {
		        console.warn("위치/날씨 정보 획득 실패:", error);
		    } finally {
		        // self 대신 MusicApp으로 직접 조준하면 더 확실합니다.
		        if (typeof MusicApp._submitLog === 'function') {
		            MusicApp._submitLog(postData, mNo);
		        } else {
		            console.error("_submitLog 함수를 찾을 수 없습니다.");
		        }
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