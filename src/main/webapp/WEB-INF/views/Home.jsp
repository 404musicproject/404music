<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | Digital Archive</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/music-chart.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <style>
        body { background-color: #050505; color: #fff; font-family: 'Pretendard', sans-serif; overflow-x: hidden; margin: 0; }
        
        /* 1위 곡 배경 레이아웃 (Hero) */
        .hero-section {
            position: relative;
            height: 60vh;
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            border-bottom: 2px solid #ff0055;
        }

        #top1-bg {
            position: absolute;
            top: 0; left: 0; width: 100%; height: 100%;
            background-size: cover;
            background-position: center;
            filter: blur(20px) brightness(0.3);
            z-index: 1;
            transition: all 1s ease;
        }

        .hero-content {
            position: relative;
            z-index: 2;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        #top1-jacket {
            width: 250px;
            height: 250px;
            border-radius: 12px;
            box-shadow: 0 0 30px rgba(255, 0, 85, 0.5);
            border: 2px solid #ff0055;
            margin-bottom: 20px;
            object-fit: cover;
        }

        .top1-badge {
            background: #ff0055;
            padding: 4px 12px;
            font-weight: bold;
            font-size: 0.9rem;
            margin-bottom: 10px;
            letter-spacing: 2px;
        }

        /* 메인 메뉴 영역 */
        .menu-grid {
            max-width: 1000px;
            margin: -50px auto 50px;
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            padding: 0 20px;
            position: relative;
            z-index: 10;
        }

        .menu-card {
            background: #0a0a0a;
            border: 1px solid #00f2ff;
            padding: 30px 10px;
            text-align: center;
            text-decoration: none;
            color: #00f2ff;
            transition: all 0.3s;
            border-radius: 8px;
            display: flex;
            flex-direction: column;
            gap: 10px;
            cursor: pointer;
        }

        .menu-card:hover {
            background: rgba(0, 242, 255, 0.1);
            transform: translateY(-10px);
            box-shadow: 0 0 20px rgba(0, 242, 255, 0.4);
            color: #fff;
            border-color: #fff;
        }

        .menu-card .time-label { font-size: 0.7rem; opacity: 0.6; }
        .menu-card .title-label { font-size: 1.1rem; font-weight: bold; letter-spacing: 1px; }

        /* 지역별 섹션 */
        .location-section {
            max-width: 1000px;
            margin: 80px auto;
            padding: 0 20px;
        }
        
        .section-title {
            color: #ff0055;
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 30px;
            text-transform: uppercase;
            letter-spacing: 2px;
            border-left: 4px solid #ff0055;
            padding-left: 15px;
        }
        
        .location-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 15px;
        }
        
        .location-card {
            position: relative;
            height: 160px;
            background-color: #0a0a0a;
            background-size: cover;
            background-position: center;
            border: 1px solid #222;
            border-radius: 12px;
            transition: all 0.3s ease;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            justify-content: flex-end;
            padding: 15px;
            text-decoration: none;
            cursor: pointer;
        }

        .location-card::after {
            content: '';
            position: absolute;
            top: 0; left: 0; width: 100%; height: 100%;
            background: linear-gradient(to top, rgba(0,0,0,0.95) 10%, rgba(0,0,0,0.2) 90%);
            z-index: 1;
        }
        
        .location-card:hover {
            border-color: #ff0055;
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(255, 0, 85, 0.4);
        }

        .location-card > * { position: relative; z-index: 2; }
        
        .city-name {
            font-size: 0.8rem;
            color: #00f2ff;
            font-weight: bold;
            margin-bottom: 8px;
            display: block;
            text-shadow: 0 0 5px #000;
        }

        /* iTunes 카드 전용 호버 */
        .itunes-card {
            background: #111;
            padding: 15px;
            border-radius: 12px;
            border: 1px solid #222;
            transition: 0.3s;
            cursor: pointer;
        }
        .itunes-card:hover {
            transform: translateY(-5px);
            border-color: #ff0055 !important;
            box-shadow: 0 0 15px rgba(255, 0, 85, 0.3);
            background: #1a1a1a !important;
        }

        /* 지역별 카드 이미지 배경 */
        .card-seoul { background-image: url('${pageContext.request.contextPath}/img/location/seoul.jpg'); }
        .card-busan { background-image: url('${pageContext.request.contextPath}/img/location/busan.jpg'); }
        .card-daegu { background-image: url('${pageContext.request.contextPath}/img/location/daegu.jpg'); }
        .card-daejeon { background-image: url('${pageContext.request.contextPath}/img/location/daejeon.jpg'); }
        .card-jeju { background-image: url('${pageContext.request.contextPath}/img/location/jeju.jpg'); }
    </style>
</head>
<body>
<header><%@ include file="/WEB-INF/views/common/Header.jsp" %></header> 

