<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music // 문의 작성</title>

    <style>
        :root {
            --neon-cyan: #00f2ff;
            --neon-pink: #ff0055;
            --neon-purple: #bc13fe;
            --dark-bg: #050505;
        }

        .support-page {
            min-height: 100vh;
            background-color: #050505;
            background-image: none !important;
            padding-top: 60px;
        }

        .form-container { 
            max-width: 800px; 
            margin: 0 auto; 
            padding: 40px;
            border: none;
            background: transparent;
            box-shadow: none;
        }

        .form-title { 
            color: var(--neon-cyan); 
            padding-left: 16px;
            margin-bottom: 30px;
            border-left: 4px solid var(--neon-pink);
            text-transform: uppercase;
            letter-spacing: 2px;
            text-shadow: 0 0 10px var(--neon-cyan);
            font-size: 12px;
        }

        .label-neon { 
            display: block; 
            color: var(--neon-pink); 
            margin-bottom: 12px; 
            font-weight: bold; 
            text-transform: uppercase;
            letter-spacing: 1px;
            font-size:12px;
        }

        .retro-input { 
            width: 100%; 
            padding: 10px; 
            background: #000;
            border: 1px solid rgba(0,242,255,0.35);
            color: var(--neon-cyan); 
            outline: none; 
            box-sizing: border-box;
            font-family: inherit;
            transition: 0.3s;
            font-size:10px;
            margin-bottom: 20px;
        }

        .retro-input:focus { 
            border-color: var(--neon-cyan); 
            box-shadow: 0 0 15px var(--neon-cyan); 
        }

        .checkbox-group { 
            display: flex; 
            align-items: center; 
            margin-bottom: 25px;
            cursor: pointer;
        }

        .checkbox-group input[type="checkbox"] {
            width: 16px;
            height: 16px;
            appearance: none;
            border: 2px solid var(--neon-pink);
            background: transparent;
            margin-right: 12px;
            cursor: pointer;
            position: relative;
        }

        .checkbox-group input[type="checkbox"]:checked {
            background: var(--neon-pink);
            box-shadow: 0 0 10px var(--neon-pink);
        }

        .checkbox-group input[type="checkbox"]:checked::after {
            content: '✔';
            position: absolute;
            top: -2px;
            left: 2px;
            color: #fff;
            font-size: 16px;
        }

        .btn-neon-submit { 
            background: transparent; 
            color: var(--neon-pink); 
            border: 2px solid var(--neon-pink); 
            padding: 12px 30px; 
            cursor: pointer; 
            width: 100%; 
            font-weight: bold;
            font-size:10px;
            text-transform: uppercase;
            letter-spacing: 2px;
            transition: 0.4s;
            font-family: inherit;
        }

        .btn-neon-submit:hover { 
            background: var(--neon-pink); 
            color: #fff; 
            box-shadow: 0 0 30px var(--neon-pink); 
        }
    </style>
</head>

<body>

<jsp:include page="/WEB-INF/views/common/Header.jsp" />

<div class="support-page">

    <div class="form-container">
        <h2 class="form-title">문의 생성</h2>

        <form action="${pageContext.request.contextPath}/support/insertInquiry.do" method="post">

            <!-- 세션 유저 번호 -->
            <input type="hidden" name="uNo" value="${sessionScope.loginUser.UNo}">

            <div class="input-group">
                <label class="label-neon">제목</label>
                <input type="text"
                       name="iTitle"
                       class="retro-input"
                       required
                       placeholder="제목을 입력하세요...">
            </div>

            <div class="input-group">
                <label class="label-neon">암호화된 내용 본문</label>
                <textarea name="iContent"
                          rows="10"
                          class="retro-input"
                          required
                          placeholder="내용을 입력하세요..."></textarea>
            </div>

            <div class="checkbox-group">
                <input type="checkbox" name="iIsSecret" value="Y" id="secret">
                <label for="secret"
                       class="label-neon"
                       style="margin-bottom:0; cursor:pointer;">
                    비공개 암호화 설정
                </label>
            </div>

            <button type="submit" class="btn-neon-submit">
                관리자에게 전송
            </button>
        </form>
    </div>
</div>
<jsp:include page="/WEB-INF/views/common/Footer.jsp" />
</body>
</html>