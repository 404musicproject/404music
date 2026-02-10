<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" buffer="16kb" autoFlush="true" %>
<!DOCTYPE html>
<html>
<head>
<style>
    /* 메인 배경과 일치시키기 */
    body { background-color: #050505; color: #fff; }

    /* 대시보드 외곽 프레임 */
    .kibana-wrapper {
        max-width: 1400px;
        margin: 60px auto;
        padding: 20px;
        background: #0a0a0a;
        border: 1px solid #333;
        border-radius: 20px;
        box-shadow: 0 0 40px rgba(0, 242, 255, 0.15);
        position: relative;
    }

    /* 1. 상단 포인트 장식 (크기 및 디자인 강화) */
    .kibana-wrapper::before {
        content: "LIVE DATA ANALYTICS";
        position: absolute;
        top: -20px;
        left: 40px;
        background: linear-gradient(90deg, #ff0055, #ff5f56);
        color: white;
        padding: 8px 25px; /* 크기 키움 */
        font-size: 1rem;    /* 폰트 키움 */
        font-weight: 900;
        border-radius: 50px; /* 둥글게 변경 */
        letter-spacing: 2px;
        box-shadow: 0 5px 15px rgba(255, 0, 85, 0.4);
        z-index: 10;
    }

    /* 2. 오른쪽 상단 뒤로가기 버튼 스타일 */
    .back-button {
        position: absolute;
        top: -20px;
        right: 40px;
        background: #111;
        color: #00f2ff;
        text-decoration: none;
        padding: 8px 20px;
        border: 1px solid #00f2ff;
        border-radius: 50px;
        font-size: 0.9rem;
        font-weight: bold;
        transition: all 0.3s;
        z-index: 10;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .back-button:hover {
        background: #00f2ff;
        color: #000;
        box-shadow: 0 0 20px rgba(0, 242, 255, 0.5);
        transform: translateY(-2px);
    }

    /* iframe 설정 */
    .kibana-iframe {
        width: 100%;
        height: 2500px; 
        border: none;
        border-radius: 10px;
        background-color: #1a1b1e; 
        margin-top: 20px; /* 버튼들과 겹치지 않게 여백 추가 */
    }
</style>
</head>

<header><jsp:include page="/WEB-INF/views/common/Header.jsp" /></header> 

<main>
    <div class="kibana-wrapper">

		<a href="${pageContext.request.contextPath}/" class="back-button">
		    <i class="fas fa-arrow-left"></i> BACK TO HOME
		</a>

		    <iframe 
		    class="kibana-iframe"
		    src="http://192.168.10.46:5601/app/dashboards#/view/45e96950-018c-11f1-9d3e-5fb803ff8476?embed=true&_g=(filters%3A!()%2CrefreshInterval%3A(pause%3A!t%2Cvalue%3A0)%2Ctime%3A(from%3Anow-7d%2Cto%3Anow))">
		</iframe>
    </div>
</main>

<footer><jsp:include page="/WEB-INF/views/common/Footer.jsp" /></footer>

</html>