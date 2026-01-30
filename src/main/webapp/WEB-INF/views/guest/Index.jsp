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
        $(document).ready(function() {
            const uNo = "${sessionScope.loginUser.UNo}" || 0;
            MusicApp.init(Number(uNo));

            MusicApp.renderRow = function(item, index) {
                const mNo = item.MNO || item.m_no || 0;
                const bNo = item.BNO || item.b_no || 0;
                const aNo = item.ANO || item.a_no || 0;
                const title = (item.TITLE || item.title || 'Unknown').replace(/'/g, "\\'");
                const artist = (item.ARTIST || item.artist || 'Unknown').replace(/'/g, "\\'");
                const albumImg = item.ALBUM_IMG || item.b_image || 'https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png';
                const isLiked = item.MY_LIKE > 0;

                return '<tr style="border-bottom: 1px solid #111; transition: 0.3s; cursor: pointer;" ' +
                       'onclick="MusicApp.playLatestYouTube(\'' + title + '\', \'' + artist + '\', \'' + albumImg + '\')" ' +
                       'onmouseover="this.style.backgroundColor=\'rgba(255,255,255,0.03)\'" ' +
                       'onmouseout="this.style.backgroundColor=\'transparent\'">' +
                    
                    // 순위 (#) - 중앙 정렬
                    '<td style="padding: 15px; color: #444; text-align: center;">' + (index + 1) + '</td>' +
                    
                    // 곡 정보
                    '<td>' +
                        '<div style="display: flex; align-items: center; padding: 10px 0;">' +
                            '<div onclick="event.stopPropagation(); location.href=\'' + MusicApp.basePath + '/album/detail?b_no=' + bNo + '\'" title="앨범 상세 보기">' +
                                '<img src="' + albumImg + '" class="album-art" onerror="this.src=\'https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png\'">' +
                            '</div>' +
                            '<div>' +
                                '<div style="font-weight: bold; color: #eee; margin-bottom: 4px;">' + (item.TITLE || item.title) + '</div>' +
                                '<div class="artist-link" style="font-size: 0.85rem; color: #888;" ' +
                                     'onclick="event.stopPropagation(); location.href=\'' + MusicApp.basePath + '/artist/detail?a_no=' + aNo + '\'" title="아티스트 정보 보기">' +
                                    (item.ARTIST || item.artist) +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                    '</td>' +

                    // LIKE - 중앙 정렬
                    '<td style="text-align: center;">' +
                        '<button style="background:none; border:none; cursor:pointer; color: ' + (isLiked ? '#ff0055' : '#444') + ';" ' +
                                'onclick="event.stopPropagation(); MusicApp.toggleLike(' + mNo + ', this);">' +
                            '<i class="fa-' + (isLiked ? 'solid' : 'regular') + ' fa-heart"></i>' +
                        '</button>' +
                    '</td>' +

                    // LIB - 중앙 정렬
                    '<td style="text-align: center;">' +
                        '<button style="background:none; border:none; color:#00f2ff; cursor:pointer; font-size: 1.1rem;" title="라이브러리에 추가" ' +
                                'onclick="event.stopPropagation(); MusicApp.addToLibrary(' + mNo + ');">' +
                            '<i class="fa-solid fa-plus-square"></i>' +
                        '</button>' +
                    '</td>' +

                    // [핵심] PLAY 아이콘 - 헤더와 동일하게 오른쪽 정렬 및 패딩 부여
                    '<td style="text-align: right; padding-right: 30px;">' +
                        '<i class="fa-solid fa-circle-play play-trigger"></i>' +
                    '</td>' +
                '</tr>';
            };

            renderTabs();
            MusicApp.loadChart();
        });

        function renderTabs() {
            const html = '<button class="tab-btn active" onclick="changeTab(\'top100\', this)">Real-time</button>' +
                         '<button class="tab-btn" onclick="changeTab(\'weekly\', this)">Weekly</button>' +
                         '<button class="tab-btn" onclick="changeTab(\'monthly\', this)">Monthly</button>' +
                         '<button class="tab-btn" onclick="changeTab(\'yearly\', this)">Yearly</button>';
            $('.chart-tabs').html(html);
        }

        function changeTab(mode, btn) {
            $('.tab-btn').removeClass('active');
            $(btn).addClass('active');
            MusicApp.currentMode = mode;
            MusicApp.loadChart();
        }
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