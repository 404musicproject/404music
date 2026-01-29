<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | MY LIBRARY</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/music-service.js"></script>

<style>
    /* 1. 기본 레이아웃 및 폰트 */
    body { background-color: #050505; color: #fff; margin: 0; font-family: 'Pretendard', sans-serif; }
    main { 
        min-height: calc(100vh - 180px); 
        padding-top: 20px; 
        padding-bottom: 120px; 
        position: relative;
        z-index: 1; 
    }
    .container {
        max-width: 1000px;
        margin: 0 auto;
        padding: 0 20px;
    }
    
    /* 2. 헤더 섹션 (상단 타이틀 & 전체 재생 버튼) */
    .search-header { padding: 40px 0 30px 0; border-bottom: 1px solid #222; margin-bottom: 30px; }
    .lib-keyword { color: #00f2ff; text-shadow: 0 0 10px rgba(0, 242, 255, 0.5); font-style: italic; }
    
    .btn-play-all { 
        padding: 10px 25px; background: #00f2ff; color: #000; border: none; 
        border-radius: 4px; cursor: pointer; font-weight: bold; transition: 0.3s;
    }
    .btn-play-all:hover { background: #00dce6; box-shadow: 0 0 20px rgba(0, 242, 255, 0.4); }

    /* 3. 테이블 레이아웃 및 정렬 보정 */
    .chart-table { 
        width: 100%; 
        border-collapse: collapse; 
        table-layout: fixed; /* 컬럼 너비 고정의 핵심 */
    }
    
    /* 컬럼별 너비 비중 설정 (SearchResult와 통일) */
    .col-num { width: 60px; text-align: center !important; }
    .col-info { width: auto; text-align: left !important; }
    .col-like { width: 90px; text-align: center !important; }
    .col-del  { width: 90px; text-align: center !important; }
    .col-play { width: 90px; text-align: center !important; }

    .chart-table th { 
        border-bottom: 1px solid #222; 
        color: #555; 
        padding: 15px 0; 
        font-size: 0.8rem; 
        font-weight: bold;
        text-transform: uppercase;
    }
    
    .chart-table td { 
        padding: 12px 0; 
        border-bottom: 1px solid #111; 
        vertical-align: middle; 
        transition: 0.3s;
    }

    /* 4. 내부 요소 (앨범아트, 링크, 아이콘) */
    .album-art { 
        width: 45px; height: 45px; object-fit: cover; 
        border-radius: 4px; margin-right: 15px; 
        transition: 0.3s; cursor: pointer; flex-shrink: 0;
    }
    .album-art:hover { filter: brightness(1.3); transform: scale(1.05); }
    
    .artist-link { 
        cursor: pointer; transition: 0.2s; display: inline-block; 
        color: #888; text-decoration: none; font-size: 0.85rem; 
    }
    .artist-link:hover { color: #00f2ff !important; text-decoration: underline; }
    
    .play-trigger { color: #00f2ff; cursor: pointer; font-size: 1.5rem; transition: 0.2s; }
    .play-trigger:hover { transform: scale(1.2); text-shadow: 0 0 10px #00f2ff; }
    
    .btn-icon { 
        background:none; border:none; cursor:pointer; 
        font-size: 1.1rem; transition: 0.2s; color: #444; 
        display: inline-flex; align-items: center; justify-content: center;
        width: 40px; height: 40px;
    }
    .btn-icon:hover { transform: scale(1.2); }
    
    /* 하트 및 휴지통 강조색 */
    .heart-active { color: #ff0055 !important; }
    .trash-icon:hover { color: #ff4d4d !important; }

    /* 텍스트 넘침 방지 */
    .song-title {
        font-weight: bold; color: #eee; margin-bottom: 4px;
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }
</style>
</head>
<body>
<header><jsp:include page="/WEB-INF/views/common/Header.jsp" /></header>

<main>
    <div class="container">
        <div class="search-header" style="display: flex; justify-content: space-between; align-items: flex-end;">
            <div>
                <h2 style="margin: 0; font-size: 1.8rem;">YOUR <span class="lib-keyword">COLLECTION</span></h2>
                <p style="color: #666; font-size: 0.9rem; margin-top: 10px;">보관함에 저장된 곡들을 관리하고 재생하세요.</p>
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
		            <th class="col-num">#</th>
		            <th class="col-info" style="text-align: left; padding-left: 15px;">SONG INFO</th>
		            <th class="col-like">LIKE</th>
		            <th class="col-del">DEL</th> 
		            <th class="col-play">PLAY</th>
		        </tr>
		    </thead>
		    <tbody id="chart-body">
			    <c:forEach var="music" items="${libraryList}" varStatus="status">
			        <%-- [수정] onclick을 제거하고 data 속성에 정보를 담습니다 --%>
			        <tr id="row-${music.m_no}" 
			            class="music-row"
			            data-mno="${music.m_no}"
			            data-title="${fn:escapeXml(music.m_title)}"
			            data-artist="${fn:escapeXml(music.a_name)}"
			            data-img="${music.b_image}"
			            style="cursor: pointer;"
			            onmouseover="this.style.backgroundColor='rgba(255,255,255,0.03)'" 
			            onmouseout="this.style.backgroundColor='transparent'">
			            
			            <td class="col-num" style="color: #444;">${status.count}</td>
			            <td class="col-info">
			                <div style="display: flex; align-items: center; padding-left: 15px;">
			                    <img src="${music.b_image}" class="album-art">
			                    <div style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
			                        <div class="song-title">${music.m_title}</div>
			                        <a href="/artist/detail?a_no=${music.a_no}" class="artist-link" onclick="event.stopPropagation();">${music.a_name}</a>
			                    </div>
			                </div>
			            </td>
			            <td class="col-like">
			                <button class="btn-icon heart-active" onclick="event.stopPropagation(); MusicApp.toggleLike(${music.m_no}, this);">
			                    <i class="fa-solid fa-heart"></i>
			                </button>
			            </td>
			            <td class="col-del">
			                <button class="btn-icon trash-icon" onclick="event.stopPropagation(); removeFromLibrary('${music.m_no}');">
			                    <i class="fa-solid fa-trash-can"></i>
			                </button>
			            </td>
			            <td class="col-play">
			                <i class="fa-solid fa-circle-play play-trigger"></i>
			            </td>
			        </tr>
			    </c:forEach>
			</tbody>
		</table>
    </div>
</main>

<footer><jsp:include page="/WEB-INF/views/common/Footer.jsp" /></footer>

<script>
    const uNo = "${sessionScope.loginUser.UNo}" || "0";

    $(document).ready(function() {
        if (uNo !== "0" && typeof MusicApp !== 'undefined') {
            MusicApp.init(Number(uNo));
        }

        // [추가] 행 클릭 시 재생 이벤트 바인딩
        $(document).on("click", ".music-row", function() {
            const d = $(this).data();
            handlePlay(d.mno, d.title, d.artist, d.img);
        });
    });

    function handlePlay(mNo, title, artist, img) {
        if (typeof MusicApp !== 'undefined' && typeof MusicApp.sendPlayLog === 'function') {
            MusicApp.sendPlayLog(mNo);
        }
        if (typeof PlayQueue !== 'undefined') {
            PlayQueue.addAndPlay(mNo, title, artist, img);
        }
    }

    function removeFromLibrary(mNo) {
        if(!confirm("이 곡을 보관함에서 삭제하시겠습니까?")) return;
        $.post('${pageContext.request.contextPath}/api/music/remove-library', { m_no: mNo, u_no: uNo })
        .done(function() {
            $("#row-" + mNo).fadeOut(300, function() { $(this).remove(); });
        })
        .fail(function() { alert("삭제 실패"); });
    }

    // [수정] 정규표현식 대신 data()를 사용하여 안전하게 전체 곡 수집
    function playAllLibrary() {
        if (typeof PlayQueue === 'undefined') return;
        
        const $rows = $(".music-row");
        if ($rows.length === 0) return;

        $rows.each(function() {
            const d = $(this).data();
            PlayQueue.addOnly(d.mno, d.title, d.artist, d.img);
        });
        
        PlayQueue.playIndex(0);
        alert("보관함의 모든 곡을 재생 목록에 추가했습니다.");
    }
</script>
</body>
</html>