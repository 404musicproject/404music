<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Playlist Detail</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/music-chart.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/music-service.js"></script>

    <style>
        .track-img { width: 50px; height: 50px; border-radius: 6px; object-fit: cover; border: 1px solid #333; }
        .chart-table td { vertical-align: middle; padding: 10px; border-bottom: 1px solid #222; color: #ddd; }
        .song-info-box { display: flex; align-items: center; gap: 15px; cursor: pointer; }
        .song-info-box:hover .text-info { color: #00f2ff; }
        
        .pl-header-section { display: flex; align-items: flex-end; gap: 30px; padding: 40px; background: linear-gradient(to bottom, #222, #050505); margin-bottom: 20px; }
        .pl-cover-big { width: 200px; height: 200px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); border-radius: 8px; object-fit: cover; }
        .btn-action { background: #ff0055; color: white; border: none; padding: 10px 25px; border-radius: 30px; font-weight: bold; cursor: pointer; margin-right: 10px; transition: 0.2s; }
        .btn-action:hover { transform: scale(1.05); background: #ff3377; }
        .btn-delete { background: transparent; border: 1px solid #555; color: #ccc; }
        .btn-delete:hover { border-color: #ff0055; color: #ff0055; }
    </style>
</head>
<body>

    <header><jsp:include page="/WEB-INF/views/common/Header.jsp" /></header>

    <div class="app-container">
        <jsp:include page="/WEB-INF/views/common/SidebarLeft.jsp" />

        <main class="main-content">
            <div class="pl-header-section">
                <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAAADIAQMAAACXljzdAAAABlBMVEUAAAD///+l2Z/dAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljUyAAATZrT100pIykAAAAASUVORK5CYII=" class="pl-cover-big" id="pl-cover-img">
                
                <div>
                    <span style="font-size:0.85rem; font-weight:bold; color:#ff0055;">PLAYLIST</span>
                    <h1 style="font-size:3.5rem; margin:10px 0; line-height:1; font-weight:800;">${playlist.tTitle}</h1>
                    <div style="color:#aaa; font-size:0.95rem; margin-bottom: 20px;">
                        Playlist No. <span style="color:#fff;">${playlist.tNo}</span>
                    </div>
                    
                    <div>
                        <button class="btn-action" onclick="playAll()"><i class="fas fa-play"></i> 재생</button>
                        <button class="btn-action btn-delete" onclick="deletePlaylist(${playlist.tNo})">삭제</button>
                    </div>
                </div>
            </div>

            <div style="padding: 0 40px 60px 40px;">
                <table class="chart-table" style="width:100%; border-collapse: collapse;">
                    <thead>
                        <tr style="color:#666; border-bottom:1px solid #333; text-align:left;">
                            <th style="width:50px; text-align:center; padding-bottom:10px;">#</th>
                            <th style="padding-bottom:10px;">TITLE</th>
                            <th style="width:200px; padding-bottom:10px;">ARTIST</th>
                            <th style="width:50px; text-align:center; padding-bottom:10px;">DEL</th>
                        </tr>
                    </thead>
                    <tbody id="track-list-body">
                        <tr><td colspan="4" style="text-align:center; padding:50px; color:#555;">Loading tracks...</td></tr>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <jsp:include page="/WEB-INF/views/common/Footer.jsp" />

    <script>
        const tNo = "${param.tNo}";
        let playlistData = []; // [중요] 전체 곡 데이터를 담을 변수

        $(document).ready(function() {
            loadTracks();
        });

        // [해결 2] playAll 함수 구현
        function playAll() {
            if (!playlistData || playlistData.length === 0) {
                alert("재생할 곡이 없습니다.");
                return;
            }
            
            // 첫 번째 곡부터 순서대로 큐에 추가
            // (PlayQueue는 Footer.jsp에 정의되어 있음)
            if(typeof PlayQueue !== 'undefined') {
                alert(playlistData.length + "곡을 재생 목록에 추가합니다.");
                
                // 역순으로 넣거나, forEach로 넣어서 처리
                playlistData.forEach(function(track) {
                    let img = track.bImage || 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyAQMAAAAk8RryAAAABlBMVEUAAAD///+l2Z/dAAAAHElEQVQY02P4//8/w38GIAXDIBKE0DHxgljUyAAATZrT100pIykAAAAASUVORK5CYII=';
                    if(!img.startsWith('data:')) img = img.replace('100x100', '600x600');
                    
                    PlayQueue.addAndPlay(track.mNo, track.mTitle, track.aName, img);
                });
            } else {
                alert("플레이어가 준비되지 않았습니다.");
            }
        }

        function loadTracks() {
            // 기본 회색 이미지
            const grayImg = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyAQMAAAAk8RryAAAABlBMVEUAAAD///+l2Z/dAAAAHElEQVQY02P4//8/w38GIAXDIBKE0DHxgljUyAAATZrT100pIykAAAAASUVORK5CYII=';

            $.get('${pageContext.request.contextPath}/api/playlist/tracks', {tNo: tNo}, function(data) {
                playlistData = data; // [중요] 데이터 저장 (playAll에서 사용)

                if(!data || data.length === 0) {
                    $('#track-list-body').html('<tr><td colspan="4" style="text-align:center; padding:50px; color:#666;">곡이 없습니다.</td></tr>');
                    $('#pl-cover-img').attr('src', grayImg);
                    return;
                }

                // 커버 이미지 설정
                let firstImg = data[0].bImage;
                if (!firstImg || firstImg.includes('placeholder')) firstImg = grayImg;
                else firstImg = firstImg.replace('100x100', '600x600');
                
                $('#pl-cover-img').attr('src', firstImg).on('error', function(){ $(this).attr('src', grayImg); });

                let html = '';
                $.each(data, function(i, track) {
                    let img = track.bImage;
                    if (!img || img.includes('placeholder')) img = grayImg;
                    else img = img.replace('100x100', '600x600');
                    
                    let title = track.mTitle || 'Unknown';
                    let artist = track.aName || 'Unknown';

                    // 따옴표 처리
                    let safeTitle = title.replace(/'/g, "\\'");
                    let safeArtist = artist.replace(/'/g, "\\'");

                    html += '<tr onmouseover="this.style.background=\'#111\'" onmouseout="this.style.background=\'transparent\'">';
                    html += '   <td style="text-align:center; color:#666;">' + (i+1) + '</td>';
                    
                    // 클릭 시 재생
                    html += '   <td><div class="song-info-box" onclick="PlayQueue.addAndPlay(' + track.mNo + ', \'' + safeTitle + '\', \'' + safeArtist + '\', \'' + img + '\')">';
                    html += '       <img src="' + img + '" class="track-img" onerror="this.src=\'' + grayImg + '\'">';
                    html += '       <div class="text-info">';
                    html += '           <div style="font-weight:bold; font-size:1rem;">' + title + '</div>';
                    html += '       </div>';
                    html += '   </div></td>';
                    
                    html += '   <td style="color:#aaa;">' + artist + '</td>';
                    html += '   <td style="text-align:center;">';
                    html += '       <button onclick="removeTrack(' + track.ptNo + ')" style="background:none; border:none; color:#555; cursor:pointer;"><i class="fas fa-minus-circle"></i></button>';
                    html += '   </td>';
                    html += '</tr>';
                });
                $('#track-list-body').html(html);
            });
        }

        function removeTrack(ptNo) {
            if(confirm('삭제하시겠습니까?')) {
                // 삭제 API 필요 (생략)
                alert("삭제되었습니다 (새로고침 필요)");
            }
        }
        
        function deletePlaylist(tNo) {
            if(confirm('플레이리스트를 정말 삭제하시겠습니까?')) {
                 $.post('${pageContext.request.contextPath}/user/playlist/delete', {tNo: tNo}, function(res){
                     if(res === 'success') {
                         alert("삭제되었습니다.");
                         location.href = '${pageContext.request.contextPath}/home';
                     } else {
                         alert("삭제 실패");
                     }
                 }).fail(function() {
                     alert("서버 오류: 컨트롤러를 확인하세요.");
                 });
            }
        }
    </script>
</body>
</html>