<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | MY LIBRARY</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        body { background-color: #050505; color: #fff; margin: 0; font-family: 'Pretendard', sans-serif; }
        main { min-height: calc(100vh - 180px); padding-top: 20px; padding-bottom: 120px; }
        .container { max-width: 1000px; margin: 0 auto; padding: 0 20px; }
        
        .lib-keyword { color: #00f2ff; text-shadow: 0 0 10px rgba(0, 242, 255, 0.5); font-style: italic; }
        .lib-tabs { display: flex; gap: 10px; margin-bottom: 25px; border-bottom: 1px solid #222; padding-bottom: 15px; }
        .tab-item { 
            background: none; border: none; color: #555; padding: 8px 20px; 
            cursor: pointer; font-size: 1rem; font-weight: bold; transition: 0.3s; 
        }
        .tab-item.active { color: #00f2ff; border-bottom: 2px solid #00f2ff; }

        .chart-table { width: 100%; border-collapse: collapse; table-layout: fixed; }
        .chart-table th { border-bottom: 1px solid #222; color: #555; padding: 15px 0; font-size: 0.8rem; }
        .chart-table td { padding: 12px 0; border-bottom: 1px solid #111; vertical-align: middle; text-align: center; }
        
        /* SearchResult 스타일 이식 */
        .album-art { 
            width: 50px; height: 50px; object-fit: cover; border-radius: 4px; 
            margin-right: 15px; transition: all 0.3s ease; cursor: pointer; flex-shrink: 0; 
        }
        .album-art:hover { filter: brightness(1.2); transform: scale(1.1); box-shadow: 0 0 10px rgba(0, 242, 255, 0.5); }
        
        .song-title { font-weight: bold; color: #eee; margin-bottom: 4px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .artist-link { color: #888; text-decoration: none; font-size: 0.85rem; cursor: pointer; }
        .artist-link:hover { color: #00f2ff !important; text-decoration: underline; }
        
        .btn-icon { background:none; border:none; cursor:pointer; font-size: 1.1rem; color: #444; }
        .heart-active { color: #ff0055 !important; }
        .play-trigger { color: #00f2ff; cursor: pointer; font-size: 1.5rem; transition: 0.2s; }
        .play-trigger:hover { transform: scale(1.2); text-shadow: 0 0 10px #00f2ff; }
    </style>
</head>
<body>
<header><jsp:include page="/WEB-INF/views/common/Header.jsp" /></header>

<main>
    <div class="container">
        <div style="display: flex; justify-content: space-between; align-items: flex-end; padding: 40px 0;">
            <div>
                <h2 style="margin: 0; font-size: 1.8rem;">YOUR <span class="lib-keyword">COLLECTION</span></h2>
                <p style="color: #666; font-size: 0.9rem; margin-top: 10px;">보관함 곡과 좋아요 표시한 곡을 관리하세요.</p>
            </div>
            <button class="btn-icon" onclick="playAllVisible()" style="background:#00f2ff; color:#000; padding:10px 20px; border-radius:4px; font-weight:bold;">
                <i class="fa-solid fa-play"></i> PLAY ALL
            </button>
        </div>

        <div class="lib-tabs">
            <button class="tab-item active" onclick="switchTab('all', this)">전체 곡 (보관함)</button>
            <button class="tab-item" onclick="switchTab('liked', this)">내 좋아요</button>
        </div>

        <table class="chart-table">
            <thead>
                <tr>
                    <th style="width: 60px;">#</th>
                    <th style="text-align: left; padding-left: 15px;">SONG INFO</th>
                    <th style="width: 80px;">LIKE</th>
                    <th style="width: 80px;">DEL</th> 
                    <th style="width: 80px;">PLAY</th>
                </tr>
            </thead>
            
            <%-- [전체 곡 탭] --%>
            <tbody id="body-all">
                <c:forEach var="music" items="${libraryList}" varStatus="status">
                    <tr class="music-row" id="lib-row-${music.m_no}" 
                        data-mno="${music.m_no}" data-title="${fn:escapeXml(music.m_title)}" 
                        data-artist="${fn:escapeXml(music.a_name)}" data-img="${music.b_image}"
                        onmouseover="this.style.backgroundColor='rgba(255,255,255,0.03)'" 
                        onmouseout="this.style.backgroundColor='transparent'">
                        <td>${status.count}</td>
                        <td style="text-align: left; padding-left: 15px;">
                            <div style="display: flex; align-items: center;">
                                <%-- SearchResult와 동일한 앨범 이동 로직 --%>
                                <img src="${music.b_image}" class="album-art" 
                                     onclick="event.stopPropagation(); location.href='${pageContext.request.contextPath}/album/detail?b_no=${music.b_no}'" 
                                     title="앨범 상세 보기">
                                <div>
                                    <div class="song-title">${music.m_title}</div>
                                    <%-- SearchResult와 동일한 아티스트 이동 로직 --%>
                                    <div class="artist-link" 
                                         onclick="event.stopPropagation(); location.href='${pageContext.request.contextPath}/artist/detail?a_no=${music.a_no}'" 
                                         title="아티스트 정보 보기">
                                        ${music.a_name}
                                    </div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <button class="btn-icon ${music.isLiked == 'Y' ? 'heart-active' : ''}" onclick="event.stopPropagation(); handleLike(${music.m_no}, this)">
                                <i class="${music.isLiked == 'Y' ? 'fa-solid' : 'fa-regular'} fa-heart"></i>
                            </button>
                        </td>
                        <td>
                            <button class="btn-icon" onclick="event.stopPropagation(); removeLib(${music.m_no})">
                                <i class="fa-solid fa-trash-can"></i>
                            </button>
                        </td>
                        <td><i class="fa-solid fa-circle-play play-trigger" onclick="event.stopPropagation(); playThis(this)"></i></td>
                    </tr>
                </c:forEach>
            </tbody>

            <%-- [좋아요 탭] --%>
            <tbody id="body-liked" style="display:none;">
                <c:forEach var="music" items="${likedList}" varStatus="status">
                    <tr class="music-row" id="liked-row-${music.m_no}" 
                        data-mno="${music.m_no}" data-title="${fn:escapeXml(music.m_title)}" 
                        data-artist="${fn:escapeXml(music.a_name)}" data-img="${music.b_image}"
                        onmouseover="this.style.backgroundColor='rgba(255,255,255,0.03)'" 
                        onmouseout="this.style.backgroundColor='transparent'">
                        <td>${status.count}</td>
                        <td style="text-align: left; padding-left: 15px;">
                            <div style="display: flex; align-items: center;">
                                <img src="${music.b_image}" class="album-art" 
                                     onclick="event.stopPropagation(); location.href='${pageContext.request.contextPath}/album/detail?b_no=${music.b_no}'">
                                <div>
                                    <div class="song-title">${music.m_title}</div>
                                    <div class="artist-link" 
                                         onclick="event.stopPropagation(); location.href='${pageContext.request.contextPath}/artist/detail?a_no=${music.a_no}'">
                                        ${music.a_name}
                                    </div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <button class="btn-icon heart-active" onclick="event.stopPropagation(); handleLike(${music.m_no}, this)">
                                <i class="fa-solid fa-heart"></i>
                            </button>
                        </td>
                        <td>-</td> 
                        <td><i class="fa-solid fa-circle-play play-trigger" onclick="event.stopPropagation(); playThis(this)"></i></td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</main>

<footer><jsp:include page="/WEB-INF/views/common/Footer.jsp" /></footer>

<script>
    const uNo = "${sessionScope.loginUser.UNo}";

    function switchTab(type, btn) {
        $(".tab-item").removeClass("active");
        $(btn).addClass("active");
        if(type === 'all') {
            $("#body-liked").hide(); $("#body-all").show();
        } else {
            $("#body-all").hide(); $("#body-liked").show();
        }
    }

    function handleLike(mNo, btn) {
        $.post('/api/music/toggle-like', { m_no: mNo, u_no: uNo }, function(res) {
            if(res.status === 'unliked') {
                $(btn).removeClass('heart-active').find('i').attr('class', 'fa-regular fa-heart');
                $("#liked-row-" + mNo).fadeOut(300);
            } else {
                $(btn).addClass('heart-active').find('i').attr('class', 'fa-solid fa-heart');
            }
        });
    }

    function removeLib(mNo) {
        if(!confirm("보관함에서 삭제하시겠습니까?")) return;
        $.post('/api/music/remove-library', { m_no: mNo, u_no: uNo }, function() {
            $("#lib-row-" + mNo).fadeOut(300);
        });
    }

    function playThis(el) {
        const d = $(el).closest('tr').data();
        if(typeof PlayQueue !== 'undefined') PlayQueue.addAndPlay(d.mno, d.title, d.artist, d.img);
    }

    function playAllVisible() {
        const $rows = $("tbody:visible tr:visible");
        if($rows.length === 0) return;
        PlayQueue.list = [];
        $rows.each(function() {
            const d = $(this).data();
            PlayQueue.addOnly(d.mno, d.title, d.artist, d.img);
        });
        PlayQueue.playIndex(0);
    }
</script>
</body>
</html>