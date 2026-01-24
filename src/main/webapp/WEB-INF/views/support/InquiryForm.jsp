<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music // CREATE_INQUIRY</title>
    <style>
        /* Neon Retro Theme Variable */
        :root {
            --neon-cyan: #00f2ff;
            --neon-pink: #ff0055;
            --neon-purple: #bc13fe;
            --dark-bg: #050505;
            --grid-line: rgba(188, 19, 254, 0.15);
        }

        body { 
            background-color: var(--dark-bg); 
            color: var(--neon-cyan); 
            font-family: 'Courier New', monospace;
            background-image: linear-gradient(var(--grid-line) 1px, transparent 1px),
                              linear-gradient(90deg, var(--grid-line) 1px, transparent 1px);
            background-size: 30px 30px;
            margin: 0;
        }

        .form-container { 
            max-width: 800px; 
            margin: 60px auto; 
            padding: 40px; 
            border: 2px solid var(--neon-purple); 
            background: rgba(10, 10, 10, 0.9);
            box-shadow: 0 0 20px rgba(188, 19, 254, 0.3), inset 0 0 15px rgba(188, 19, 254, 0.1);
        }

        .form-title { 
            color: var(--neon-cyan); 
            border-bottom: 2px solid var(--neon-pink); 
            padding-bottom: 15px; 
            text-transform: uppercase;
            letter-spacing: 2px;
            text-shadow: 0 0 10px var(--neon-cyan);
            margin-bottom: 35px;
        }

        .input-group { margin-bottom: 30px; }
        
        .label-neon { 
            display: block; 
            color: var(--neon-pink); 
            margin-bottom: 12px; 
            font-weight: bold; 
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .retro-input { 
            width: 100%; 
            padding: 15px; 
            background: #000; 
            border: 1px solid var(--grid-line); 
            color: var(--neon-cyan); 
            outline: none; 
            box-sizing: border-box;
            font-family: inherit;
            transition: 0.3s;
        }

        .retro-input:focus { 
            border-color: var(--neon-cyan); 
            box-shadow: 0 0 15px var(--neon-cyan); 
        }

        /* 체크박스 커스텀 디자인 */
        .checkbox-group { 
            display: flex; 
            align-items: center; 
            margin-bottom: 35px;
            cursor: pointer;
        }
        
        .checkbox-group input[type="checkbox"] {
            width: 20px;
            height: 20px;
            appearance: none;
            border: 2px solid var(--neon-pink);
            background: transparent;
            margin-right: 15px;
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

        /* 전송 버튼 */
        .btn-neon-submit { 
            background: transparent; 
            color: var(--neon-pink); 
            border: 2px solid var(--neon-pink); 
            padding: 18px 30px; 
            cursor: pointer; 
            width: 100%; 
            font-weight: bold; 
            text-transform: uppercase;
            letter-spacing: 3px;
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

<div class="form-container">
    <h2 class="form-title">CREATE_INQUIRY_PACKET</h2>
    
    <form action="${pageContext.request.contextPath}/support/insertInquiry.do" method="post">
        <!-- 세션 유저 번호 -->
        <input type="hidden" name="uNo" value="${sessionScope.loginUser.UNo}">
        
        <div class="input-group">
            <label class="label-neon">SUBJECT_HEADER</label>
            <input type="text" name="iTitle" class="retro-input" required placeholder="ENTER SUBJECT...">
        </div>
        
        <div class="input-group">
            <label class="label-neon">ENCRYPTED_MESSAGE_BODY</label>
            <textarea name="iContent" rows="10" class="retro-input" required placeholder="ENTER DATA..."></textarea>
        </div>

        <div class="checkbox-group">
            <input type="checkbox" name="iIsSecret" value="Y" id="secret">
            <label for="secret" class="label-neon" style="margin-bottom:0; cursor:pointer;">SET_PRIVATE_ENCRYPTION</label>
        </div>
        
        <button type="submit" class="btn-neon-submit">TRANSMIT_PACKET_TO_ADMIN</button>
    </form>
</div>

<jsp:include page="/WEB-INF/views/common/Footer.jsp" />
</body>
</html>