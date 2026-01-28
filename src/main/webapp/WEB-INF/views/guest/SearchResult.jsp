<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | SEARCH RESULT</title>
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/music-chart.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/music-service.js"></script>

    <style>
        /* 푸터/플레이어와 겹치지 않게 레이아웃 조정 */
        body { background-color: #050505; color: #fff; margin: 0; }
        main { 
            min-height: calc(100vh - 180px); 
            padding-top: 20px; 
            padding-bottom: 120px; /* 플레이어 바 높이만큼 여유 */
            position: relative;
            z-index: 1; 
        }
        .search-keyword { color: #ff0055; text-shadow: 0 0 10px rgba(255, 0, 85, 0.5); font-style: italic; }
        .search-empty-box { 
            padding: 100px 20px; text-align: center; border: 1px dashed #333; 
            border-radius: 16px; margin: 20px 0; background: rgba(255, 255, 255, 0.05); 
        }
        .btn-register { 
            margin-top: 25px; padding: 12px 35px; background: transparent; 
            border: 1px solid #00f2ff; color: #00f2ff; border-radius: 4px; 
            cursor: pointer; font-weight: bold; text-transform: uppercase; transition: 0.3s; 
        }
        .btn-register:hover { background: #00f2ff; color: #000; box-shadow: 0 0 20px rgba(0, 242, 255, 0.6); }
        .action-cell { text-align: right; padding-right: 30px; }
        .play-trigger { color: #00f2ff; cursor: pointer; font-size: 1.5rem; transition: 0.2s; }
        .play-trigger:hover { transform: scale(1.2); text-shadow: 0 0 10px #00f2ff; }
        
        /* 테이블 스타일 보정 */
        .chart-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .album-art { width: 50px; height: 50px; object-fit: cover; border-radius: 4px; margin-right: 15px; }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/Header.jsp" />

<main>
    <div class="container">
        <div class="chart-tabs" style="display: flex; align-items: center; margin-bottom: 30px;">
            <button class="tab-btn active" style="background: none; border: none; color: #ff0055; font-weight: bold; font-size: 1.2rem; border-bottom: 2px solid #ff0055; padding-bottom: 5px;">
                SEARCH RESULT
            </button>
            <button class="tab-btn" onclick="location.href='/music/Index'" 
                    style="margin-left: auto; border: 1px solid #444; color: #888; background: transparent; padding: 5px 15px; cursor: pointer;">
                ← BACK TO CHART
            </button>
        </div>
        
        <div class="section">
            <div class="chart-header">
                <h2 id="chart-title">SEARCHING FOR <span class="search-keyword">"${keyword}"</span></h2>
                <p style="color: #666; font-size: 0.9rem;">"${keyword}"에 대한 검색 결과입니다.</p>
            </div>

            <table class="chart-table">
                <thead>
				    <tr style="border-bottom: 1px solid #222; color: #555; text-align: left;">
				        <th style="padding: 15px; width: 50px;">#</th>
				        <th>SONG INFO</th>
				        <th style="text-align: center; width: 80px;">LIKE</th>
				        <th style="text-align: center; width: 80px;">LIB</th> 
				        <th class="action-cell">PLAY</th>
				    </tr>
				</thead>
                <tbody id="chart-body">
                    <c:choose>
                        <c:when test="${not empty musicList}">
                            <c:forEach var="music" items="${musicList}" varStatus="status">
                                <tr style="border-bottom: 1px solid #111; transition: 0.3s; cursor: pointer;" 
                                    onclick="handlePlay('${music.m_no}', '${music.m_title}', '${music.a_name}', '${music.b_image}')"
                                    onmouseover="this.style.backgroundColor='rgba(255,255,255,0.03)'" 
                                    onmouseout="this.style.backgroundColor='transparent'">
                                    <td style="padding: 15px; color: #444;">${status.count}</td>
                                    <td>
                                        <div style="display: flex; align-items: center; padding: 10px 0;">
                                            <img src="${not empty music.b_image ? music.b_image : 'https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png'}" class="album-art">
                                            <div>
                                                <div style="font-weight: bold; color: #eee; margin-bottom: 4px;">${music.m_title}</div>
                                                <div style="font-size: 0.85rem; color: #888;">${music.a_name}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td style="text-align: center;">
                                        <button class="btn-like" style="background:none; border:none; color:#444; cursor:pointer;"
                                                onclick="event.stopPropagation(); if(typeof MusicApp !== 'undefined') MusicApp.toggleLike(${music.m_no}, this);">
                                            <i class="fa-solid fa-heart"></i>
                                        </button>
                                    </td>
                                    <td style="text-align: center;">
									    <button class="btn-add-lib" title="라이브러리에 추가"
									            style="background:none; border:none; color:#00f2ff; cursor:pointer; font-size: 1.1rem;"
									            onclick="event.stopPropagation(); addToLibrary('${music.m_no}');">
									        <i class="fa-solid fa-plus-square"></i>
									    </button>
									</td>
                                    <td class="action-cell">
                                        <i class="fa-solid fa-circle-play play-trigger"></i>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="4">
                                    <div class="search-empty-box">
                                        <p style="color: #666; font-size: 1.1rem;">"${keyword}" 에 대한 검색 결과가 없습니다.</p>
                                        <button class="btn-register" onclick="registerNewMusic('${keyword}')">
                                            <i class="fa-solid fa-bolt"></i> AUTO REGISTER
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/Footer.jsp" />

<script>
$(document).ready(function() {
	    // 세션에서 유저 번호 가져오기 (jsp 변수 사용)
	    const sessionUno = "${sessionScope.loginUser.UNo}";
	    
	    if (sessionUno && sessionUno !== "0") {
	        // music-service.js 초기화
	        if(typeof MusicApp !== 'undefined') {
	            MusicApp.init(Number(sessionUno));
	            console.log("MusicApp 초기화 완료: " + sessionUno);
	        }
	    }
	});
	
	function handlePlay(mNo, title, artist, img) {
	    // 로그 남기기 (music-service.js의 함수 호출)
	    if (typeof MusicApp !== 'undefined' && typeof MusicApp.sendPlayLog === 'function') {
	        MusicApp.sendPlayLog(mNo);
	    }
	    
	    // 재생
	    if (typeof PlayQueue !== 'undefined') {
	        PlayQueue.addAndPlay(mNo, title, artist, img);
	    }
	}
    function addToLibrary(mNo) {
        const uNo = "${sessionScope.loginUser.UNo}";
        if (!uNo || uNo == "0") {
            alert("로그인이 필요한 서비스입니다.");
            return;
        }

        // URL을 MusicController에 정의한 /api/music/toggle-like가 아닌 
        // 보관함 전용 엔드포인트로 정확히 호출해야 합니다.
        $.post('${pageContext.request.contextPath}/api/music/add-library', { 
            m_no: mNo,
            u_no: uNo
        })
        .done(function(res) {
            alert("라이브러리에 추가되었습니다! 🎵");
        })
        .fail(function(err) {
            alert("이미 추가되었거나 오류가 발생했습니다.");
        });
    }

    function registerNewMusic(keyword) {
        if(!keyword) return;
        $('.search-empty-box').html('<p style="color: #00f2ff;"><i class="fa-solid fa-sync fa-spin"></i> 데이터를 수집하고 있습니다...</p>');
        
        $.post('${pageContext.request.contextPath}/api/music/register', { keyword: keyword })
         .done(function() {
             location.href = "/musicSearch?searchKeyword=" + encodeURIComponent(keyword);
         })
         .fail(function() {
             alert("등록 실패");
             location.reload();
         });
    }
</script>
</body>
</html>