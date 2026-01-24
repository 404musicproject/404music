<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>FOOTER</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Footer.css">
</head>
<body>
    <footer class="neon-footer">
        <div class="footer-container">
            <div class="footer-copyright">
                <!-- 현재 날짜 2026년 기준 저작권 표시 -->
                <p>Copyright © 2026 404Music Inc. 모든 권리 보유.</p>
            </div>
            
            <nav class="footer-nav">
                <!-- 개인정보처리방침은 법적 고지사항이므로 단독 페이지 유지 권장 -->
                <a href="${pageContext.request.contextPath}/terms" class="neon-link">개인정보처리방침</a>
                <span class="sep">|</span>
                
                <!-- [수정] 통합 고객 센터의 NOTICE 탭으로 연결 -->
                <a href="${pageContext.request.contextPath}/support?mode=notice" class="neon-link">공지사항</a>
                <span class="sep">|</span>
                
                <!-- [수정] 통합 고객 센터의 INQUIRY 탭으로 연결 -->
                <a href="${pageContext.request.contextPath}/support?mode=inquiry" class="neon-link">1:1 문의</a>
                <span class="sep">|</span>
                
                <!-- [추가] 통합 고객 센터의 FAQ 탭으로 연결 -->
                <a href="${pageContext.request.contextPath}/support?mode=faq" class="neon-link">FAQ</a>
            </nav>
        </div>
    </footer>
</body>
</html>