<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>404Music | Header</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/ToastMessage.css">
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style type="text/css">
/* =========================
   HEADER 기본 레이아웃
========================= */
.main-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 40px;
    height: 70px; /* 높이 약간 조절 */
    background-color: #0f0f0f; 
    box-sizing: border-box;
    width: 100%;
    position: sticky;
    top: 0;
    z-index: 1000;
    border-bottom: 1px solid #2a2a2a;
}

/* =========================
   LOGO
========================= */
.header-left {
    display: flex;
    align-items: center;
    flex-shrink: 0;
}

.header-logo {
    height: 55px;
    width: auto;
    transition: all 0.3s ease;
}
.header-logo:hover {
    transform: scale(1.05);
    filter: brightness(1.2) drop-shadow(0 0 8px rgba(0, 242, 255, 0.5));
}

/* =========================
   SEARCH FORM
========================= */
.header-center {
    flex-grow: 1;
    display: flex;
    justify-content: center;
    max-width: 600px;
}

.search-form {
    display: flex;
    align-items: center;
    width: 100%;
    height: 40px;
    background-color: #000;
    border-radius: 30px; 
    border: 2px solid #00f2ff; 
    box-shadow: 0 0 10px rgba(0, 242, 255, 0.2);
    overflow: hidden;
}

.search-select {
    width: 100px;
    height: 100%;
    background: transparent;
    border: none;
    outline: none;
    color: #00f2ff;
    font-weight: bold;
    font-size: 0.8rem;
    padding: 0 10px 0 15px;
    cursor: pointer;
    border-right: 1px solid rgba(0, 242, 255, 0.3);
}

