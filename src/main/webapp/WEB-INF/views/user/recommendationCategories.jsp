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
        h3 { border-bottom: 1px solid #ddd; padding-top: 30px; margin-bottom: 15px; color: #eee; }
        .category-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
            gap: 15px;
            padding-top: 10px;
        }
        .category-item {
            background-color: #333;
            border-radius: 8px;
            text-align: center;
            cursor: pointer;
            transition: transform 0.2s, background-color 0.3s;
        }
        .category-item:hover {
            background-color: #4a4a4a;
            transform: translateY(-3px);
        }
        .category-item a {
            display: block;
            padding: 20px;
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
        <h2>취향 저격 테마별 추천</h2>

        <h3>기분 (MOOD)</h3>
        <div class="category-grid">
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=행복한 기분">행복한 기분 😊</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=자신감 뿜뿜">자신감 뿜뿜 😎</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=스트레스 해소">스트레스 해소 😫</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=슬픔">슬픔 😢</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=로맨틱">로맨틱 ❤️</a></div>
        </div>

        <h3>활동 (ACTIVITY)</h3>
        <div class="category-grid">
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=파티">파티 🎉</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=운동">운동 🏋️‍♂️</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=휴식">휴식 ☕</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=요리할 때">요리할 때 👨‍🍳</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=집중">집중 📖</a></div>
        </div>

        <h3>날씨 (WEATHER)</h3>
        <div class="category-grid">
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=더운 여름">더운 여름 🏖️</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=비 오는 날">비 오는 날 🌧️</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=맑음">맑음 ☀️</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=흐림">흐림 ☁️</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=눈 오는 날">눈 오는 날 ❄️</a></div>
        </div>

        <h3>시간 & 장소 (TIME & LOCATION)</h3>
        <div class="category-grid">
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=새벽 감성">새벽 감성 🌙</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=바다">바다 🌊</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=산/등산">산/등산 🏔️</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=카페/작업">카페/작업 💻</a></div>
            <div class="category-item"><a href="${pageContext.request.contextPath}/music/recommendationList?tagName=헬스장">헬스장 💪</a></div>
        </div>
    </div>
</main>

<footer><%@ include file="/WEB-INF/views/common/Footer.jsp" %></footer>
</body>
</html>