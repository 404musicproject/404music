<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | MY LIBRARY</title>
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/music-chart.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/music-service.js"></script>

    <style>
        body { background-color: #050505; color: #fff; margin: 0; }
        main { 
            min-height: calc(100vh - 180px); 
            padding-top: 40px; 
            padding-bottom: 120px; 
        }
        .lib-keyword { color: #00f2ff; text-shadow: 0 0 10px rgba(0, 242, 255, 0.8); font-style: italic; }
        
        /* 테이블 스타일 보정 */
        .chart-table { width: 100%; border-collapse: collapse; margin-top: 30px; }
        .chart-table th { 
            color: #00f2ff; font-size: 0.85rem; letter-spacing: 1px; 
            padding: 15px 10px; border-bottom: 1px solid #222; 
        }
        .chart-table td { 
            padding: 12px 10px; vertical-align: middle; 
            border-bottom: 1px solid #111; 
        }
        
        .album-art { width: 55px; height: 55px; object-fit: cover; border-radius: 6px; margin-right: 20px; }

        /* 버튼 스타일 */
        .btn-play-all { 
            padding: 8px 20px; background: transparent; 
            border: 1px solid #ff0055; color: #ff0055; border-radius: 4px; 
            cursor: pointer; font-weight: bold; transition: 0.3s; font-size: 0.9rem;
        }
        .btn-play-all:hover { background: #ff0055; color: #fff; box-shadow: 0 0 15px rgba(255, 0, 85, 0.5); }

        .btn-icon { background:none; border:none; cursor:pointer; font-size: 1.3rem; transition: 0.2s; padding: 5px; }
        .btn-icon:hover { transform: scale(1.15); }
        .play-trigger { color: #00f2ff; }
        .heart-icon { color: #ff0055; }
        .trash-icon { color: #555; }
        .trash-icon:hover { color: #ff4d4d; }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/Header.jsp" />

<main>
    <div class="container">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #222; padding-bottom: 20px;">
            <div>
                <h2 style="margin: 0; font-size: 1.8rem;">YOUR PERSONAL <span class="lib-keyword">COLLECTION</span></h2>
                <p style="color: #666; font-size: 0.95rem; margin-top: 10px;">보관함에 저장된 곡들을 관리하고 재생하세요.</p>
            </div>
            <c:if test="${not empty libraryList}">
                <button class="btn-play-all" onclick="playAllLibrary()">
                    <i class="fa-solid fa-play" style="margin-right: 8px;"></i> PLAY ALL
                </button>
            </c:if>
        </div>

        <table class="chart-table">
            <thead>
                <tr>
                    <th style="width: 60px; text-align: center;">#</th>
                    <th style="text-align: left;">SONG INFO</th>
                    <th style="width: 100px; text-align: center;">LIKE</th>
                    <th style="width: 100px; text-align: center;">DEL</th> 
                    <th style="width: 100px; text-align: center;">PLAY</th>
                </tr>
            </thead>
            <tbody id="chart-body">
                <c:choose>
                    <c:when test="${not empty libraryList}">
                        <c:forEach var="music" items="${libraryList}" varStatus="status">
                            <tr id="row-${music.m_no}" 
                                onclick="handlePlay('${music.m_no}', '${music.m_title}', '${music.a_name}', '${music.b_image}')"
                                style="cursor: pointer;"
                                onmouseover="this.style.backgroundColor='rgba(255,255,255,0.03)'" 
                                onmouseout="this.style.backgroundColor='transparent'">
                                
                                <td style="text-align: center; color: #444; font-weight: bold;">${status.count}</td>
                                <td>
                                    <div style="display: flex; align-items: center;">
                                        <img src="${not empty music.b_image ? music.b_image : 'https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png'}" class="album-art">
                                        <div>
                                            <div style="font-weight: bold; color: #eee; font-size: 1.05rem; margin-bottom: 3px;">${music.m_title}</div>
                                            <div style="color: #888; font-size: 0.9rem;">${music.a_name}</div>
                                        </div>
                                    </div>
                                </td>
                                
                                <td style="text-align: center;">
                                    <button class="btn-icon heart-icon" onclick="event.stopPropagation(); MusicApp.toggleLike(${music.m_no}, this);">
                                        <i class="fa-solid fa-heart"></i>
                                    </button>
                                </td>
                                
                                <td style="text-align: center;">
                                    <button class="btn-icon trash-icon" onclick="event.stopPropagation(); removeFromLibrary('${music.m_no}');">
                                        <i class="fa-solid fa-trash-can"></i>
                                    </button>
                                </td>

                                <td style="text-align: center;">
                                    <i class="fa-solid fa-circle-play btn-icon play-trigger"></i>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="5" style="padding: 100px 0; text-align: center; color: #666;">
                                보관함이 비어 있습니다.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/Footer.jsp" />

<script>
    // JavaScript 로직은 이전과 동일 (removeFromLibrary, handlePlay 등)
    const uNo = "${sessionScope.loginUser.UNo}" || 0;

    function handlePlay(mNo, title, artist, img) {
        if (typeof PlayQueue !== 'undefined') {
            PlayQueue.addAndPlay(mNo, title, artist, img);
        }
    }

    function removeFromLibrary(mNo) {
        if(!confirm("이 곡을 보관함에서 삭제하시겠습니까?")) return;
        $.post('${pageContext.request.contextPath}/api/music/remove-library', { m_no: mNo, u_no: uNo })
        .done(function() {
            $("#row-" + mNo).fadeOut(300);
        });
    }

    function playAllLibrary() {
        const tracks = [];
        $("#chart-body tr[id^='row-']").each(function() {
            const onclickStr = $(this).attr("onclick");
            const match = onclickStr.match(/'([^']*)'/g).map(s => s.replace(/'/g, ""));
         // 각 인덱스에 맞는 데이터를 객체의 속성으로 할당합니다.
            if (match.length >= 4) {
                tracks.push({ 
                    mNo: match[0], 
                    title: match[1], 
                    artist: match[2], 
                    img: match[3] 
                });
            }
            // --- [수정 끝] ---
        });
        if(tracks.length > 0 && typeof PlayQueue !== 'undefined') {
            // 1. 모든 트랙을 addOnly로 동기적으로 추가
            tracks.forEach(track => {
                PlayQueue.addOnly(track.mNo, track.title, track.artist, track.img);
            });
            
            // 2. 목록에 모두 추가된 후, 첫 번째 곡 재생 시작
            // PlayQueue.playIndex(0)는 playIndex에 추가한 비디오ID 검색 로직 덕분에 정상 작동합니다.
            PlayQueue.playIndex(0); 
        }
    }
</script>
</body>
</html>