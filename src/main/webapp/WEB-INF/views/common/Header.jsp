<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>header</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Header.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ToastMessage.css">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
       <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
<div class="main-header">
    <div class="header-left">
    <a href="/" style="text-decoration: none; display: inline-block;">
        <svg class="header-logo" viewBox="0 0 340 80" xmlns="http://www.w3.org/2000/svg" style="display: block;">
            <defs>
                <filter id="cyanGlow" x="-30%" y="-30%" width="160%" height="160%">
                    <feGaussianBlur stdDeviation="2.5" result="blur" />
                    <feComposite in="SourceGraphic" in2="blur" operator="over" />
                </filter>
                <filter id="pinkGlow" x="-30%" y="-30%" width="160%" height="160%">
                    <feGaussianBlur stdDeviation="3" result="blur" />
                    <feComposite in="SourceGraphic" in2="blur" operator="over" />
                </filter>
            </defs>

            <g transform="translate(10, 10)">
                <path d="M10 40 Q10 10 40 10 Q70 10 70 40" fill="none" stroke="#00f2ff" stroke-width="5" filter="url(#cyanGlow)" />
                <rect x="5" y="40" width="12" height="20" rx="2" fill="#ff0055" filter="url(#pinkGlow)" />
                <rect x="63" y="40" width="12" height="20" rx="2" fill="#ff0055" filter="url(#pinkGlow)" />
            </g>

            <text x="90" y="52" font-family="Verdana, sans-serif" font-weight="900" font-size="40" fill="#ff0055" filter="url(#pinkGlow)">
                404
            </text>

            <text x="175" y="52" font-family="Verdana, sans-serif" font-weight="900" font-size="40" fill="#00f2ff" filter="url(#cyanGlow)">
                MUSIC
            </text>
            
            <line x1="90" y1="65" x2="320" y2="65" stroke="#00f2ff" stroke-width="2" stroke-dasharray="100 5 20 5" filter="url(#cyanGlow)" />
            <line x1="90" y1="68" x2="250" y2="68" stroke="#ff0055" stroke-width="1" filter="url(#pinkGlow)" />
        </svg>
        </a>
</div>

    <div class="header-center">
	    <%-- /MusicSearch 를 /musicSearch 로 변경 --%>
	    <form action="/musicSearch" method="get" class="search-form">
	        <input type="text" name="searchKeyword" placeholder="어떤 음악을 검색하시겠습니까?">
	        <button type="submit" class="search-button">
	            <i class="fa-solid fa-magnifying-glass"></i>
	        </button>
	    </form>
	</div>
    
<div class="header-right">
    <div class="user-status-group">
        <c:choose>
            <c:when test="${empty sessionScope.loginUser}">
                <a href="javascript:void(0)" onclick="openLoginModal()" class="login-text-btn">LOGIN</a>
                <span class="auth-divider">|</span>
                <a href="/signup" class="login-text-btn">회원가입</a>
            </c:when>
            <c:otherwise>
                <div class="auth-info">
                    <span class="user-greeting"><strong>${sessionScope.loginUser.UNick}</strong>님</span>
                    <span class="auth-divider">|</span>
                    <a href="${pageContext.request.contextPath}/music/myLibrary">
					    <i class="fa-solid fa-box-archive"></i> MY LIBRARY
					</a>
                    <a href="/logout" class="login-text-btn">LOGOUT</a>
                </div>
                
                <%-- 프로필 컨테이너: 이미지와 드롭다운을 하나로 묶음 --%>
                <div class="profile-container">
                    <div class="profile-img-box" onclick="toggleProfileMenu(event)">
                        <img src="${not empty sessionScope.loginUser.UProfileImg ? sessionScope.loginUser.UProfileImg : '/img/default-profile.png'}" 
                             alt="Profile" class="header-profile-img">
                    </div>

                    <%-- 드롭다운 메뉴가 여기에 있어야 relative 기준점에 맞춰서 뜹니다 --%>
                    <div id="profileDropdown" class="dropdown-table-menu">
                        <table>
                            <tr onclick="location.href='/user/mypage'">
                                <td>Mypage</td>
                            </tr>
                            <tr onclick="location.href='/logout'">
                                <td class="menu-logout">로그아웃</td>
                            </tr>
                        </table>
                    </div>
                </div> <%-- .profile-container 끝 --%>
            </c:otherwise>
        </c:choose>
    </div>
</div>
<jsp:include page="/WEB-INF/views/common/Login.jsp" />
</div>
</body>
<script>
//검색창 토글
function toggleSearch() {
    const box = document.getElementById('searchBox');
    const input = document.getElementById('searchInput');
    box.classList.add('open');
    input.focus();
}

function closeSearch() {
    const box = document.getElementById('searchBox');
    const input = document.getElementById('searchInput');
    if (input.value === "") {
        box.classList.remove('open');
    }
}

// 프로필 드롭다운
function toggleProfileMenu(e) {
    e.stopPropagation(); // 클릭 이벤트 전파 방지
    
    const menu = document.getElementById('profileDropdown');
    const caret = document.querySelector('.caret'); // 화살표 아이콘이 있다면
    
    // [중요] menu가 존재하지 않으면 함수를 즉시 종료합니다.
    if (!menu) {
        console.log("드롭다운 메뉴를 찾을 수 없습니다. (로그인 상태 확인 필요)");
        return;
    }
    
    const isVisible = menu.style.display === 'block';
    menu.style.display = isVisible ? 'none' : 'block';
    
    if (caret) {
        caret.style.transform = isVisible ? 'rotate(0deg)' : 'rotate(180deg)';
    }
}

// 화면 전환
function openProfileManage() {
    document.getElementById('profileSelectView').style.display = 'none';
    document.getElementById('profileManageView').style.display = 'flex';
}

function closeProfileManage() {
    document.getElementById('profileSelectView').style.display = 'flex';
    document.getElementById('profileManageView').style.display = 'none';
}

// 이미지 변경
function applyIcon(imgName) {
    if(confirm("이 아이콘으로 변경하시겠습니까?")) {
        location.href = "profile_main.jsp?changeImg=" + imgName;
    }
}

</script>
</html>