<main>
    <section>
        <div class="hero-section">
            <div id="top1-bg"></div>
            <div class="hero-content">
                <div class="top1-badge">CURRENT NO.1</div>
                <img id="top1-jacket" src="" alt="Top Music">
                <h1 id="top1-title" style="margin: 0; font-size: 2rem; text-shadow: 0 0 10px #ff0055;">Loading...</h1>
                <p id="top1-artist" style="color: #888; margin-top: 5px;"></p>
            </div>
        </div>

        <div class="menu-grid">
            <a href="${pageContext.request.contextPath}/music/Index?type=top100" class="menu-card">
                <span class="time-label">REAL-TIME</span>
                <span class="title-label">DAILY</span>
            </a>
            <a href="${pageContext.request.contextPath}/music/Index?type=weekly" class="menu-card">
                <span class="time-label">7 DAYS</span>
                <span class="title-label">WEEKLY</span>
            </a>
            <a href="${pageContext.request.contextPath}/music/Index?type=monthly" class="menu-card">
                <span class="time-label">30 DAYS</span>
                <span class="title-label">MONTHLY</span>
            </a>
            <a href="${pageContext.request.contextPath}/music/Index?type=yearly" class="menu-card">
                <span class="time-label">365 DAYS</span>
                <span class="title-label">YEARLY</span>
            </a>
        </div>
    </section>

    <section class="container" style="margin-top: 50px;">
        <div class="section">
            <div class="chart-header">
                <div>
                    <h2 style="color: #00f2ff; text-shadow: 0 0 10px rgba(0, 242, 255, 0.5); margin:0;">NEW RELEASES</h2>
                    <p style="margin: 4px 0 0 0; color: #888; font-size: 0.8rem;">K-POP 마켓의 최신 트렌드를 확인하세요.</p>
                </div>
                <button class="tab-btn" onclick="loadItunesMusic()" style="font-size: 0.7rem; padding: 5px 15px;">REFRESH</button>
            </div>
            <div id="itunes-list" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 20px; margin-top: 10px;">
                </div>
        </div>
    </section>    

    <section class="location-section">
        <div class="section-title">Regional Top Hits</div>
        <div class="location-grid" id="regional-grid">
            <div class="location-card card-seoul" onclick="goRegional('SEOUL')">
                <span class="city-name">SEOUL</span>
                <div id="seoul-title" class="city-top-song">-</div>
                <div id="seoul-artist" class="city-top-artist">-</div>
            </div>
            <div class="location-card card-busan" onclick="goRegional('BUSAN')">
                <span class="city-name">BUSAN</span>
                <div id="busan-title" class="city-top-song">-</div>
                <div id="busan-artist" class="city-top-artist">-</div>
            </div>
            <div class="location-card card-daegu" onclick="goRegional('DAEGU')">
                <span class="city-name">DAEGU</span>
                <div id="daegu-title" class="city-top-song">-</div>
                <div id="daegu-artist" class="city-top-artist">-</div>
            </div>
            <div class="location-card card-daejeon" onclick="goRegional('DAEJEON')">
                <span class="city-name">DAEJEON</span>
                <div id="daejeon-title" class="city-top-song">-</div>
                <div id="daejeon-artist" class="city-top-artist">-</div>
            </div>
            <div class="location-card card-jeju" onclick="goRegional('JEJU')">
                <span class="city-name">JEJU</span>
                <div id="jeju-title" class="city-top-song">-</div>
                <div id="jeju-artist" class="city-top-artist">-</div>
            </div>
        </div>
    </section>
</main>

<footer><%@ include file="/WEB-INF/views/common/Footer.jsp" %></footer>

<script>
const contextPath = '${pageContext.request.contextPath}';

// 공통 fallback 이미지
const FALLBACK_IMG = 'https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png';

// ✅ Apple artworkUrl 고화질 변환 (100 -> 600)
function toHighResArtwork(url) {
  if (!url) return FALLBACK_IMG;
  return String(url)
    .replace(/100x100bb/g, '600x600bb')
    .replace(/100x100/g, '600x600');
}

// ✅ 최신곡 클릭 시: 유튜브 영상 열기 (새 탭)
function playLatestYouTube(title, artist) {
    console.log("전역 플레이어 연동 시도:", artist, title);

    // 1. 서버에 곡 정보 전달 및 수집 (MusicController의 search 연동)
    // 이 과정에서 DB에 곡이 없으면 저장하고, 유튜브 ID를 가져옵니다.
    $.ajax({
        url: contextPath + "/api/music/search",
        type: "GET",
        data: { keyword: artist + " " + title },
        success: function(data) {
            if (data && data.length > 0) {
                const music = data[0]; // 검색된 첫 번째 곡 (방금 저장된 곡)
                
                // 2. music-service.js에 정의된 전역 재생 함수 호출
                // 보통 musicService.play(music) 또는 전역 함수 playTrack(music) 형태일 겁니다.
                if (window.musicService && typeof window.musicService.playTrack === 'function') {
                    window.musicService.playTrack(music);
                } else if (typeof playTrack === 'function') {
                    playTrack(music);
                } else {
                    // 만약 전역 함수명을 모른다면 Index로 이동시켜 재생 유도 (차선책)
                    location.href = contextPath + '/music/Index?type=search&keyword=' + encodeURIComponent(artist + " " + title);
                }
            }
        },
        error: function() {
            alert("곡 정보를 가져오는 데 실패했습니다.");
        }
    });
}

