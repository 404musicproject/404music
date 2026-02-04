<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<title>SIGN UP STEP 3</title>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<style>
    @import url('https://fonts.googleapis.com/css2?family=Pretendard:wght@400;700&family=Courier+Prime:wght@400;700&display=swap');

    body {
        background-color: #050505;
        color: #fff;
        font-family: 'Pretendard', sans-serif;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        height: 100vh;
        margin: 0;
    }

    h2 {
        color: #fff;
        text-shadow: 0 0 15px #ff0055;
        margin-bottom: 30px;
        text-align: center;
        letter-spacing: 3px;
        font-weight: 800;
    }

    .signup-box {
        width: 380px;
        padding: 40px;
        background: #0a0a0a;
        border: 1px solid #ff0055;
        border-radius: 16px;
        box-shadow: 0 0 25px rgba(255, 0, 85, 0.2);
        text-align: center;
        position: relative;
    }

    /* 프로필 이미지 영역 */
    .image-preview-circle {
        width: 160px;
        height: 160px;
        border-radius: 50%;
        border: 2px solid #ff0055;
        box-shadow: 0 0 20px rgba(255, 0, 85, 0.4);
        background-color: #111;
        overflow: hidden;
        margin: 0 auto 18px;   /* ✅ 아래 간격 살짝 줄임 */
        display: flex;
        justify-content: center;
        align-items: center;
        transition: 0.3s;
    }

    /* ✅ 미리보기 확대 방지 */
	#previewImg{
	    width: 100%;
	    height: 100%;
	    object-fit: contain;     /* 과확대 방지 */
	    transform: scale(1.02);  /* ✅ 검은 여백 안 보이게 살짝 키움 */
	    display: block;
	}

    .retro-btn {
        width: 100%;
        padding: 15px;
        background-color: transparent;
        color: #ff0055;
        border: 1px solid #ff0055;
        border-radius: 8px;
        font-weight: bold;
        letter-spacing: 1px;
        cursor: pointer;
        transition: all 0.3s;
        margin-bottom: 10px;
    }

    .retro-btn:hover {
        background: #ff0055;
        color: #fff;
        box-shadow: 0 0 15px rgba(255, 0, 85, 0.5);
    }

    .retro-btn.skip {
        color: #00f2ff;
        border-color: #00f2ff;
        margin-top: 5px;
    }

    .retro-btn.skip:hover {
        background: #00f2ff;
        color: #000;
        box-shadow: 0 0 15px rgba(0, 242, 255, 0.5);
    }

    .file-select-btn {
        color: #888;
        font-size: 0.9rem;
        cursor: pointer;
        text-decoration: underline;
        transition: 0.3s;
    }
    .file-select-btn:hover { color: #fff; }

    /* ✅ 프리셋(8개) 선택 UI */
    .preset-title{
        margin-top: 10px;        /* ✅ 살짝 줄임 */
        color: #888;
        font-size: 0.85rem;
        letter-spacing: 1px;
    }
    .preset-grid{
        margin-top: 6px;         /* ✅ 위로 올리기 */
        transform: translateY(-8px);
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 10px;
        justify-items: center;
    }
    .preset-item{
        width: 56px;
        height: 56px;
        border-radius: 12px;
        overflow: hidden;
        border: 2px solid rgba(255,255,255,0.12);
        background: rgba(255,255,255,0.03);
        cursor: pointer;
        transition: 0.2s;
    }
    .preset-item img{
        width: 100%;
        height: 100%;
        object-fit: cover;
        display: block;
    }
    .preset-item:hover{
        border-color: rgba(255,0,85,0.5);
        box-shadow: 0 0 10px rgba(255,0,85,0.25);
    }
    .preset-item.selected{
        border-color: #ff0055;
        box-shadow: 0 0 14px rgba(255,0,85,0.35);
    }

    .system-footer {
        margin-top: 30px;
        color: #444;
        font-size: 11px;
        letter-spacing: 1px;
    }

    /* 진행 바 */
    .progress-container {
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 40px;
        gap: 10px;
    }

    .progress-step {
        display: flex;
        flex-direction: column;
        align-items: center;
        opacity: 0.3;
        transition: 0.5s;
    }

    .progress-step.active { opacity: 1; }

    .step-num {
        font-family: 'Courier Prime', monospace;
        font-size: 18px;
        font-weight: bold;
        color: #00f2ff;
        text-shadow: 0 0 10px #00f2ff;
    }

    .progress-step.active .step-num {
        color: #ff0055;
        text-shadow: 0 0 15px #ff0055;
    }

    .step-text {
        font-size: 10px;
        letter-spacing: 2px;
        margin-top: 5px;
        color: #fff;
    }

    .progress-line {
        width: 50px;
        height: 1px;
        background: rgba(255, 255, 255, 0.1);
        margin-bottom: 15px;
    }

    .progress-line.active-line {
        background: #00f2ff;
        box-shadow: 0 0 10px #00f2ff;
        opacity: 1;
    }

    .progress-step.active:last-child .step-num {
        color: #ff0055;
        text-shadow: 0 0 15px #ff0055;
    }
</style>
</head>
<body>
    <jsp:include page="../common/Header.jsp" />
    <main class="signup-main">
      <div class="signup-wrap">

    <h2>SIGN UP STEP 3</h2>

    <div class="progress-container">
        <div class="progress-step active">
            <span class="step-num">01</span>
            <span class="step-text">AUTH</span>
        </div>
        <div class="progress-line active-line"></div>

        <div class="progress-step active">
            <span class="step-num">02</span>
            <span class="step-text">INFO</span>
        </div>
        <div class="progress-line active-line"></div>

        <div class="progress-step active">
            <span class="step-num">03</span>
            <span class="step-text">PHOTO</span>
        </div>
    </div>

    <div class="signup-box">
        <div class="close-btn">×</div>
        <form id="signupFormStep3">
            <input type="hidden" id="uId" name="uId" value="${uId}">

            <div class="profile-area">
                <div class="image-preview-circle">
                    <!-- ✅ 기본값: 첫번째 프리셋으로 시작 -->
                    <img id="previewImg"
                         src="/img/Profile/profile01.png"
                         onerror="this.onerror=null; this.src='/images/no-image-found.png';"
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

                <input type="hidden" id="profilePreset" name="profilePreset" value="">
            </div>

            <div class="btn-group">
                <button type="button" class="retro-btn" onclick="submitStep3()">
                    COMPLETE REGISTRATION
                </button>

                <button type="button" class="retro-btn skip" onclick="skipStep()">
                    SKIP SETUP
                </button>
            </div>
        </form>
    </div>

    <div class="system-footer">
        SYSTEM STATUS: PROFILE IMAGE REQUIRED // 2026
    </div>

    <script>
        // 1. 프리셋 선택 → 미리보기 반영
        $("#presetGrid").on("click", ".preset-item", function() {
            $(".preset-item").removeClass("selected");
            $(this).addClass("selected");

            const file = $(this).data("file");
            $("#profilePreset").val(file);

            // 미리보기 원형에 반영
            $("#previewImg").attr("src", "/img/Profile/" + file);
        });

        // ✅ 1-1. 아무것도 선택 안 했으면 첫번째 이미지로 기본 선택
        $(function(){
            const current = ($("#profilePreset").val() || "").trim();
            if (!current) {
                $("#presetGrid .preset-item").first().trigger("click");
            }
        });

        // 2. 전송 로직
        function submitStep3() {
            const preset = $("#profilePreset").val();

            // ✅ 이제 기본이 1번으로 자동 선택되니까, 여기로 들어오면 preset은 보통 항상 있음
            if (!preset) {
                // 혹시라도 비어있으면 안전하게 1번 지정
                $("#presetGrid .preset-item").first().trigger("click");
            }

            const finalPreset = $("#profilePreset").val();

            const formData = new FormData();
            formData.append("profilePreset", finalPreset);
            formData.append("uId", $("#uId").val());

            $.ajax({
                url: '/api/user/guest/signup/step3',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(res) {
                    alert("SYSTEM: REGISTRATION COMPLETE.");
                    location.href = "/";
                },
                error: function(xhr) {
                    alert("ERROR: " + xhr.responseText);
                }
            });
        }

        // 3. 건너뛰기
        function skipStep() {
            if(confirm("COMPLETE REGISTRATION WITHOUT PROFILE IMAGE?")) {
                alert("REGISTRATION COMPLETE.");
                location.href = "/";
            }
        }
    </script>
      </div>
    </main>
    <jsp:include page="../common/Footer.jsp" />
</body>
</html>
