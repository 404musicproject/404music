<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<title>회원가입 3단계</title>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<link rel="stylesheet" href="/css/SignupFormStep3.css">
</head>
<body>
    <jsp:include page="../common/Header.jsp" />
    <main class="signup-main">
      <div class="signup-wrap">

        <div class="progress-container">
            <div class="progress-step active">
                <span class="step-num">01</span>
                <span class="step-text">인증</span>
            </div>
            <div class="progress-line active-line"></div>
            <div class="progress-step active">
                <span class="step-num">02</span>
                <span class="step-text">정보</span>
            </div>
            <div class="progress-line active-line"></div>
            <div class="progress-step active">
                <span class="step-num">03</span>
                <span class="step-text">프로필</span>
            </div>
        </div>

        <h2>프로필 사진 설정</h2>

        <div class="signup-box">
            <form id="signupFormStep3">
                <input type="hidden" id="uId" name="uId" value="${uId}">

                <div class="profile-area">
                    <div class="image-preview-circle">
                        <img id="previewImg"
                             src="/img/Profile/profile01.png"
                             onerror="this.onerror=null; this.src='/images/no-image-found.png';"
                             alt="프로필 미리보기">
                    </div>

                    <div class="preset-title">프로필 이미지를 선택해 주세요</div>

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

                    <input type="hidden" id="profilePreset" name="profilePreset" value="">
                </div>

                <div class="btn-group">
                    <button type="button" onclick="submitStep3()">가입 완료</button>
                    <button type="button" class="skip" onclick="skipStep()">건너뛰기</button>
                </div>
            </form>
        </div>

        <script>
            $("#presetGrid").on("click", ".preset-item", function() {
                $(".preset-item").removeClass("selected");
                $(this).addClass("selected");
                const file = $(this).data("file");
                $("#profilePreset").val(file);
                $("#previewImg").attr("src", "/img/Profile/" + file);
            });

            $(function(){
                const current = ($("#profilePreset").val() || "").trim();
                if (!current) {
                    $("#presetGrid .preset-item").first().trigger("click");
                }
            });

            function submitStep3() {
                const preset = $("#profilePreset").val();
                if (!preset) $("#presetGrid .preset-item").first().trigger("click");

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
                        alert("시스템: 회원가입이 정상적으로 완료되었습니다.");
                        location.href = "/";
                    },
                    error: function(xhr) {
                        alert("오류가 발생했습니다: " + xhr.responseText);
                    }
                });
            }

            function skipStep() {
                if(confirm("프로필 사진을 나중에 설정하고 가입을 완료할까요?")) {
                    alert("회원가입이 완료되었습니다.");
                    location.href = "/";
                }
            }
        </script>
      </div>
    </main>
    <jsp:include page="../common/Footer.jsp" />
</body>
</html>