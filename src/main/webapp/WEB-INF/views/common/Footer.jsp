<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>FOOTER</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
</head>
<body>
    <footer class="neon-footer">
        <div class="footer-container">
            <div class="footer-copyright">
                <p>Copyright © 2026 Apple Inc. 모든 권리 보유.</p>
            </div>
            
            <nav class="footer-nav">
                <a href="${pageContext.request.contextPath}/terms" class="neon-link">개인정보처리방침</a>
                <span class="sep">|</span>
                <a href="${pageContext.request.contextPath}/notice" class="neon-link">공지사항</a>
                <span class="sep">|</span>
                <a href="${pageContext.request.contextPath}/qna" class="neon-link">1:1 문의</a>
            </nav>
        </div>
    </footer>

</body>
</html>