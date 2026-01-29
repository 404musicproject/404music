<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" buffer="32kb" autoFlush="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | 사이버 뮤직 차트</title>
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/music-chart.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://www.youtube.com/iframe_api"></script>
    <script src="${pageContext.request.contextPath}/js/music-service.js"></script>

    <script>
        $(document).ready(function() {
            const uNo = "${sessionScope.loginUser.uNo}" || 0;
            const urlParams = new URLSearchParams(window.location.search);
            const city = urlParams.get('city');

            MusicApp.init(Number(uNo));

            if (city) {
                const upperCity = city.toUpperCase();
                MusicApp.selectedCity = upperCity;
                MusicApp.currentMode = 'regional';
                renderTabs('regional', upperCity);
                setTimeout(() => { MusicApp.loadChart(); }, 150); 
            } else {
                MusicApp.selectedCity = '';
                renderTabs('period');
            }

            // 차트 클릭 시 재생
            $('#chart-body').on('click', 'tr', function(e) {
                if ($(e.target).closest('.btn-like, .preview-badge').length) return;
                const musicNo = $(this).data('mno'); 
                if (musicNo) {
                    $('#player-container').fadeIn();
                    MusicApp.playMusic(musicNo);
                }
            });
        });

        function renderTabs(mode, city) {
            let html = '';
            if (mode === 'regional') {
                html = `
                    <button class="tab-btn active" onclick="changeTab('regional', this, '${city}')">${city} CHART</button>
                    <button class="tab-btn" onclick="location.href='${pageContext.request.contextPath}/music/Index'" 
                            style="margin-left: auto; border: 1px solid #444; color: #888 !important; background: transparent;">
                        ← BACK TO MAIN
                    </button>`;
            } else {
                html = `
                    <button class="tab-btn active" onclick="changeTab('top100', this)">Real-time</button>
                    <button class="tab-btn" onclick="changeTab('weekly', this)">Weekly</button>
                    <button class="tab-btn" onclick="changeTab('monthly', this)">Monthly</button>
                    <button class="tab-btn" onclick="changeTab('yearly', this)">Yearly</button>`;
            }
            $('.chart-tabs').html(html);
        }

        function changeTab(mode, btn, city) {
            $('.tab-btn').removeClass('active');
            $(btn).addClass('active');
            MusicApp.currentMode = mode;
            MusicApp.selectedCity = city || '';
            MusicApp.loadChart();
        }
    </script>
    
    <style>
        /* Index 전용 추가 스타일이 필요하다면 여기에 작성 (현재는 공통 CSS로 충분함) */
        #player-container { display: none; } /* 초기 숨김 */
    </style>
</head>
<body>

<header><%@ include file="/WEB-INF/views/common/Header.jsp" %></header>

<main>
    <div class="container">
        <div class="chart-tabs"></div>
        
        <div class="section">
            <div class="chart-header">
                <div>
                    <h2 id="chart-title">LIVE CHART</h2>
                    <p style="margin: 4px 0 0 0; color: #666; font-size: 0.8rem;">곡을 클릭하면 영상이 재생되며 기록이 남습니다.</p>
                </div>
                <span id="update-time"></span>
            </div>

            <table class="chart-table">
                <thead>
                    <tr>
                        <th>RANK</th>
                        <th>SONG INFO</th>
                        <th style="text-align: center;">LIKE</th>
                        <th style="text-align: center; width: 80px;">LIB</th> 
                        <th style="text-align: right; padding-right: 20px;">PLAYS</th>
                    </tr>
                </thead>
                <tbody id="chart-body"></tbody>
            </table>
        </div>
    </div>
</main>

<div id="player-container">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
        <h4 id="now-playing-title" style="font-size: 0.75rem; color: #00f2ff; margin: 0; max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">재생 중인 곡 없음</h4>
        <button onclick="MusicApp.stopAll(); $('#player-container').fadeOut();" style="background:none; border:none; color:#ff0055; cursor:pointer; font-size: 18px;">&times;</button>
    </div>
    <div id="player"></div>
</div>

<footer><%@ include file="/WEB-INF/views/common/Footer.jsp" %></footer>
</body>
</html>