.search-select option { background: #0f0f0f; color: #fff; }

.search-form input {
    flex: 1;
    height: 100%;
    background: transparent;
    border: none;
    outline: none;
    color: #fff;
    font-size: 0.9rem;
    padding: 0 15px;
}

.search-button {
    width: 45px;
    height: 100%;
    background: transparent;
    border: none;
    color: #ff0055; 
    font-size: 18px;
    cursor: pointer;
    transition: 0.2s;
}
.search-button:hover { transform: scale(1.1); text-shadow: 0 0 8px #ff0055; }

/* =========================
   RIGHT AREA (User Menu)
========================= */
.header-right {
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 15px;
    flex-shrink: 0;
    min-width: 280px;
}

.user-status-group {
    display: flex;
    align-items: center;
    gap: 12px;
}

.auth-info {
    display: flex;
    align-items: center;
    gap: 12px;
}

.user-greeting { color: #fff; font-size: 0.85rem; }
.user-greeting strong { color: #00f2ff; }

.login-text-btn, .lib-link {
    color: #fff;
    font-weight: 600;
    font-size: 0.85rem;
    text-decoration: none;
    transition: 0.25s;
    display: flex;
    align-items: center;
    gap: 5px;
}
.login-text-btn:hover, .lib-link:hover { color: #ff0055; }
.lib-link i { color: #00f2ff; }

.auth-divider { color: #333; font-size: 0.8rem; }

/* PROFILE & DROPDOWN */
.profile-container {
    position: relative;
    margin-left: 5px;
}

.profile-img-box {
    width: 38px;
    height: 38px;
    border-radius: 50%;
    border: 2px solid #00f2ff;
    overflow: hidden;
    cursor: pointer;
    transition: 0.3s;
}
.profile-img-box:hover { border-color: #ff0055; transform: scale(1.05); }

.header-profile-img { width: 100%; height: 100%; object-fit: cover; }

.dropdown-table-menu {
    display: none;
    position: absolute;
    top: 50px;
    right: 0;
    width: 160px;
    background-color: #161616;
    border: 1px solid #333;
    border-radius: 8px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.6);
    z-index: 1100;
    overflow: hidden;
}

.dropdown-table-menu table { width: 100%; border-collapse: collapse; }
.dropdown-table-menu td {
    padding: 12px 15px;
    color: #eee;
    font-size: 0.85rem;
    cursor: pointer;
    border-bottom: 1px solid #222;
    transition: 0.2s;
}
.dropdown-table-menu tr:hover td { background-color: #222; color: #00f2ff; }
.dropdown-table-menu .menu-logout:hover { color: #ff0055; }
</style>
</head>
<body>

<header class="main-header">
    <div class="header-left">
        <a href="/" class="logo-link">
            <svg class="header-logo" viewBox="0 0 340 80" xmlns="http://www.w3.org/2000/svg">
                <defs>
                    <filter id="cyanGlow"><feGaussianBlur stdDeviation="2.5" result="blur" /><feComposite in="SourceGraphic" in2="blur" operator="over" /></filter>
                    <filter id="pinkGlow"><feGaussianBlur stdDeviation="3" result="blur" /><feComposite in="SourceGraphic" in2="blur" operator="over" /></filter>
                </defs>
                <g transform="translate(10, 10)">
                    <path d="M10 40 Q10 10 40 10 Q70 10 70 40" fill="none" stroke="#00f2ff" stroke-width="5" filter="url(#cyanGlow)" />
                    <rect x="5" y="40" width="12" height="20" rx="2" fill="#ff0055" filter="url(#pinkGlow)" />
                    <rect x="63" y="40" width="12" height="20" rx="2" fill="#ff0055" filter="url(#pinkGlow)" />
                </g>
                <text x="90" y="52" font-family="Verdana, sans-serif" font-weight="900" font-size="40" fill="#ff0055" filter="url(#pinkGlow)">404</text>
                <text x="175" y="52" font-family="Verdana, sans-serif" font-weight="900" font-size="40" fill="#00f2ff" filter="url(#cyanGlow)">MUSIC</text>
            </svg>
        </a>
    </div>

    <div class="header-center">
        <form action="${pageContext.request.contextPath}/musicSearch" method="get" class="search-form" id="headerSearchForm">
            <select name="searchType" class="search-select" id="headerSearchType">
                <option value="TITLE" ${param.searchType == 'TITLE' ? 'selected' : ''}>제목</option>
                <option value="ARTIST" ${param.searchType == 'ARTIST' ? 'selected' : ''}>아티스트</option>
                <option value="ALBUM" ${param.searchType == 'ALBUM' ? 'selected' : ''}>앨범</option>
                <option value="LYRICS" ${param.searchType == 'LYRICS' ? 'selected' : ''}>가사</option>
                <option value="ALL" ${empty param.searchType || param.searchType == 'ALL' ? 'selected' : ''}>전체</option>
            </select>
            <input type="text" name="searchKeyword" id="headerSearchKeyword" value="${param.searchKeyword}" placeholder="검색어를 입력하세요">
            <button type="submit" class="search-button"><i class="fa-solid fa-magnifying-glass"></i></button>
        </form>
    </div>
    
    <div class="header-right">
        <div class="user-status-group">
            <c:choose>
                <c:when test="${empty sessionScope.loginUser}">
                    <a href="javascript:void(0)" onclick="openLoginModal()" class="login-text-btn">LOGIN</a>
                    <span class="auth-divider">|</span>
                    <a href="/signup" class="login-text-btn">SIGN UP</a>
                </c:when>
                <c:otherwise>
                    <div class="auth-info">
                        <span class="user-greeting"><strong>${sessionScope.loginUser.UNick}</strong>님</span>
                        <a href="${pageContext.request.contextPath}/music/myLibrary" class="lib-link">
                            <i class="fa-solid fa-box-archive"></i> LIBRARY
                        </a>
                    </div>
                    
                    <div class="profile-container">
                        <div class="profile-img-box" onclick="toggleProfileMenu(event)">
                            <img src="${not empty sessionScope.loginUser.UProfileImg ? sessionScope.loginUser.UProfileImg : '/img/default-profile.png'}" 
                                 alt="Profile" class="header-profile-img">
                        </div>
                        <div id="profileDropdown" class="dropdown-table-menu">
                            <table>
                                <tr onclick="location.href='/user/mypage'"><td><i class="fa-solid fa-circle-user"></i> My Page</td></tr>
                                <tr onclick="location.href='/logout'"><td class="menu-logout"><i class="fa-solid fa-power-off"></i> Logout</td></tr>
                            </table>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</header>

<jsp:include page="/WEB-INF/views/common/Login.jsp" />

<script>
// 프로필 드롭다운 토글
function toggleProfileMenu(e) {
    e.stopPropagation();
    const menu = document.getElementById('profileDropdown');
    if (!menu) return;
    const isVisible = menu.style.display === 'block';
    menu.style.display = isVisible ? 'none' : 'block';
}

// 메뉴 바깥 클릭 시 닫기
window.addEventListener('click', function() {
    const menu = document.getElementById('profileDropdown');
    if (menu) menu.style.display = 'none';
});

// 헤더 검색 placeholder 업데이트
document.addEventListener('DOMContentLoaded', function () {
    const sel = document.getElementById('headerSearchType');
    const input = document.getElementById('headerSearchKeyword');
    if (!sel || !input) return;

    const setPlaceholder = () => {
        const v = (sel.value || 'TITLE').toUpperCase();
        switch (v) {
            case 'ARTIST': input.placeholder = '아티스트 이름을 입력하세요'; break;
            case 'ALBUM':  input.placeholder = '앨범 제목을 입력하세요'; break;
            case 'LYRICS': input.placeholder = '가사 키워드를 입력하세요'; break;
            case 'ALL':    input.placeholder = '통합 검색어를 입력하세요'; break;
            default:       input.placeholder = '노래 제목을 입력하세요';
        }
    };
    sel.addEventListener('change', setPlaceholder);
    setPlaceholder();
});
</script>

</body>
</html>