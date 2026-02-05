<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>PROFILE SETTINGS | 404MUSIC</title>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

    <style>
        body {
            background-color: #050505;
            color: #fff;
            font-family: 'Pretendard', sans-serif;
            margin: 0;
        }

        .wrap {
            min-height: auto;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            padding: 40px 16px;
        }

        .card {
            width: 420px;
            padding: 34px;
            background: #0a0a0a;
            border: 1px solid #00f2ff;
            border-radius: 16px;
            box-shadow: 0 0 25px rgba(0, 242, 255, 0.18);
            text-align: center;
        }

        h2 {
            margin: 0 0 18px;
            letter-spacing: 2px;
            text-shadow: 0 0 12px rgba(0, 242, 255, 0.35);
        }

        .sub {
            margin: 0 0 22px;
            color: #888;
            font-size: 12px;
            letter-spacing: 1px;
        }

        .image-preview-circle {
            width: 160px;
            height: 160px;
            border-radius: 50%;
            border: 2px solid #00f2ff;
            box-shadow: 0 0 20px rgba(0, 242, 255, 0.25);
            background-color: #111;
            overflow: hidden;
            margin: 0 auto 14px;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        #previewImg {
            width: 100%;
            height: 100%;
            object-fit: contain;
            transform: scale(1.02);
            display: block;
        }

        .preset-title {
            margin-top: 8px;
            color: #888;
            font-size: 0.85rem;
            letter-spacing: 1px;
        }

        .preset-grid {
            margin-top: 10px;
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            justify-items: center;
        }

        .preset-item {
            width: 56px;
            height: 56px;
            border-radius: 12px;
            overflow: hidden;
            border: 2px solid rgba(255, 255, 255, 0.12);
            background: rgba(255, 255, 255, 0.03);
            cursor: pointer;
            transition: 0.2s;
        }

        .preset-item img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        .preset-item:hover {
            border-color: rgba(0, 242, 255, 0.55);
            box-shadow: 0 0 10px rgba(0, 242, 255, 0.25);
        }

        .preset-item.selected {
            border-color: #00f2ff;
            box-shadow: 0 0 14px rgba(0, 242, 255, 0.35);
        }

        .btn-row {
            margin-top: 22px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }

        /* 버튼(레트로/네온 톤) */
        .retro-btn {
            padding: 14px;
            background-color: transparent;
            border-radius: 12px;
            font-weight: 800;
            letter-spacing: 1px;
            cursor: pointer;
            transition: transform 0.12s ease, box-shadow 0.12s ease, background 0.12s ease, color 0.12s ease;
        }

        /* 프로필 변경(핑크) */
        .retro-btn.primary {
            color: #ff0055;
            border: 1px solid #ff0055;
            box-shadow: 0 0 12px rgba(255, 0, 85, 0.25);
        }
        .retro-btn.primary:hover {
            background: #ff0055;
            color: #fff;
            box-shadow: 0 0 18px rgba(255, 0, 85, 0.45);
            transform: translateY(-1px);
        }

        /* 그대로 두기(시안) */
        .retro-btn.ghost {
            color: #00f2ff;
            border: 1px solid #00f2ff;
            box-shadow: 0 0 12px rgba(0, 242, 255, 0.18);
        }
        .retro-btn.ghost:hover {
            background: #00f2ff;
            color: #000;
            box-shadow: 0 0 18px rgba(0, 242, 255, 0.45);
            transform: translateY(-1px);
        }

        .retro-btn:active {
            transform: translateY(0) scale(0.99);
        }

        .hint {
            margin-top: 14px;
            font-size: 11px;
            color: #444;
            letter-spacing: 1px;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/Header.jsp" />

    <div class="wrap">
        <div class="card">
            <h2>PROFILE SETTINGS</h2>
            <p class="sub">기존 프로필이 있으면 자동으로 선택됩니다.</p>

            <form id="profileForm">
                <input type="hidden" id="uId" name="uId" value="${sessionScope.loginUser.UId}">
                <input type="hidden" id="profilePreset" name="profilePreset" value="">

                <div class="image-preview-circle">
                    <img id="previewImg"
                         src="${not empty sessionScope.loginUser.UProfileImg ? sessionScope.loginUser.UProfileImg : '/img/Profile/profile01.png'}"
                         onerror="this.onerror=null; this.src='/img/Profile/profile01.png';"
                         alt="PROFILE PREVIEW">
                </div>

                <div class="preset-title">SELECT ONE PROFILE IMAGE</div>

                <div class="preset-grid" id="presetGrid">
                    <div class="preset-item" data-file="profile01.png"><img src="/img/Profile/profile01.png" alt="preset 1"></div>
                    <div class="preset-item" data-file="profile02.png"><img src="/img/Profile/profile02.png" alt="preset 2"></div>
                    <div class="preset-item" data-file="profile03.png"><img src="/img/Profile/profile03.png" alt="preset 3"></div>
                    <div class="preset-item" data-file="profile04.png"><img src="/img/Profile/profile04.png" alt="preset 4"></div>
                    <div class="preset-item" data-file="profile05.png"><img src="/img/Profile/profile05.png" alt="preset 5"></div>
                    <div class="preset-item" data-file="profile06.png"><img src="/img/Profile/profile06.png" alt="preset 6"></div>
                    <div class="preset-item" data-file="profile07.png"><img src="/img/Profile/profile07.png" alt="preset 7"></div>
                    <div class="preset-item" data-file="profile08.png"><img src="/img/Profile/profile08.png" alt="preset 8"></div>
                </div>

                <div class="btn-row">
                    <button type="button" class="retro-btn primary" onclick="saveProfile()">APPLY AVATAR</button>
                    <button type="button" class="retro-btn ghost" onclick="goBack()">KEEP CURRENT</button>
                </div>


                <div class="hint">SYSTEM STATUS: PROFILE UPDATED INSTANTLY // 2026</div>
            </form>
        </div>
    </div>

    <jsp:include page="/WEB-INF/views/common/Footer.jsp" />

    <script>
        // 프리셋 선택 → 미리보기 반영
        $("#presetGrid").on("click", ".preset-item", function() {
            $(".preset-item").removeClass("selected");
            $(this).addClass("selected");

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
                alert("Avatar updated successfully.");
                location.href = "/user/mypage";
            },
            error: function(xhr) {
                alert("ERROR: " + (xhr.responseText || "Avatar update failed."));
            }
            });
        }

        function goBack() {
            history.back();
        }
    </script>
</body>
</html>
