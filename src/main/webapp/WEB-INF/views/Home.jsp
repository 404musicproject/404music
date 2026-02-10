<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" buffer="128kb" autoFlush="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | Digital Archive</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/music-service.js"></script>
    <style>
        body { background-color: #050505; color: #fff; font-family: 'Pretendard', sans-serif; overflow-x: hidden; margin: 0; }
        
        /* 1. 히어로 섹션 */
        .hero-section { position: relative; height: 60vh; width: 100%; display: flex; align-items: center; justify-content: center; overflow: hidden; border-bottom: 2px solid #ff0055; }
        #top1-bg { position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-size: cover; background-position: center; filter: blur(20px) brightness(0.3); z-index: 1; transition: all 1s ease; }
        .hero-content { position: relative; z-index: 2; text-align: center; display: flex; flex-direction: column; align-items: center; cursor: pointer; transition: transform 0.3s; }
        .hero-content:hover { transform: scale(1.03); }
        #top1-jacket { width: 250px; height: 250px; border-radius: 12px; box-shadow: 0 0 30px rgba(255, 0, 85, 0.5); border: 2px solid #ff0055; margin-bottom: 20px; object-fit: cover; }
        .top1-badge { background: #ff0055; padding: 4px 12px; font-weight: bold; font-size: 0.9rem; margin-bottom: 10px; letter-spacing: 2px; }

		/* TOP 10 섹션 스타일 (2열 그리드 적용) */
		.top10-container { max-width: 1000px; margin: 40px auto; padding: 0 20px; }
		.top10-wrapper { 
		    background: #0a0a0a; 
		    border: 1px solid #333; 
		    border-radius: 12px; 
		    padding: 10px; 
		}
		/* 중요: 2열 배치를 위한 그리드 설정 */
		.top10-list {
		    display: grid;
		    /* 1fr 1fr 대신 아래처럼 사용하면 각 열이 동일한 너비를 강제로 유지합니다 */
		    grid-template-columns: repeat(2, minmax(0, 1fr)); 
		    gap: 10px 20px;
		}
		
		.top10-item { 
		    display: flex; 
		    align-items: center; 
		    padding: 10px; 
		    border-radius: 8px; 
		    transition: 0.2s; 
		    cursor: pointer;
		    background: rgba(255, 255, 255, 0.03);
		}
		.top10-item:hover { background: rgba(255, 0, 85, 0.15); transform: translateX(5px); }
		
		.top10-rank { 
		    font-size: 1.2rem; 
		    font-weight: 900; 
		    color: #ff0055; 
		    width: 30px; 
		    text-align: center; 
		    font-style: italic;
		    margin-right: 15px;
		}
		.top10-img { width: 50px; height: 50px; border-radius: 4px; object-fit: cover; margin-right: 15px; }
		/* 1. 리스트 전체 컨테이너: 2열 5행 세로 배치 설정 */
		.top10-list {
		    display: grid !important;
		    grid-template-columns: repeat(2, minmax(0, 1fr)); /* 2열 동일 너비 */
		    grid-template-rows: repeat(5, auto);             /* 5행으로 제한 */
		    grid-auto-flow: column;                          /* 위에서 아래로 먼저 채우기 (핵심!) */
		    gap: 10px 20px;
		}
		
		/* 2. 각 아이템 스타일 */
		.top10-item { 
		    display: flex; 
		    align-items: center; 
		    padding: 10px; 
		    border-radius: 8px; 
		    transition: 0.2s; 
		    cursor: pointer;
		    background: rgba(255, 255, 255, 0.03);
		    min-width: 0; /* 내부 텍스트 생략 처리를 위해 필수 */
		}
		
		/* 3. 텍스트 정보 영역 (기존의 잘못된 grid 속성 제거) */
		.top10-info {
		    flex: 1;
		    min-width: 0;
		    display: flex;
		    flex-direction: column;
		    justify-content: center;
		    overflow: hidden;
		}
		
		/* 4. 제목 스타일 (말줄임표 처리) */
		.top10-title {
		    font-weight: bold;
		    font-size: 1rem;
		    white-space: nowrap;
		    overflow: hidden;
		    text-overflow: ellipsis;
		    width: 100%; /* 부모 너비에 맞춤 */
		}
		
		/* 5. 아티스트 스타일 (말줄임표 처리) */
		.top10-artist {
		    font-size: 0.8rem;
		    color: #888;
		    white-space: nowrap;
		    overflow: hidden;
		    text-overflow: ellipsis;
		    width: 100%;
		}
		.top10-play { color: #ff0055; font-size: 1.2rem; padding: 0 10px; }

        /* 2. 메뉴 그리드 */
        .menu-grid { max-width: 1000px; margin: -50px auto 50px; display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; padding: 0 20px; position: relative; z-index: 10; }
        .menu-card { background: #0a0a0a; border: 1px solid #00f2ff; padding: 30px 10px; text-align: center; text-decoration: none; color: #00f2ff; transition: all 0.3s; border-radius: 8px; display: flex; flex-direction: column; gap: 10px; cursor: pointer;z-index: 20; user-select: none; }
        .menu-card:hover { background: rgba(0, 242, 255, 0.1); transform: translateY(-10px); box-shadow: 0 0 20px rgba(0, 242, 255, 0.4); color: #fff; border-color: #fff; }
        .menu-card * {pointer-events: none;}
        /* 3. 최신 음악 섹션 */
        .container { max-width: 1000px; margin: 80px auto; padding: 0 20px; }
        .chart-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 25px; }
        #itunes-list { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; justify-content: center; }
        .itunes-card { background: #111; padding: 15px; border-radius: 12px; border: 1px solid #222; transition: 0.3s; cursor: pointer; }
        .itunes-card:hover { transform: translateY(-5px); border-color: #ff0055 !important; box-shadow: 0 0 15px rgba(255, 0, 85, 0.3); background: #1a1a1a !important; }

        /* 4. 지역별 섹션 이미지 스타일 */
        .location-section, .Weather-section, .activity-section { max-width: 1000px; margin: 80px auto; padding: 0 20px; }
        .section-title { color: #ff0055; font-size: 1.5rem; font-weight: bold; margin-bottom: 30px; text-transform: uppercase; letter-spacing: 2px; border-left: 4px solid #ff0055; padding-left: 15px; }
        .location-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 15px; }
        .location-card { position: relative; height: 160px; background-color: #111; background-size: cover; background-position: center; border: 1px solid #222; border-radius: 12px; transition: all 0.3s ease; overflow: hidden; display: flex; flex-direction: column; justify-content: flex-end; padding: 15px; text-decoration: none; cursor: pointer; }
        .location-card::after { content: ''; position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: linear-gradient(to top, rgba(0,0,0,0.9) 10%, rgba(0,0,0,0.1) 90%); z-index: 1; }
        .location-card:hover { border-color: #ff0055; transform: translateY(-5px); box-shadow: 0 5px 15px rgba(255,0,85,0.3); }
        .location-card > * { position: relative; z-index: 2; }
        
        .card-seoul { background-image: url('${pageContext.request.contextPath}/img/Location/seoul.jpg'); }
        .card-busan { background-image: url('${pageContext.request.contextPath}/img/Location/busan.jpg'); }
        .card-daegu { background-image: url('${pageContext.request.contextPath}/img/Location/daegu.jpg'); }
        .card-daejeon { background-image: url('${pageContext.request.contextPath}/img/Location/daejeon.jpg'); }
        .card-jeju { background-image: url('${pageContext.request.contextPath}/img/Location/jeju.jpg'); }

        .city-name { font-size: 0.8rem; color: #00f2ff; font-weight: bold; margin-bottom: 8px; display: block; }
        .city-top-song { font-size: 0.9rem; font-weight: bold; color: #fff; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .city-top-artist { font-size: 0.75rem; color: #aaa; }

        @media (max-width: 900px) {
            #itunes-list { grid-template-columns: repeat(2, 1fr); }
            .location-grid { grid-template-columns: repeat(2, 1fr); }
            .menu-grid { grid-template-columns: repeat(2, 1fr); }
            .top10-list { 
		        display: grid;
		        grid-template-columns: 1fr; 
		        grid-template-rows: none;
		        grid-auto-flow: row; /* 모바일은 다시 순서대로 아래로 */
		    }
        }
        
        /* 태그 이미지 (생략 가능하면 유지) */
		.tag-1 { background-image: url('${pageContext.request.contextPath}/img/Tag/1.png'); }
		.tag-2 { background-image: url('${pageContext.request.contextPath}/img/Tag/2.png'); }
		.tag-3 { background-image: url('${pageContext.request.contextPath}/img/Tag/3.png'); }
		.tag-4 { background-image: url('${pageContext.request.contextPath}/img/Tag/4.png'); }
		.tag-5 { background-image: url('${pageContext.request.contextPath}/img/Tag/5.png'); }
		.tag-6 { background-image: url('${pageContext.request.contextPath}/img/Tag/6.png'); }
		.tag-7 { background-image: url('${pageContext.request.contextPath}/img/Tag/7.png'); }
		.tag-8 { background-image: url('${pageContext.request.contextPath}/img/Tag/8.png'); }
		.tag-9 { background-image: url('${pageContext.request.contextPath}/img/Tag/9.png'); }
		.tag-10 { background-image: url('${pageContext.request.contextPath}/img/Tag/10.png'); }
		.tag-11 { background-image: url('${pageContext.request.contextPath}/img/Tag/11.png'); }
		.tag-12 { background-image: url('${pageContext.request.contextPath}/img/Tag/12.png'); }
		.tag-13 { background-image: url('${pageContext.request.contextPath}/img/Tag/13.png'); }
		.tag-14 { background-image: url('${pageContext.request.contextPath}/img/Tag/14.png'); }
		.tag-15 { background-image: url('${pageContext.request.contextPath}/img/Tag/15.png'); }
		.tag-16 { background-image: url('${pageContext.request.contextPath}/img/Tag/16.png'); }
		.tag-17 { background-image: url('${pageContext.request.contextPath}/img/Tag/17.png'); }
		.tag-18 { background-image: url('${pageContext.request.contextPath}/img/Tag/18.png'); }
		.tag-19 { background-image: url('${pageContext.request.contextPath}/img/Tag/19.png'); }
		.tag-20 { background-image: url('${pageContext.request.contextPath}/img/Tag/20.png'); }
		.tag-21 { background-image: url('${pageContext.request.contextPath}/img/Tag/21.png'); }
		
		/* 팝업 오버레이 스타일 추가 */
		.custom-popup-overlay {
		    position: fixed;
		    top: 0; left: 0; width: 100%; height: 100%;
		    background: rgba(0, 0, 0, 0.8);
		    display: flex; align-items: center; justify-content: center;
		    z-index: 10000;
		}
		.custom-popup-content {
		    background: #1a1a1a;
		    border: 2px solid #ff0055;
		    padding: 20px;
		    border-radius: 12px;
		    width: 400px;
		    color: #fff;
		    box-shadow: 0 0 20px rgba(255, 0, 85, 0.5);
		}
		.popup-footer {
		    margin-top: 15px;
		    display: flex;
		    justify-content: space-between;
		    align-items: center;
		}
		.popup-footer button {
		    background: #ff0055; border: none; color: #fff;
		    padding: 5px 15px; cursor: pointer; border-radius: 4px;
		}
		
		/* 로그인 안했을 때/미구독 시 보이는 배너 스타일 */
.Kibana {
    max-width: 1000px;
    margin: 40px auto;
    padding: 40px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: linear-gradient(135deg, #1a1a1a 0%, #333 100%) !important;
    border-radius: 20px;
    border: 1px solid #444;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
}

.Kibana h4 {
    margin: 0;
    font-size: 1.5rem;
    color: #fff;
    font-weight: bold;
}

.Kibana p {
    margin: 10px 0 0 0;
    color: #bbb;
    font-size: 1rem;
}

/* "지금 구독하기" 버튼 스타일 */
.Kibana a {
    text-decoration: none;
    transition: transform 0.3s, filter 0.3s;
}

.Kibana a span {
    display: inline-block;
    background: #ff0055;
    color: #fff;
    padding: 15px 35px;
    border-radius: 50px;
    font-weight: bold;
    box-shadow: 0 4px 15px rgba(255, 0, 85, 0.4);
}

.Kibana a:hover {
    transform: scale(1.05);
    filter: brightness(1.2);
}

/* 모바일 대응 */
@media (max-width: 768px) {
    .Kibana {
        flex-direction: column;
        text-align: center;
        gap: 20px;
        margin: 20px;
        padding: 30px 20px;
    }
}
		
		
/* 프리미엄 컨테이너: 테두리 없이 배경만으로 구분 */
.premium-container {
    max-width: 1100px;
    margin: 40px auto;
    padding: 50px 30px;
    /* 상단은 약간 밝은 그레이-바이올렛, 하단은 다시 어두워지는 고급스러운 그라데이션 */
    background: linear-gradient(180deg, #1a1a1c 0%, #111112 100%);
    border-radius: 40px;
    /* 테두리 대신 그림자로 경계를 만듭니다 */
    box-shadow: 0 30px 60px rgba(0, 0, 0, 0.4);
}

.premium-header { text-align: center; margin-bottom: 30px; }
.premium-badge {
    color: #ffd700;
    font-size: 0.8rem;
    font-weight: bold;
    letter-spacing: 2px;
    border: 1px solid #ffd700;
    padding: 5px 15px;
    border-radius: 50px;
}

/* 분석 데스크를 가로로 긴 '슬림 배너'로 변경 */
.Kibana-mini {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: rgba(255, 255, 255, 0.03);
    padding: 20px 30px;
    border-radius: 15px;
    text-decoration: none;
    margin-bottom: 40px;
    border: 1px solid rgba(255, 0, 85, 0.3);
    transition: 0.3s;
}

.Kibana-mini:hover {
    background: rgba(255, 0, 85, 0.1);
    border-color: #ff0055;
}

.kibana-text h4 { margin: 0; color: #fff; font-size: 1.2rem; }
.kibana-text p { margin: 5px 0 0; color: #888; font-size: 0.9rem; }
.kibana-btn { color: #ff0055; font-weight: bold; font-size: 0.9rem; }

/* 모바일 대응 */
@media (max-width: 768px) {
    .Kibana {
        flex-direction: column;
        text-align: center;
        gap: 25px;
        padding: 40px 20px;
        margin: 40px 20px;
    }
}

/* 관리자 배지 컨테이너 */
/* 관리자 배지를 상단 헤더 영역 근처로 강제 이동 */
.admin-badge-container {
    position: absolute; /* 절대 위치 설정 */
    top: 170px;          /* 헤더 영역 높이에 맞게 조절 */
    right: 40px;       /* 라이브러리 버튼 왼쪽 근처로 배치 */
    z-index: 9999;      /* 최상단으로 올림 */
    margin: 0;
    padding: 0;
}

.admin-badge {
    display: flex;
    align-items: center;
    gap: 8px;
    background: rgba(255, 0, 85, 0.15); /* 배경 투명도 조절 */
    border: 1px solid #ff0055;
    color: #ff0055;
    padding: 6px 14px;
    border-radius: 20px;
    font-size: 0.75rem; /* 크기를 살짝 줄임 */
    text-decoration: none;
    font-weight: bold;
    backdrop-filter: blur(5px);
    transition: all 0.3s;
}

/* 겹침의 원인이었던 menu-grid 마진 복구 */
.menu-grid {
    max-width: 1000px;
    margin: -50px auto 50px; /* 원래의 겹침 디자인 유지 */
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 20px;
    padding: 0 20px;
    position: relative;
    z-index: 10;
}

/* 호버 효과: 네온 핑크로 발광 */
.admin-badge:hover {
    background: #ff0055;
    color: #fff;
    box-shadow: 0 0 20px rgba(255, 0, 85, 0.6);
    transform: translateY(-2px);
}

/* 깜빡이는 포인트 점 (Live 느낌) */
.pulse-dot {
    width: 8px;
    height: 8px;
    background-color: #ff0055;
    border-radius: 50%;
    position: relative;
}

.admin-badge:hover .pulse-dot {
    background-color: #fff;
}

.pulse-dot::before {
    content: "";
    position: absolute;
    width: 100%;
    height: 100%;
    background: inherit;
    border-radius: 50%;
    animation: pulse 1.5s infinite;
}

@keyframes pulse {
    0% { transform: scale(1); opacity: 0.8; }
    100% { transform: scale(2.5); opacity: 0; }
}


    </style>
</head>
<body>
<header><jsp:include page="/WEB-INF/views/common/Header.jsp" /></header> 

<main>
    <section class="hero-section">
        <div id="top1-bg"></div>
        <div class="hero-content" onclick="playTopOne()">
		    <div class="top1-badge">CURRENT NO.1</div>
		    <img id="top1-jacket" src="https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png" alt="Top Music">
		    <h1 id="top1-title" style="margin: 0; font-size: 2.2rem; text-shadow: 0 0 15px #ff0055;">Loading...</h1>
		    <p id="top1-artist" style="color: #ccc; margin-top: 5px;"></p>
		</div>
    </section>
    

<c:set var="userAuth" value="${loginUser.uAuth}" /> <%-- 먼저 변수에 담아보기 --%>

<%-- 안전한 대괄호 연산자 사용 및 대소문자 방어 코드 --%>
<c:if test="${not empty loginUser and (loginUser['uAuth'] == 'ADMIN' or loginUser['uauth'] == 'ADMIN')}">
    <div class="admin-badge-container">
        <a href="${pageContext.request.contextPath}/support/KibanaAdmin" class="admin-badge">
            <span class="pulse-dot"></span>
            <i class="fa-solid fa-chart-line"></i> 관리자 분석 모드 활성화됨
        </a>
    </div>
</c:if>
				
	<section class="menu-grid">
        <a href="${pageContext.request.contextPath}/music/Index?type=top100" class="menu-card">
            <span style="font-size: 0.7rem; opacity: 0.7;">REAL-TIME</span>
            <span style="font-weight: bold; letter-spacing: 1px;">DAILY</span>
        </a>
        <a href="${pageContext.request.contextPath}/music/Index?type=weekly" class="menu-card">
            <span style="font-size: 0.7rem; opacity: 0.7;">7 DAYS</span>
            <span style="font-weight: bold; letter-spacing: 1px;">WEEKLY</span>
        </a>
        <a href="${pageContext.request.contextPath}/music/Index?type=monthly" class="menu-card">
            <span style="font-size: 0.7rem; opacity: 0.7;">30 DAYS</span>
            <span style="font-weight: bold; letter-spacing: 1px;">MONTHLY</span>
        </a>
        <a href="${pageContext.request.contextPath}/music/Index?type=yearly" class="menu-card">
            <span style="font-size: 0.7rem; opacity: 0.7;">365 DAYS</span>
            <span style="font-weight: bold; letter-spacing: 1px;">YEARLY</span>
        </a>
    </section>
	
	<section class="top10-container">
	    <div class="section-title">Real-time Top 10</div>
	    <div class="top10-wrapper">
	        <div id="top10-list" class="top10-list">
                </div>
	    </div>
	</section>
	
<%-- 기존 배너 부분 --%>
<c:if test="${empty loginUser or !isSubscribed}">
    <section class="Kibana" style="background: linear-gradient(135deg, #333 0%, #555 100%);">
        <div>
            <h4 style="margin: 0; font-size: 1.6rem;">프리미엄 혜택을 누리세요 💎</h4>
            <p style="margin: 10px 0 0 0; opacity: 0.8;">구독 시 맞춤 분석과 위치 기반 추천 시스템을 이용할 수 있습니다.</p>
        </div>
        <%-- 단순 링크 대신 함수를 호출하도록 변경 가능 --%>
        <a href="javascript:void(0);" onclick="checkPremiumAccess(event)" style="text-decoration:none;">
		    <span style="background: #ff0055; color: #fff; padding: 15px 30px; border-radius: 40px;">
		        지금 구독하기 >
		    </span>
		</a>
    </section>
</c:if>

<%-- 2. 오직 구독 중인 회원에게만 보이는 핵심 기능 --%>
<%-- 2. 오직 구독 중인 회원에게만 보이는 프리미엄 존 --%>
<c:if test="${isSubscribed}">
    <div class="premium-container">
        <div class="premium-header">
            <span class="premium-badge"><i class="fa-solid fa-crown"></i> 404 PREMIUM LOUNGE</span>
        </div>

        <section class="premium-item">
            <a href="${pageContext.request.contextPath}/user/Kibana" class="Kibana-mini">
                <div class="kibana-text">
                    <h4>404 분석 데스크</h4>
                    <p>데이터로 기록된 당신의 음악 여정(최소 5분간의 음악 기록이 필요합니다.)</p>
                </div>
                <span class="kibana-btn">분석 리포트 <i class="fa-solid fa-arrow-right"></i></span>
            </a>
        </section>
        
        <section class="location-section">
            <div class="section-title">📍 NOW & HERE</div>
            <div class="location-grid" id="context-list"></div>
        </section>

        <section class="location-section">
            <div class="section-title">✨ FOR YOUR MOOD</div>
            <div class="location-grid" id="personalized-list"></div>
        </section>
    </div>
</c:if>

    <section class="container">
        <div class="chart-header">
            <div>
                <h2 style="color: #00f2ff; text-shadow: 0 0 10px rgba(0, 242, 255, 0.5); margin:0;">K-POP TREND</h2>
                <p style="margin: 4px 0 0 0; color: #888; font-size: 0.8rem;">K-POP 트렌드 차트</p>
            </div>
            <button onclick="loadItunesMusic()" style="background: none; border: 1px solid #333; color: #888; cursor: pointer; padding: 5px 10px; border-radius: 4px;">REFRESH</button>
        </div>
        <div id="itunes-list"></div>
    </section>    

    <section class="location-section">
        <div class="section-title">Regional Top Hits</div>
        <div class="location-grid">
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

<footer><jsp:include page="/WEB-INF/views/common/Footer.jsp" /></footer>

<script>
const contextPath = '${pageContext.request.contextPath}';
const FALLBACK_IMG = 'https://www.gstatic.com/android/keyboard/emojikitchen/20201001/u1f4bf/u1f4bf.png';
let cachedTopOne = null;

const tagNoMap = {
  "행복한 기분": 1, "파티": 2, "더운 여름": 3, "자신감 뿜뿜": 4, "운동": 5,
  "스트레스 해소": 6, "슬픔": 7, "비 오는 날": 8, "새벽 감성": 9, "로맨틱": 10,
  "휴식": 11, "요리할 때": 12, "집중": 13, "맑음": 14, "흐림": 15,
  "눈 오는 날": 16, "바다": 17, "산/등산": 18, "카페/작업": 19, "헬스장": 20, "공원/피크닉": 21
};

function toHighResArtwork(url) {
    if (!url) return FALLBACK_IMG;
    return String(url).replace(/100x100bb/g, '600x600bb').replace(/100x100/g, '600x600');
}



function goRegional(city) { 
    location.href = contextPath + '/music/regional?city=' + city; 
}

function changeHeroAndPlay(title, artist, imgUrl) {
    // 1. [UI 변경] 즉시 화면 정보를 바꿉니다.
    const highImg = toHighResArtwork(imgUrl);
    $('#top1-bg').css('background-image', 'url(' + highImg + ')');
    $('#top1-jacket').attr('src', highImg);
    $('#top1-title').text(title);
    $('#top1-artist').text(artist);

    // 2. [핵심: 재생 실행] 이 코드가 있어야 노래가 나옵니다!
    if (window.MusicApp && typeof window.MusicApp.playLatestYouTube === 'function') {
        window.MusicApp.playLatestYouTube(title, artist, imgUrl);
    } else {
        console.error("MusicApp이 로드되지 않았거나 playLatestYouTube 함수를 찾을 수 없습니다.");
    }

    // 3. [로그 전송] 재생과 별개로 백그라운드에서 실행 (비동기)
    const userNo = "${loginUser != null ? loginUser.UNo : 0}";
    if (userNo !== "0") {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(position) {
                // 좌표 성공 시 전송
                $.post(contextPath + '/api/music/log', {
                    title: title,
                    artist: artist,
                    albumImg: imgUrl,
                    h_lat: position.coords.latitude,
                    h_lon: position.coords.longitude
                });
            }, function(error) {
                // 좌표 실패 시(권한 거부 등) 기본 정보만 전송
                $.post(contextPath + '/api/music/log', {
                    title: title,
                    artist: artist,
                    albumImg: imgUrl
                });
            }, { timeout: 3000 }); // 3초 대기 후 안되면 실패 처리
        } else {
            // Geolocation 지원 안 하는 브라우저
            $.post(contextPath + '/api/music/log', {
                title: title,
                artist: artist,
                albumImg: imgUrl
            });
        }
    }
}

function playTopOne() {
    if (cachedTopOne) {
        changeHeroAndPlay(cachedTopOne.TITLE || cachedTopOne.m_title, cachedTopOne.ARTIST || cachedTopOne.a_name, cachedTopOne.ALBUM_IMG || cachedTopOne.B_IMAGE);
    }
}

function loadTop10() {
    var userNo = "${loginUser != null ? loginUser.UNo : 0}";
    var $listContainer = $('#top10-list');

    $.get(contextPath + '/api/music/top100', { u_no: userNo, _t: Date.now() }, function(res) {
        // [수정] res가 배열인지 아주 꼼꼼하게 확인합니다.
        let list = [];
        if (res && Array.isArray(res)) {
            list = res;
        } else if (res && res.list && Array.isArray(res.list)) {
            list = res.list;
        }

        // list가 배열이 아니거나 비어있다면 안내 문구만 띄우고 종료 (forEach 실행 안 함)
        if (!list || list.length === 0) {
            $listContainer.html('<p style="grid-column:1/-1; text-align:center; padding:20px; color:#888;">'
                               + '<i class="fa-solid fa-clock-rotate-left"></i> 현재 실시간 차트를 집계 중입니다.</p>');
            return;
        }

        let html = '';
        list.forEach(function(item, i) {
            if (i >= 10 || !item) return;

            var title = item.TITLE || item.m_title || 'Unknown';
            var artist = item.ARTIST || item.a_name || 'Unknown';
            var rawImg = item.ALBUM_IMG || item.b_image || FALLBACK_IMG;
            var img = toHighResArtwork(rawImg);
            var rank = i + 1;

            var sTitle = title.replace(/'/g, "\\'");
            var sArtist = artist.replace(/'/g, "\\'");

            if (i === 0) {
                $('#top1-bg').css('background-image', 'url(' + img + ')');
                $('#top1-jacket').attr('src', img);
                $('#top1-title').text(title);
                $('#top1-artist').text(artist);
                cachedTopOne = item;
            }

            html += '<div class="top10-item" onclick="changeHeroAndPlay(\'' + sTitle + '\', \'' + sArtist + '\', \'' + img + '\')">';
            html += '    <div class="top10-rank">' + rank + '</div>';
            html += '    <img src="' + img + '" class="top10-img" onerror="this.src=\'' + FALLBACK_IMG + '\'">';
            html += '    <div class="top10-info">';
            html += '        <div class="top10-title">' + title + '</div>';
            html += '        <div class="top10-artist">' + artist + '</div>';
            html += '    </div>';
            html += '    <div class="top10-play"><i class="fa-solid fa-play"></i></div>';
            html += '</div>';
        });
        
        $listContainer.html(html);
    }).fail(function() {
        $listContainer.html('<p style="grid-column:1/-1; text-align:center; padding:20px; color:#888;">데이터를 불러올 수 없습니다.</p>');
    });
}

function loadRegionalPreviews() {
    const cities = ['SEOUL', 'BUSAN', 'DAEGU', 'DAEJEON', 'JEJU'];
    cities.forEach(city => {
        $.get(contextPath + '/api/music/regional', { city: city }, function(data) {
            // [수정] data가 배열이고 내용이 있는지 확인
            if (data && Array.isArray(data) && data.length > 0) {
                const idPrefix = city.toLowerCase();
                const topSong = data[0].TITLE || data[0].m_title || '-';
                const topArtist = data[0].ARTIST || data[0].a_name || '-';
                $('#' + idPrefix + '-title').text(topSong);
                $('#' + idPrefix + '-artist').text(topArtist);
            }
        });
    });
}

function loadItunesMusic() {
    $.get(contextPath + "/api/music/rss/most-played", { limit: 8 }, function(data) {
        // [수정] data가 배열인지 확인
        if (!data || !Array.isArray(data)) {
            $('#itunes-list').html('<p style="grid-column:1/-1; text-align:center; color:#888;">트렌드 데이터를 불러올 수 없습니다.</p>');
            return;
        }

        let html = '';
        data.forEach(function(m) {
            if (!m) return;
            const t = (m.TITLE || 'Unknown').replace(/'/g, "\\'");
            const a = (m.ARTIST || 'Unknown').replace(/'/g, "\\'");
            const img = m.ALBUM_IMG || FALLBACK_IMG;
            html += '<div class="itunes-card" onclick="changeHeroAndPlay(\'' + t + '\', \'' + a + '\', \'' + img + '\')">'
                + '  <img src="' + toHighResArtwork(img) + '" style="width:100%; aspect-ratio:1/1; object-fit:cover; border-radius:8px;">'
                + '  <div class="city-top-song" style="margin-top:10px;">' + (m.TITLE || 'Unknown') + '</div>'
                + '  <div class="city-top-artist" style="color:#00f2ff;">' + (m.ARTIST || 'Unknown') + '</div>'
                + '</div>';
        });
        $('#itunes-list').html(html);
    });
}




/* --- 메인 기능: 태그 그리기 --- */
function drawTagCards() {
    const rawContextTags = [];
    <c:forEach var="ct" items="${homeContextTags}">rawContextTags.push("${ct}");</c:forEach>
    
    const locationTags = ["바다", "산/등산", "카페/작업", "헬스장", "공원/피크닉"];
    const weatherTags = ["더운 여름", "비 오는 날", "맑음", "흐림", "눈 오는 날"];
    
    // NOW & HERE 섹션
    let contextHtml = '<div id="geo-weather-card" class="location-card" style="display:none;">'
                    + '  <span class="city-name" id="geo-city">LOCATION</span>'
                    + '  <div class="city-top-song" id="geo-weather-title">날씨 확인 중...</div>'
                    + '  <div class="city-top-artist" id="geo-weather-desc">위치 정보를 불러오는 중</div>'
                    + '</div>';
    
    let addedCount = 0;
    rawContextTags.forEach(function(name) {
        if (locationTags.indexOf(name) !== -1 && addedCount < 4) {
            const no = tagNoMap[name] || 19;
            contextHtml += '<div class="location-card tag-' + no + '" onclick="goTag(\'' + name + '\', event)">'
                         + '  <span class="city-name">NEARBY PLACE</span>'
                         + '  <div class="city-top-song">' + name + '</div>'
                         + '  <div class="city-top-artist">지금 위치와 어울리는 추천</div>'
                         + '</div>';
            addedCount++;
        }
    });

    /* --- 수정된 drawTagCards 함수 일부 --- */
/* --- drawTagCards 함수 내부의 해당 구간을 이 코드로 통째로 바꾸세요 --- */
if (addedCount < 4) {
    locationTags.forEach(function(fallbackName) { // 루프 변수명이 fallbackName입니다.
    	console.log("현재 추가 시도 중인 fallbackName:", fallbackName);
        if (rawContextTags.indexOf(fallbackName) === -1 && addedCount < 4) {
            const no = tagNoMap[fallbackName] || 19;
            
            // [주의] 아래 'goTag'의 인자가 반드시 'fallbackName'이어야 합니다.
            // 만약 'name'이라고 적혀있다면, 위에서 쓴 변수가 아니므로 빈 값('')이 들어갑니다.
            contextHtml += '<div class="location-card tag-' + no + '" onclick="goTag(\'' + fallbackName + '\', event)">' 
                         + '  <span class="city-name">RECOMMENDED PLACE</span>'
                         + '  <div class="city-top-song">' + fallbackName + '</div>'
                         + '  <div class="city-top-artist">이런 장소는 어떠세요?</div>'
                         + '</div>';
            addedCount++;
        }
    });
}
    $('#context-list').html(contextHtml);

    // FOR YOUR MOOD 섹션
    const moodTags = [];
    <c:forEach var="mt" items="${homeMoodTags}">moodTags.push("${mt}");</c:forEach>
    
 // [수정 포인트] 필터링을 먼저 거친 후, 최종적으로 5개만 추출합니다.
    const filteredMoods = moodTags.filter(function(name) {
        // 날씨와 장소 태그가 아닌 것만 남김
        return weatherTags.indexOf(name) === -1 && locationTags.indexOf(name) === -1;
    });
    
    let personalHtml = '';
    filteredMoods.forEach(function(name, idx) {
        if (idx < 5) {
            const no = tagNoMap[name] || 9;
            personalHtml += '<div class="location-card tag-' + no + '" onclick="goTag(\'' + name + '\', event)">' // event 추가
                          + '  <span class="city-name">MY MOOD #' + (idx + 1) + '</span>'
                          + '  <div class="city-top-song">' + name + '</div>'
                          + '  <div class="city-top-artist">당신을 위한 맞춤 추천</div>'
                          + '</div>';
        }
    });
    
 // 만약 필터링 후 개수가 너무 적다면? (방어 코드: 기본 무드 태그 추가 가능)
    if (filteredMoods.length === 0) {
        personalHtml = '<p style="color:#888; text-align:center; width:100%;">맞춤 추천 테마를 불러오는 중입니다.</p>';
    }
    
    $('#personalized-list').html(personalHtml);
    renderContextWeather();
    
    console.log("카드 그리기 완료, 날씨 렌더링 시작");
}

function renderContextWeather() {
    if (!window.MusicApp) return;
    window.MusicApp.getWeatherData(function(data) {
        if (!data) return;
        const city = data.name.toUpperCase();
        const weatherId = data.weather[0].id;
        const temp = data.main.temp;
        let tagName = "맑음"; let bgImgNo = 14;

        if (temp > 30) { tagName = "더운 여름"; bgImgNo = 3; }
        else if (weatherId < 600) { tagName = "비 오는 날"; bgImgNo = 8; }
        else if (weatherId < 700) { tagName = "눈 오는 날"; bgImgNo = 16; }
        else if (weatherId > 800) { tagName = "흐림"; bgImgNo = 15; }

        $('#geo-city').text(city);
        $('#geo-weather-title').text(tagName);
        $('#geo-weather-desc').text(Math.round(temp) + "°C, 실시간 날씨 맞춤");
        $('#geo-weather-card').css({'background-image': 'url(${pageContext.request.contextPath}/img/Tag/' + bgImgNo + '.png)', 'display': 'block'})
                             .attr('onclick', "goTag('" + tagName + "', event)");
    });
}

/* --- 실행 및 이벤트 핸들러 --- */
/* --- 실행 및 이벤트 핸들러 --- */
$(document).ready(function() {
    // [수정] 팝업 로드 로직을 안전하게 변경
    $.get(contextPath + '/api/getPopups', function(list) {
        // list가 존재하고 배열인 경우에만 forEach 실행
        if (list && Array.isArray(list) && list.length > 0) {
            list.forEach(function(popup) {
                if (!popup) return;
                const no = popup.noticeNo || popup.noticeno || 1;
                if (!getCookie('hide_popup_' + no)) showLayerPopup(popup);
            });
        }
    }).fail(function() {
        console.log("팝업 데이터를 불러오는 데 실패했습니다.");
    });

    if (window.MusicApp) window.MusicApp.init("${loginUser.UNo}" || 0);
    
    // 필수 호출 함수들
    loadTop10();           
    loadRegionalPreviews(); 
    loadItunesMusic();     
    drawTagCards();
});


// --- 추가 함수: 팝업 생성 ---
// 팝업 생성 함수: 데이터 필드명을 더 꼼꼼하게 체크합니다.
// 1. 팝업 생성 함수
// 1. 팝업 생성 함수
// --- 팝업 관련 최종 통합 함수 (중복 제거용) ---
// 전역 변수로 팝업 개수 추적 (계단식 배치를 위해)
let popupCount = 0; // 팝업 개수 추적용 변수

function showLayerPopup(popup) {
    const title = popup.ntitle || popup.nTitle || "공지사항"; 
    const content = popup.ncontent || popup.nContent || "내용이 없습니다.";
    const no = popup.noticeNo || popup.noticeno || 1;

    // ✅ 계단식 좌표 계산 (30px씩 어긋나게)
    const offset = popupCount * 35; 
    const topPos = 120 + offset;
    const leftPos = 80 + offset;
    popupCount++;

    const modalHtml = `
        <div id="popup-modal-\${no}" class="custom-popup-sticker draggable-popup" 
             style="position: fixed; 
                    top: \${topPos}px; left: \${leftPos}px; 
                    width: 350px; background: #1a1a1a; 
                    border: 2px solid #ff0055; border-radius: 12px; 
                    box-shadow: 0 15px 40px rgba(0,0,0,0.8); 
                    z-index: \${100002 + popupCount}; color: #fff; overflow: hidden;">
            
            <div class="popup-handle" style="padding: 12px 15px; background: #222; cursor: move; display: flex; justify-content: space-between; align-items: center; user-select: none;">
                <strong style="color: #ff0055; font-size: 0.9rem;"><i class="fa-solid fa-grip-lines-vertical" style="margin-right:8px; opacity:0.5;"></i> \${title}</strong>
                <span onclick="closePopup(\${no})" style="cursor:pointer; color:#888; font-size: 1.5rem; line-height:1;">&times;</span>
            </div>

            <div class="popup-body-content" style="padding: 20px; max-height: 400px; overflow-y: auto; font-size: 0.9rem; line-height: 1.5; color: #eee;">
                \${content}
            </div>

            <div style="padding: 12px 15px; background: #111; display: flex; justify-content: space-between; align-items: center; border-top: 1px solid #333;">
                <label style="font-size: 11px; color: #bbb; cursor: pointer; display: flex; align-items: center;">
                    <input type="checkbox" id="no-more-\${no}" style="margin-right: 6px;"> 오늘 하루 보지 않기
                </label>
                <button onclick="closePopup(\${no})" 
                        style="background: #ff0055; border: none; color: #fff; padding: 5px 15px; border-radius: 4px; cursor: pointer; font-size: 11px; font-weight: bold;">
                    닫기
                </button>
            </div>
        </div>

        <style>
            /* 사진 크기 자동 조절 */
            #popup-modal-\${no} .popup-body-content img {
                max-width: 100% !important;
                height: auto !important;
                display: block;
                margin: 10px 0;
            }
        </style>
    `;
    
    $('body').append(modalHtml);
    makeDraggable(document.getElementById(`popup-modal-\${no}`));
}

function makeDraggable(el) {
    let pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
    const handle = el.querySelector(".popup-handle");

    if (handle) {
        handle.onmousedown = dragMouseDown;
    }

    function dragMouseDown(e) {
        e = e || window.event;
        // 버튼이나 체크박스 클릭 시에는 드래그 막기
        if (e.target.tagName === 'BUTTON' || e.target.tagName === 'INPUT') return;

        e.preventDefault();
        pos3 = e.clientX;
        pos4 = e.clientY;
        document.onmouseup = closeDragElement;
        document.onmousemove = elementDrag;
        
        // 클릭한 팝업을 가장 위로 올림 (하이픈 제거: zIndex)
        $(".custom-popup-sticker").css("z-index", 100002);
        el.style.zIndex = "100099"; 
    }

    function elementDrag(e) {
        e = e || window.event;
        e.preventDefault();
        pos1 = pos3 - e.clientX;
        pos2 = pos4 - e.clientY;
        pos3 = e.clientX;
        pos4 = e.clientY;
        
        // 팝업 위치 갱신
        el.style.top = (el.offsetTop - pos2) + "px";
        el.style.left = (el.offsetLeft - pos1) + "px";
    }

    function closeDragElement() {
        document.onmouseup = null;
        document.onmousemove = null;
    }
}

function closePopup(no) {
    console.log("닫기 시도 번호:", no); // 브라우저 콘솔(F12)에서 확인용

    // 1. 쿠키 저장 (체크박스 확인)
    if ($('#no-more-' + no).is(':checked')) {
        setCookie('hide_popup_' + no, 'true', 1);
    }

    // 2. 팝업 제거 (ID로 찾기 + 못 찾을 경우를 대비한 클래스 기반 탐색)
    const target = document.getElementById("popup-modal-" + no);
    if (target) {
        target.remove();
    } else {
        // ID로 못 찾으면 클래스와 data 속성 등으로 강제 제거
        $(`.custom-popup-sticker`).each(function() {
            if($(this).attr('id').indexOf(no) !== -1) {
                $(this).remove();
            }
        });
    }

    // 3. 카운트 리셋
    if ($('.custom-popup-sticker').length === 0) {
        popupCount = 0;
    }
}
// --- 추가 함수: 쿠키 유틸리티 ---
function setCookie(name, value, days) {
    let date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    document.cookie = name + '=' + value + ';expires=' + date.toUTCString() + ';path=/';
}

function getCookie(name) {
    let value = "; " + document.cookie;
    let parts = value.split("; " + name + "=");
    if (parts.length === 2) return parts.pop().split(";").shift();
}

//1. 권한 체크 함수 (통합 및 최적화)
function checkPremiumAccess(e) {
    if (e && typeof e.preventDefault === 'function') {
        e.preventDefault();
        e.stopPropagation();
    }

    const isSubscribed = "${isSubscribed}"; 
    const loginUser = "${loginUser.UNo}"; // UNo가 있으면 로그인 된 것으로 간주

    // 로그인 여부 확인
    if (!loginUser || loginUser === "0" || loginUser === "") {
        alert("로그인이 필요한 서비스입니다.");
        if(typeof openLoginModal === 'function') openLoginModal();
        return false;
    }

    // 구독 여부 확인
    if (isSubscribed === "false" || isSubscribed === "" || isSubscribed === "null") {
        if (confirm("이 기능은 프리미엄 구독 회원 전용입니다.\n구독 페이지로 이동하시겠습니까?")) {
            location.href = contextPath + "/user/subscription";
        }
        return false;
    }

    return true; 
}

// 2. 태그 이동 함수 (통합)
function goTag(tagName, e) {
    console.log("클릭된 태그:", tagName);
    
    // 권한 체크 먼저 수행
    if (!checkPremiumAccess(e)) {
        return; 
    }

    if(!tagName || tagName === '-') {
        console.log("태그 이름이 유효하지 않음");
        return;
    }

    const cleanTagName = tagName.replace(' 스타일', '').trim();
    const url = contextPath + "/music/recommendationList?tagName=" + encodeURIComponent(cleanTagName);
    console.log("이동 시도:", url);
    location.href = url;
}
</script>
</body>
</html>