<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" buffer="32kb" autoFlush="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music | 추천 카테고리</title>
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/music-chart.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <style>
        h3 { border-bottom: 1px solid #ddd; padding-top: 20px; margin-bottom: 15px; }
        .category-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 20px;
            padding-top: 10px;
        }
        .category-item {
            background-color: #333;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .category-item:hover {
            background-color: #555;
        }
        .category-item a {
            color: white;
            text-decoration: none;
            font-weight: bold;
        }
    </style>
</head>
<body>

<header><%@ include file="/WEB-INF/views/common/Header.jsp" %></header>

<main>
    <div class="container">
        <h2>상황별 &amp; 날씨별 추천</h2>

        <h3>활동 (ACTIVITY)</h3>
        <div class="category-grid">
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=운동">운동 🏃‍♀️</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=에너지 충전">에너지 충전 ⚡</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=휴식">휴식 ☕</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=집중">집중 🎧</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=파티">파티 🎉</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=잠잘 때">잠잘 때 😴</a></div>
        </div>

        <h3>기분 (MOOD)</h3>
        <div class="category-grid">
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=행복한 기분">행복한 기분 😊</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=로맨스">로맨스 ❤️</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=슬픔">슬픔 😢</a></div>
        </div>
        
        <h3>날씨 (WEATHER)</h3>
        <div class="category-grid">
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=맑고 화창한 날">맑고 화창한 날 ☀️</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=비 오는 날">비 오는 날 🌧️</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=흐린 날">흐린 날 ☁️</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=추운 겨울">추운 겨울 ❄️</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=더운 여름">더운 여름 🏖️</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=바람 부는 날">바람 부는 날 💨</a></div>
        </div>
    </div>
</main>

<footer><%@ include file="/WEB-INF/views/common/Footer.jsp" %></footer>
</body>
</html>