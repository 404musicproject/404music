<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music Main Home</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Footer.css">
</head>
<body style="background-color: #050505;"> 
<%@ include file="/WEB-INF/views/common/Header.jsp" %>
    <main style="min-height: 600px; padding: 40px; color: #00f2ff; font-family: 'Courier New', monospace;">
        <h2 style="text-shadow: 0 0 10px #00f2ff; border-left: 5px solid #ff0055; padding-left: 15px;">
            TODAY'S RETRO PICK
        </h2>
        <p style="margin-top: 20px;">환영합니다! 404Music에서 최고의 음악을 찾아보세요.</p>
        
        <div style="margin-top: 40px; border: 1px dashed #ff0055; padding: 20px;">
            <p>[음악 리스트가 여기에 출력됩니다]</p>
        </div>
    </main>
<%@ include file="/WEB-INF/views/common/Footer.jsp" %>
<script>
document.addEventListener("DOMContentLoaded", function() {
    console.log("404 MUSIC SYSTEM ONLINE");
    
    // 섹션에 마우스를 올리면 깜빡이는 효과
    const sections = document.querySelectorAll('.retro-section');
    sections.forEach(sec => {
        sec.addEventListener('mouseenter', () => {
            sec.style.borderColor = '#ffff00';
        });
        sec.addEventListener('mouseleave', () => {
            sec.style.borderColor = '#00ffff';
        });
    });
});
</script>
</body>
</html>