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

    /* 메인 타이틀: 홈의 No.1 텍스트 스타일 계승 */
    h2 {
        color: #fff;
        text-shadow: 0 0 15px #ff0055;
        margin-bottom: 30px;
        text-align: center;
        letter-spacing: 3px;
        font-weight: 800;
    }

    /* 컨테이너: 홈의 카드 스타일 계승 */
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
        border: 2px solid #ff0055; /* 핑크 포인트 */
        box-shadow: 0 0 20px rgba(255, 0, 85, 0.4);
        background-color: #111;
        overflow: hidden;
        margin: 0 auto 25px;
        display: flex;
        justify-content: center;
        align-items: center;
        transition: 0.3s;
    }

    /* 버튼 스타일: 홈의 menu-card 스타일 계승 */
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

    /* 스킵 버튼: 홈의 보조 컬러(Cyan) 활용 */
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

    .system-footer {
        margin-top: 30px;
        color: #444;
        font-size: 11px;
        letter-spacing: 1px;
    }
    
    /* 진행 바 컨테이너 */
.progress-container {
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 40px;
    gap: 10px;
}

/* 단계 아이템 (01, 02, 03) */
.progress-step {
    display: flex;
    flex-direction: column;
    align-items: center;
    opacity: 0.3; /* 평소에는 흐리게 */
    transition: 0.5s;
}

/* 현재 활성화된 단계 */
.progress-step.active {
    opacity: 1;
}

.step-num {
    font-family: 'Courier Prime', monospace;
    font-size: 18px;
    font-weight: bold;
    color: #00f2ff; /* 시안 색상 */
    text-shadow: 0 0 10px #00f2ff;
}

.progress-step.active .step-num {
    color: #ff0055; /* 현재 단계는 핑크로 강조 */
    text-shadow: 0 0 15px #ff0055;
}

.step-text {
    font-size: 10px;
    letter-spacing: 2px;
    margin-top: 5px;
    color: #fff;
}

/* 연결 라인 */
.progress-line {
    width: 50px;
    height: 1px;
    background: rgba(255, 255, 255, 0.1);
    margin-bottom: 15px; /* 텍스트 높이 고려 */
}
/* 활성화된 연결선 스타일 */
.progress-line.active-line {
    background: #00f2ff; /* 시안 색상 */
    box-shadow: 0 0 10px #00f2ff;
    opacity: 1;
}

/* 03번 숫자는 최종 단계이므로 핑크로 강조하고 싶다면 */
.progress-step.active:last-child .step-num {
    color: #ff0055;
    text-shadow: 0 0 15px #ff0055;
}
</style>
</head>
<body>

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
				    <img id="previewImg" 
				         src="/images/default_profile.png" 
				         onerror="this.onerror=null; this.src='/images/no-image-found.png';"
				         alt="PROFILE PREVIEW">
				</div>
				                
                <label for="profileFile" class="file-select-btn">
                    SELECT IMAGE
                </label>
                <input type="file" id="profileFile" name="profileFile" accept="image/*">
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
        // 1. 이미지 미리보기 로직
        $("#profileFile").on("change", function(e) {
            const file = e.target.files[0];
            if (!file) return;

            if (!file.type.match('image.*')) {
                alert("SYSTEM ERROR: INVALID FILE TYPE");
                $(this).val('');
                return;
            }

            const reader = new FileReader();
            reader.onload = function(e) {
                $("#previewImg").attr("src", e.target.result);
            }
            reader.readAsDataURL(file);
        });

        // 2. 전송 로직
        function submitStep3() {
            const fileInput = $("#profileFile")[0];
            
            if (fileInput.files.length === 0) {
                skipStep();
                return;
            }

            const formData = new FormData();
            formData.append("profileFile", fileInput.files[0]);
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
            // 영어 confirm 메시지
            if(confirm("COMPLETE REGISTRATION WITHOUT PROFILE IMAGE?")) {
                alert("REGISTRATION COMPLETE.");
                location.href = "/";
            }
        }
    </script>
</body>
</html>