// 1) (기존) 검색/이동 함수 - 필요하면 남겨두고, 최신곡에서는 안 씀
function playMusic(mNo, title) {
  console.log("곡 재생/검색 시도:", mNo, title);
  location.href = contextPath + '/music/Index?type=search&keyword=' + encodeURIComponent(title);
}

function goRegional(city) {
  location.href = contextPath + '/music/regional?city=' + city;
}

// 2) 상단 Hero (Top 1)
function loadTopOne() {
  $.get(contextPath + '/api/music/top100', function(data) {
    if (data && data.length > 0) {
      const top1 = data[0];

      const rawImg = top1.ALBUM_IMG || '';
      const imgUrl = toHighResArtwork(rawImg);

      $('#top1-bg').css('background-image', 'url(' + imgUrl + ')');
      $('#top1-jacket').attr('src', imgUrl);
      $('#top1-title').text(top1.TITLE || 'No Title');
      $('#top1-artist').text(top1.ARTIST || 'No Artist');
    }
  });
}

// 3) 지역별 프리뷰 로드
function loadRegionalPreviews() {
  const cities = ['SEOUL', 'BUSAN', 'DAEGU', 'DAEJEON', 'JEJU'];

  cities.forEach(city => {
    $.get(contextPath + '/api/music/regional', { city: city }, function(data) {
      if (data && data.length > 0) {
        const topSong = data[0];
        const idPrefix = city.toLowerCase();

        $('#' + idPrefix + '-title').text(topSong.TITLE || '-');
        $('#' + idPrefix + '-artist').text(topSong.ARTIST || '-');
      }
    });
  });
}

// 4) ✅ Apple RSS 최신곡/트렌드 로드 (고화질 + 8개)
function loadItunesMusic() {
  const $container = $('#itunes-list');
  const $btn = $('.tab-btn');

  $container.html('<p style="color:#666; text-align:center; grid-column: 1/-1;">서버에서 최신 데이터를 불러오는 중...</p>');
  $btn.prop('disabled', true);

  $.ajax({
    url: contextPath + "/api/music/rss/most-played",
    type: "GET",
    data: { storefront: "kr", limit: 8 }, // ✅ 서버에서 8개
    success: function(data) {
      if (!data || data.length === 0) {
        $container.html('<p style="color:#888; text-align:center; grid-column: 1/-1;">데이터가 없습니다.</p>');
        return;
      }

      let html = '';
      data.slice(0, 8).forEach(function(music) {  // ✅ 화면도 8개
        const title = music.TITLE || 'Unknown';
        const artist = music.ARTIST || 'Unknown';

        const rawImg = music.ALBUM_IMG || music.b_image || '';
        const imgUrl = toHighResArtwork(rawImg);

        // ✅ 클릭하면 검색페이지로 이동 X  → 유튜브 영상 재생(새탭)
        html += ''
          + '<div class="itunes-card" onclick="playLatestYouTube(\'' + title.replace(/'/g, "\\'") + '\', \'' + artist.replace(/'/g, "\\'") + '\')">'
          + '  <div style="width: 100%; aspect-ratio: 1/1; border-radius: 8px; margin-bottom: 12px; background: #222; overflow: hidden;">'
          + '    <img src="' + imgUrl + '" style="width:100%; height:100%; object-fit:cover;"'
          + '         onerror="this.src=\'' + FALLBACK_IMG + '\';">'
          + '  </div>'
          + '  <div style="font-weight: bold; font-size: 0.85rem; color: #fff; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">'
          +      title
          + '  </div>'
          + '  <div style="font-size: 0.75rem; color: #00f2ff; margin-top: 4px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">'
          +      artist
          + '  </div>'
          + '</div>';
      });

      $container.hide().html(html).fadeIn(300);
    },
    error: function() {
      $container.html('<p style="color:#ff0055; text-align:center; grid-column: 1/-1;">데이터 로딩 실패</p>');
    },
    complete: function() {
      $btn.prop('disabled', false);
    }
  });
}

$(document).ready(function() {
  loadTopOne();
  loadRegionalPreviews();
  loadItunesMusic();
});
</script>


</body>
</html>