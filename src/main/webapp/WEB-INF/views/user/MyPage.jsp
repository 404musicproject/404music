<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>MYPAGE | SYSTEM</title>
    <style>
        /* 기본 여백 초기화 및 배경색 강제 적용 */
        html, body {
            margin: 0 !important;
            padding: 0 !important;
            background-color: #000000 !important; /* 배경 검정색 강제 */
            width: 100%;
            height: 100%;
        }

        /* 헤더 스타일 유지 (헤더가 깨지는 걸 방지) */
        header {
            width: 100%;
            display: block;
        }

        /* 마이페이지 메인 컨테이너 - flexbox로 중앙 정렬 */
        .mypage-container {
            display: flex !important;
            justify-content: center !important;
            align-items: center !important;
            min-height: 80vh; /* 헤더를 제외한 나머지 공간에서 중앙 */
            background-color: #000;
        }

        /* 정보 카드 박스 */
        .neon-card {
            width: 450px;
            padding: 40px;
            border: 2px solid #00f2ff !important; /* 하늘색 네온 테두리 */
            background-color: #000 !important;
            box-shadow: 0 0 15px #00f2ff; /* 바깥 네온 광채 */
            text-align: center;
        }

        .neon-title {
            color: #00f2ff !important;
            text-shadow: 0 0 10px #00f2ff;
            margin-bottom: 30px;
            font-family: 'Courier New', monospace;
            letter-spacing: 2px;
        }

        /* 정보 줄 레이아웃 */
        .info-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px dotted #00f2ff;
        }

        .label {
            color: #00f2ff !important;
            font-weight: bold;
            font-size: 14px;
        }

        .value {
            color: #ffffff !important; /* 값은 흰색으로 잘 보이게 */
            font-size: 14px;
        }

        /* 수정 버튼 */
        .edit-btn {
            width: 100%;
            padding: 12px;
            margin-top: 20px;
            background-color: transparent;
            border: 1px solid #ff0055 !important; /* 핑크색 포인트 */
            color: #ff0055 !important;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
        }

        .edit-btn:hover {
            background-color: #ff0055 !important;
            color: #000 !important;
            box-shadow: 0 0 15px #ff0055;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/Header.jsp" />

    <div class="mypage-container">
        <div class="neon-card">
            <h2 class="neon-title">USER ACCESS INFO</h2>
            
            <div class="info-row">
                <span class="label">ID / EMAIL</span>
                <span class="value">${sessionScope.loginUser.UId}</span>
            </div>
            
            <div class="info-row">
                <span class="label">NICKNAME</span>
                <span class="value">${sessionScope.loginUser.UNick}</span>
            </div>

            <div class="info-row">
                <span class="label">JOIN DATE</span>
                <span class="value">${sessionScope.loginUser.UCreateAt}</span>
            </div>

            <button class="edit-btn" onclick="location.href='/settings'">EDIT PROFILE</button>
        </div>
    </div>
</body>
</html>