<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | CHART</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/music-service.js"></script>

    <style>
        body { background-color: #050505; color: #fff; margin: 0; font-family: 'Pretendard', sans-serif; }
        main { display: flex; justify-content: center; padding: 60px 0 150px 0; }
        .container { width: 100%; max-width: 1100px; padding: 0 40px; }

        /* 헤더 디자인 */
        .chart-header-top { border-bottom: 2px solid #1a1a1a; margin-bottom: 30px; padding-bottom: 10px; position: relative; }
        .chart-header-top::after { 
            content: ''; position: absolute; bottom: -2px; left: 0; 
            width: 120px; height: 2px; background: #ff0055; box-shadow: 0 0 10px #ff0055; 
        }
        .sub-title { color: #ff0055; font-size: 0.85rem; font-weight: bold; text-transform: uppercase; letter-spacing: 1.5px; }
        .main-title { font-size: 2rem; margin: 10px 0; font-weight: 800; display: flex; align-items: baseline; gap: 12px; }
        .main-title span { color: #555; font-size: 0.9rem; font-weight: normal; }

        /* 탭 버튼 */
        .chart-tabs { display: flex; gap: 12px; margin-bottom: 45px; }
        .tab-btn { background: #151515; border: none; color: #666; padding: 10px 28px; cursor: pointer; border-radius: 4px; font-weight: bold; transition: 0.3s; }
        .tab-btn.active { background: #ff0055 !important; color: #fff !important; box-shadow: 0 0 15px rgba(255, 0, 85, 0.4); }

        /* 테이블 스타일 - SearchResult와 정렬 동기화 */
        .chart-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .chart-table thead tr { border-bottom: 1px solid #222; color: #555; text-align: left; }
        .chart-table th { padding: 15px; font-size: 0.75rem; text-transform: uppercase; }
        
        /* 컬럼 너비 및 텍스트 정렬 강제 */
        .col-rank { width: 50px; text-align: center !important; }
        .col-info { width: auto; }
        .col-btn  { width: 80px; text-align: center !important; }
        
        /* [수정] PLAY 헤더와 아이콘의 수직 정렬을 위해 padding-right 일치 */
        .col-play { width: 80px; text-align: right !important; padding-right: 30px !important; }

        /* 앨범 아트 및 효과 */
        .album-art { 
            width: 45px; height: 45px; object-fit: cover; border-radius: 4px; 
            margin-right: 15px; transition: 0.3s; cursor: pointer; flex-shrink: 0; 
        }
        .album-art:hover { filter: brightness(1.3); transform: scale(1.05); }

        .artist-link { cursor: pointer; transition: 0.2s; display: inline-block; }
        .artist-link:hover { color: #00f2ff !important; text-decoration: underline; }
        
        .play-trigger { color: #00f2ff; cursor: pointer; font-size: 1.5rem; transition: 0.2s; }
        .play-trigger:hover { transform: scale(1.2); text-shadow: 0 0 10px #00f2ff; }
    </style>

 <script>
    // 전역 변수로 관리할 데이터들
    const uNo = "${sessionScope.loginUser.uNo}" || 0;
    const contextPath = '${pageContext.request.contextPath}';

    $(document).ready(function() {
        console.log("1. Document Ready 시작 - uNo:", uNo);

        // 1. MusicApp 초기화
        MusicApp.init(Number(uNo));

        // 2. 탭 렌더링 (초기 렌더링 시 active 설정 포함)
        renderTabs();

        // 3. URL 파라미터 확인 및 초기 탭 활성화
        const urlParams = new URLSearchParams(window.location.search);
        const urlType = urlParams.get('type') || 'top100'; 
        
        MusicApp.currentMode = urlType;
        
        // 탭 버튼 상태 업데이트
        $('.tab-btn').removeClass('active');
        $('.tab-btn').each(function() {
            // onclick 속성에 해당 타입이 포함되어 있는지 확인
            if ($(this).attr('onclick').includes("'" + urlType + "'")) {
                $(this).addClass('active');
            }
        });

        // 4. 제목 동적 변경 (선택사항)
        const titles = { 'top100': '실시간', 'weekly': '주간', 'monthly': '월간', 'yearly': '연간' };
        $('.main-title span').text((titles[urlType] || '실시간') + ' 음악 순위');

        // 5. 차트 데이터 로드
        MusicApp.loadChart();
    });

    // 탭 렌더링 함수
    function renderTabs() {
        const html = '<button class="tab-btn" onclick="changeTab(\'top100\', this)">Real-time</button>' +
                     '<button class="tab-btn" onclick="changeTab(\'weekly\', this)">Weekly</button>' +
                     '<button class="tab-btn" onclick="changeTab(\'monthly\', this)">Monthly</button>' +
                     '<button class="tab-btn" onclick="changeTab(\'yearly\', this)">Yearly</button>';
        $('.chart-tabs').html(html);
    }

    // 탭 변경 함수
    function changeTab(mode, btn) {
        $('.tab-btn').removeClass('active');
        $(btn).addClass('active');
        
        MusicApp.currentMode = mode;
        
        // 주소창 파라미터 업데이트 (새로고침 없이)
        const newUrl = window.location.pathname + '?type=' + mode;
        window.history.pushState({ path: newUrl }, '', newUrl);

        // 제목 변경
        const titles = { 'top100': '실시간', 'weekly': '주간', 'monthly': '월간', 'yearly': '연간' };
        $('.main-title span').text(titles[mode] + ' 음악 순위');
        
        MusicApp.loadChart();
    }

    // 데이터 렌더링 로직 (MusicApp 객체 확장)
    MusicApp.renderRow = function(item, index) {
        const mNo = item.MNO || item.m_no || 0;
        const bNo = item.BNO || item.b_no || 0;
        const aNo = item.ANO || item.a_no || 0;
        
        const rawTitle = item.TITLE || item.m_title || 'Unknown Title';
        const rawArtist = item.ARTIST || item.a_name || 'Unknown Artist';
        
        const titleForJS = String(rawTitle).replace(/'/g, "\\'");
        const artistForJS = String(rawArtist).replace(/'/g, "\\'");
        
        let albumImg = item.ALBUM_IMG || item.b_image || 'https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png';
        if(albumImg.includes('100x100')) {
            albumImg = albumImg.replace('100x100bb', '600x600bb').replace('100x100', '600x600');
        }

        const isLiked = (item.isLiked === 'Y' || (item.MY_LIKE && item.MY_LIKE > 0));

        return '<tr onclick="MusicApp.playLatestYouTube(\'' + titleForJS + '\', \'' + artistForJS + '\', \'' + albumImg + '\');" ' +
               'style="border-bottom: 1px solid #111; cursor: pointer; transition: 0.2s;">' +
            '<td class="col-rank">' + (index + 1) + '</td>' +
            '<td>' +
                '<div style="display: flex; align-items: center; padding: 10px 0;">' +
                    '<img src="' + albumImg + '" class="album-art" onclick="event.stopPropagation(); location.href=\'' + contextPath + '/album/detail?b_no=' + bNo + '\'">' +
                    '<div style="margin-left:10px;">' +
                        '<div style="font-weight: bold; color: #eee;">' + rawTitle + '</div>' +
                        '<div class="artist-link" style="font-size: 0.85rem; color: #888;" onclick="event.stopPropagation(); location.href=\'' + contextPath + '/artist/detail?a_no=' + aNo + '\'">' +
                            rawArtist +
                        '</div>' +
                    '</div>' +
                '</div>' +
            '</td>' +
            '<td style="text-align: center;">' +
                '<button style="background:none; border:none; cursor:pointer; color: ' + (isLiked ? '#ff0055' : '#444') + ';" ' +
                        'onclick="event.stopPropagation(); MusicApp.toggleLike(' + mNo + ', this);">' +
                    '<i class="fa-' + (isLiked ? 'solid' : 'regular') + ' fa-heart"></i>' +
                '</button>' +
            '</td>' +
            '<td style="text-align: center;">' +
                '<button style="background:none; border:none; color:#00f2ff; cursor:pointer;" onclick="event.stopPropagation(); MusicApp.addToLibrary(' + mNo + ');">' +
                    '<i class="fa-solid fa-plus-square"></i>' +
                '</button>' +
            '</td>' +
            '<td class="col-play" style="text-align:right; padding-right:30px;">' +
                '<i class="fa-solid fa-circle-play play-trigger" style="color:#00f2ff; font-size:1.5rem;"></i>' +
            '</td>' +
        '</tr>';
    };

    // 차트 로드 로직
    MusicApp.loadChart = function() {
        const endpoint = this.selectedCity ? 'regional' : this.currentMode;
        $.get(this.basePath + '/api/music/' + endpoint, { u_no: this.currentUserNo }, (data) => {
            let html = '';
            if(!data || data.length === 0) {
                html = '<tr><td colspan="5" style="text-align:center; padding:50px; color:#555;">데이터가 없습니다.</td></tr>';
            } else {
                data.forEach((item, index) => { html += this.renderRow(item, index); });
            }
            $('#chart-body').html(html);
        });
    };
</script>
</head>
<body>
    <header><%@ include file="/WEB-INF/views/common/Header.jsp" %></header>
    <main>
        <div class="container">
            <div class="chart-header-top">
                <div class="sub-title">CHART</div>
                <h2 class="main-title">MUSIC TOP 100 <span>실시간 음악 순위</span></h2>
            </div>
            <div class="chart-tabs"></div>
            <table class="chart-table">
                <thead>
                    <tr>
                        <th class="col-rank">#</th>
                        <th class="col-info">SONG INFO</th>
                        <th class="col-btn">LIKE</th>
                        <th class="col-btn">LIB</th> 
                        <th class="col-play">PLAY</th>
                    </tr>
                </thead>
                <tbody id="chart-body"></tbody>
            </table>
        </div>
    </main>
    <footer><%@ include file="/WEB-INF/views/common/Footer.jsp" %></footer>
</body>
</html>