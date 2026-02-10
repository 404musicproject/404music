<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>PROFILE SETTINGS | 404MUSIC</title>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&display=swap" rel="stylesheet">

    <style>
        body {
            background-color: #000 !important;
            color: #fff;
            font-family: 'Pretendard', sans-serif;
            margin: 0;
        }

        .wrap {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 40px 16px;
            background: radial-gradient(circle at center, #0a0a0a 0%, #000 100%);
        }

        /* 메인 네온 카드 스타일 */
        .card {
            width: 100%;
            max-width: 480px;
            padding: 50px 40px;
            background: #080808;
            border: 1px solid #1a1a1a;
            position: relative;
            box-shadow: 0 20px 50px rgba(0,0,0,0.9);
            border-radius: 4px; /* 우리 스타일은 약간 각진 느낌 */
        }

        /* 상단 네온 라인 애니메이션 */
        .card::before {
            content: ""; position: absolute; top: -1px; left: -1px; right: -1px; height: 3px;
            background: linear-gradient(90deg, #ff0055, #00f2ff, #ff0055);
            background-size: 200% auto;
            animation: neonFlow 3s linear infinite;
        }
        @keyframes neonFlow { to { background-position: 200% center; } }

        h2 {
            font-family: 'Orbitron', sans-serif;
            font-weight: 900;
            color: #ff0055 !important;
            text-shadow: 0 0 15px rgba(255, 0, 85, 0.5);
            letter-spacing: 4px;
            text-transform: uppercase;
            margin: 0 0 10px;
        }

        .sub {
		    margin: 0 0 30px;
		    color: #bbb; /* 기존 #555에서 밝게 조정하여 가독성 향상 */
		    font-size: 13px;
		    letter-spacing: 1.5px;
		    font-weight: 500;
		}

        /* 프로필 미리보기 서클 */
        .image-preview-circle {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            border: 2px solid #222;
            background-color: #111;
            overflow: hidden;
            margin: 0 auto 25px;
            transition: 0.4s;
            position: relative;
        }
        
        /* 선택된 이미지 강조 */
        .image-preview-circle.active {
            border-color: #00f2ff;
            box-shadow: 0 0 20px rgba(0, 242, 255, 0.4);
        }

        #previewImg {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .preset-title {
            color: #ff0055;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 2px;
            margin-bottom: 20px;
            text-transform: uppercase;
        }

        /* 프리셋 그리드 */
        .preset-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            margin-bottom: 35px;
        }

        .preset-item {
            aspect-ratio: 1/1;
            border-radius: 8px;
            overflow: hidden;
            border: 1px solid #222;
            background: #0c0c0c;
            cursor: pointer;
            transition: 0.3s;
        }

        /* [가독성 개선] 프리셋 아이템 가시성 확보 */
		.preset-item img {
		    width: 100%;
		    height: 100%;
		    object-fit: cover;
		    opacity: 0.8; /* 기본 불투명도를 높여서 이미지가 더 잘 보이게 수정 */
		    transition: 0.3s;
		}

        .preset-item:hover img,
		.preset-item.selected img {
		    opacity: 1;
		    filter: brightness(1.1); /* 선택 시 약간 더 밝게 */
		}

        .preset-item.selected {
            border-color: #00f2ff;
            box-shadow: 0 0 15px rgba(0, 242, 255, 0.3);
        }
        
        .preset-item.selected img {
            opacity: 1;
        }

        /* 버튼 그룹 */
        .btn-group {
		    display: flex;
		    flex-direction: column;
		    gap: 15px; /* 버튼 사이 간격 */
		    margin-top: 20px;
		}

        .save-btn, .back-btn {
		    width: 100%;
		    padding: 16px;
		    font-family: 'Pretendard', sans-serif;
		    font-weight: 700;
		    font-size: 15px;
		    cursor: pointer;
		    transition: 0.3s;
		    letter-spacing: 2px;
		    text-transform: uppercase;
		    border-radius: 4px;
		}

        /* APPLY AVATAR (메인 - 사이버 블루) */
		.save-btn {
		    background: transparent;
		    border: 1px solid #00f2ff;
		    color: #00f2ff;
		    box-shadow: 0 0 10px rgba(0, 242, 255, 0.2);
		}
		
		.save-btn:hover {
		    background: #00f2ff;
		    color: #000;
		    box-shadow: 0 0 20px rgba(0, 242, 255, 0.5);
		}
		/* RETURN TO MYPAGE (서브 - 고스트 스타일) */
		.back-btn {
		    background: rgba(255, 255, 255, 0.05);
		    border: 1px solid #333;
		    color: #888;
		}
		
		.back-btn:hover {
		    border-color: #ff0055; /* 호버 시 우리 시그니처 핑크로 포인트 */
		    color: #ff0055;
		    background: rgba(255, 0, 85, 0.05);
		    box-shadow: 0 0 15px rgba(255, 0, 85, 0.3);
		}
        .cancel-link {
            background: transparent;
            border: none;
            color: #555;
            cursor: pointer;
            text-decoration: underline;
            font-size: 12px;
            padding: 10px;
        }
        
        .cancel-link:hover {
            color: #ff0055;
        }

        .hint {
            margin-top: 30px;
            font-size: 11px;
            color: #222;
            letter-spacing: 2px;
            font-family: 'Orbitron', sans-serif;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/Header.jsp" />

    <div class="wrap">
	    <div class="card">
	        <h2>프로필 설정</h2>
	        <p class="sub">새로운 아이덴티티를 선택하세요 <br><small style="font-size: 10px; opacity: 0.6;">SELECT YOUR NEW IDENTITY</small></p>
	
	        <form id="profileForm">
	            <input type="hidden" id="uId" name="uId" value="${sessionScope.loginUser.UId}">
	            <input type="hidden" id="profilePreset" name="profilePreset" value="">
	
	            <div class="image-preview-circle" id="previewWrapper">
	                <img id="previewImg"
	                     src="${not empty sessionScope.loginUser.UProfileImg ? sessionScope.loginUser.UProfileImg : '/img/Profile/profile01.png'}"
	                     onerror="this.src='/img/Profile/profile01.png';"
	                     alt="PROFILE PREVIEW">
	            </div>
	
	            <div class="preset-title">아바타 프리셋 <span style="font-size: 10px; margin-left: 5px; opacity: 0.5;">PRESETS</span></div>
	
	            <div class="preset-grid" id="presetGrid">
	                <div class="preset-item" data-file="profile01.png"><img src="/img/Profile/profile01.png"></div>
	                <div class="preset-item" data-file="profile02.png"><img src="/img/Profile/profile02.png"></div>
	                <div class="preset-item" data-file="profile03.png"><img src="/img/Profile/profile03.png"></div>
	                <div class="preset-item" data-file="profile04.png"><img src="/img/Profile/profile04.png"></div>
	                <div class="preset-item" data-file="profile05.png"><img src="/img/Profile/profile05.png"></div>
	                <div class="preset-item" data-file="profile06.png"><img src="/img/Profile/profile06.png"></div>
	                <div class="preset-item" data-file="profile07.png"><img src="/img/Profile/profile07.png"></div>
	                <div class="preset-item" data-file="profile08.png"><img src="/img/Profile/profile08.png"></div>
	            </div>
	
	            <div class="btn-group">
	                <button type="button" class="save-btn" onclick="saveProfile()">
	                    아바타 적용하기
	                </button>
	                
	                <button type="button" class="back-btn" onclick="goBack()">
	                    마이페이지로 돌아가기
	                </button>
	            </div>
	
	            <div class="hint">시스템 상태: 업로드 준비 완료 // 2026</div>
	        </form>
	    </div>
	</div>

    <jsp:include page="/WEB-INF/views/common/Footer.jsp" />

    <script>
        // 프리셋 선택 → 미리보기 반영
        $("#presetGrid").on("click", ".preset-item", function() {
		    $(".preset-item").removeClass("selected");
		    $(this).addClass("selected");
		    
		    // 미리보기 서클에 글로우 효과 활성화
		    $("#previewWrapper").addClass("active");
		
		    const file = $(this).data("file");
		    $("#profilePreset").val(file);
		    $("#previewImg").attr("src", "/img/Profile/" + file);
		});

        // 페이지 진입 시: 기존 프로필이 프리셋이면 해당 프리셋을 자동 선택
        $(function() {
            const currentPath = "${not empty sessionScope.loginUser.UProfileImg ? sessionScope.loginUser.UProfileImg : ''}";
            let file = "";

            // /img/Profile/profile0X.png 형태면 file 추출
            const match = currentPath.match(/profile0([1-8])\.png$/);
            if (match) {
                file = "profile0" + match[1] + ".png";
            }

            if (file) {
                const target = $("#presetGrid .preset-item[data-file='" + file + "']");
                if (target.length) target.trigger("click");
            } else {
                // 프리셋이 아니면 1번을 기본 선택 (요구사항: 기존 프로필이 기본 선택)
                $("#presetGrid .preset-item").first().trigger("click");
            }
        });

        function saveProfile() {
            const uId = $("#uId").val();
            let preset = $("#profilePreset").val();

            if (!uId) {
                alert("세션이 만료되었습니다. 다시 로그인해주세요.");
                location.href = "/home";
                return;
            }

            if (!preset) {
                $("#presetGrid .preset-item").first().trigger("click");
                preset = $("#profilePreset").val();
            }

            const formData = new FormData();
            formData.append("profilePreset", preset);
            formData.append("uId", uId);

            $.ajax({
                url: "/api/user/guest/signup/step3",
                type: "POST",
                data: formData,
                processData: false,
                contentType: false,
                success: function() {
                alert("아바타가 성공적으로 변경되었습니다.");
                location.href = "/user/mypage";
            },
            error: function(xhr) {
                alert("오류 발생:" + (xhr.responseText || "변경에 실패했습니다."));
            }
            });
        }

        function goBack() {
            history.back();
        }
    </script>
</body>
</html>
