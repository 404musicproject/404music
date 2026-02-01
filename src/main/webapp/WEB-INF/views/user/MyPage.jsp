<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>SETTINGS | SYSTEM</title>
    <style>
        /* 기본 네온 테마 스타일 */
        html, body { margin: 0; padding: 0; background-color: #000; color: #fff;  }
        .mypage-container { display: flex; justify-content: center; align-items: center; min-height: 100vh; padding-top: 50px; padding-bottom: 50px; font-family: 'Courier New', monospace;}
        
        .neon-card { width: 550px; padding: 40px; border: 2px solid #ff0055; box-shadow: 0 0 15px #ff0055; background: #050505; position: relative; }
        
        /* 탭 버튼 스타일 */
        .tab-menu { display: flex; gap: 10px; margin-bottom: 30px; border-bottom: 1px solid #333; }
        .tab-btn { 
            padding: 10px 20px; background: transparent; border: none; color: #888; 
            cursor: pointer; font-weight: bold; transition: 0.3s; font-family: inherit;
        }
        .tab-btn:hover { color: #fff; }
        .tab-btn.active { color: #00f2ff; border-bottom: 2px solid #00f2ff; text-shadow: 0 0 5px #00f2ff; }

        /* 섹션 제어 */
        .tab-content { display: none; animation: fadeIn 0.3s ease-in-out; }
        .tab-content.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

        /* 프로필 이미지 영역 (신규 추가) */
        .profile-section { text-align: center; margin-bottom: 30px; }
        .profile-wrapper {
            width: 120px; height: 120px;
            margin: 0 auto;
            border-radius: 50%;
            border: 3px solid #00f2ff; /* 사이언 테두리 */
            box-shadow: 0 0 10px #00f2ff;
            overflow: hidden;
            position: relative;
            cursor: pointer;
            background: #000;
        }
        .profile-wrapper img { width: 100%; height: 100%; object-fit: cover; }
        
        /* 프로필 호버 시 'CHANGE' 글자 표시 */
        .profile-wrapper:hover::after {
            content: 'CHANGE';
            position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.7);
            color: #00f2ff;
            display: flex; align-items: center; justify-content: center;
            font-weight: bold; font-size: 14px;
        }

        .info-row { margin-bottom: 20px; }
        .label { color: #ff0055; font-size: 12px; display: block; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 1px; }
        .value { font-size: 15px; color: #ddd; }
        
        .neon-input { width: 100%; background: #111; border: 1px solid #444; color: #fff; padding: 12px; box-sizing: border-box; font-family: inherit; }
        .neon-input:focus { border-color: #00f2ff; outline: none; box-shadow: 0 0 5px #00f2ff; }
        
        /* 알림/안내 문구 */
        .social-notice { background: #111; padding: 15px; border-left: 4px solid #00f2ff; color: #00f2ff; font-size: 13px; margin-bottom: 20px; line-height: 1.5; }
        .danger-zone { border: 1px solid #ff0055; padding: 20px; margin-top: 30px; background: rgba(255, 0, 85, 0.05); }
        .withdraw-btn { background: transparent; border: none; color: #ff0055; cursor: pointer; text-decoration: underline; font-size: 12px; font-family: inherit; }

        .save-btn { width: 100%; padding: 15px; background: transparent; border: 1px solid #00f2ff; color: #00f2ff; font-weight: bold; cursor: pointer; margin-top: 20px; font-family: inherit; transition: 0.2s; }
        .save-btn:hover { background: #00f2ff; color: #000; box-shadow: 0 0 15px #00f2ff; }
        
        /* 버튼 비활성화 스타일 */
        button:disabled { border-color: #555; color: #555; cursor: not-allowed; box-shadow: none; }
        button:disabled:hover { background: transparent; color: #555; }

        /* 파일 인풋 숨김 */
        #profileUpdateInput { display: none; }
    </style>
    
    <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
    <script>
        // 탭 전환 함수
        function openTab(evt, tabName) {
            $('.tab-content').removeClass('active');
            $('.tab-btn').removeClass('active');
            
            $('#' + tabName).addClass('active');
            
            if (evt && evt.currentTarget) {
                $(evt.currentTarget).addClass('active');
            } else {
                $(`.tab-btn[onclick*='${tabName}']`).addClass('active');
            }
        }

        $(document).ready(function() {
            // URL 파라미터로 탭 이동 (?tab=sub)
            const urlParams = new URLSearchParams(window.location.search);
            const tabParam = urlParams.get('tab');

            if (tabParam === 'sub') {
                openTab(null, 'sub-container');
            } else {
                openTab(null, 'general');
            }
            
            // --- [신규] 프로필 이미지 즉시 변경 로직 ---
            $("#profileUpdateInput").on("change", function(e) {
                const file = e.target.files[0];
                if (!file) return;

                // 1. 파일 형식 검사
                if (!file.type.match('image.*')) {
                    alert("이미지 파일만 업로드 가능합니다.");
                    return;
                }

                // 2. 서버 전송
                const formData = new FormData();
                formData.append("profileFile", file);

                $.ajax({
                    url: '/api/user/update/profile', // UserRestController에 추가한 주소
                    type: 'POST',
                    data: formData,
                    processData: false,
                    contentType: false,
                    success: function(newPath) {
                        // 3. 성공 시 이미지 즉시 교체 (캐시 방지용 시간 추가)
                        const timestamp = new Date().getTime();
                        $("#currentProfileImg").attr("src", newPath + "?t=" + timestamp);
                        alert("프로필 사진이 변경되었습니다.");
                    },
                    error: function(xhr) {
                        alert("사진 변경 실패: " + xhr.responseText);
                    }
                });
            });
            // ------------------------------------------
        });
        
        // 닉네임 중복 체크 로직
        let nickChecked = true;
        const originalNick = "${sessionScope.loginUser.UNick}";
        let timer; 

        $('#uNick').on('input', function() {
            const nick = $(this).val();
            
            if (nick === originalNick) {
                $('#nickMsg').text("현재 사용 중인 닉네임입니다.").css("color", "gray");
                nickChecked = true;
                $('#save-btn').prop('disabled', false);
                return;
            }

            nickChecked = false;
            $('#save-btn').prop('disabled', true);
            
            clearTimeout(timer);
            
            if (nick.length < 2) {
                $('#nickMsg').text("닉네임은 2자 이상 입력해주세요.").css("color", "#ff0055");
                return;
            }

            timer = setTimeout(function() {
                $.get("/api/user/guest/check-nick", { uNick: nick }, function(isAvailable) {
                    if (isAvailable) {
                        $('#nickMsg').text("✅ 사용 가능한 닉네임입니다.").css("color", "#00f2ff");
                        nickChecked = true;
                        $('#save-btn').prop('disabled', false);
                    } else {
                        $('#nickMsg').text("❌ 이미 사용 중인 닉네임입니다.").css("color", "#ff0055");
                        nickChecked = false;
                        $('#save-btn').prop('disabled', true);
                    }
                });
            }, 300);
        });
    </script>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/Header.jsp" />

    <div class="mypage-container">
        <div class="neon-card">
            <h2 style="text-align:center; color:#ff0055; text-shadow: 0 0 10px #ff0055; letter-spacing: 2px;">SYSTEM SETTINGS</h2>

            <div class="tab-menu">
                <button class="tab-btn active" onclick="openTab(event, 'general')">GENERAL</button>
                <button class="tab-btn" onclick="openTab(event, 'security')">SECURITY</button>
                <button class="tab-btn" onclick="openTab(event, 'notification')">NOTI</button>
                <button class="tab-btn" onclick="openTab(event, 'sub-container')">SUBSCRIPTION</button>
            </div>

            <form action="/api/user/update" method="POST">
                <div id="general" class="tab-content active">
                    
                    <div class="profile-section">
						<div class="profile-wrapper" onclick="goToUpdateProfile()">
    <img id="currentProfileImg" 
         src="${not empty sessionScope.loginUser.UProfileImg ? sessionScope.loginUser.UProfileImg : '/images/default_profile.png'}" 
         onerror="this.src='https://via.placeholder.com/150/000000/00f2ff?text=NO+IMG'">
</div>
                        <input type="file" id="profileUpdateInput" accept="image/*">
                        <p style="font-size: 11px; color: #666; margin-top: 5px;">CLICK IMAGE TO CHANGE</p>
                    </div>

                    <div class="info-row">
                        <span class="label">ID / EMAIL</span>
                        <span class="value">${sessionScope.loginUser.UId}</span>
                        <input type="hidden" name="uId" value="${sessionScope.loginUser.UId}">
                    </div>
            
                    <div class="info-row">
                        <span class="label">NICKNAME</span>
                        <span class="view-mode value">${sessionScope.loginUser.UNick}</span>
                        <div class="edit-mode" style="display:none;">
                            <input type="text" name="uNick" id="uNick" class="neon-input" value="${sessionScope.loginUser.UNick}">
                            <div id="nickMsg" style="font-size: 12px; margin-top: 5px;"></div>
                        </div>
                    </div>
            
                    <div class="info-row">
                        <span class="label">REGION</span>
                        <span class="view-mode value">${not empty sessionScope.loginUser.URegion ? sessionScope.loginUser.URegion : '미설정'}</span>
                        <input type="text" name="uRegion" class="neon-input edit-mode" value="${sessionScope.loginUser.URegion}" style="display:none;">
                    </div>
            
                    <div class="info-row">
                        <span class="label">GENDER</span>
                        <span class="view-mode value">
                            <c:choose>
                                <c:when test="${sessionScope.loginUser.UGender == 'M'}">MALE</c:when>
                                <c:when test="${sessionScope.loginUser.UGender == 'F'}">FEMALE</c:when>
                                <c:otherwise>OTHER</c:otherwise>
                            </c:choose>
                        </span>
                        <select name="uGender" class="neon-input edit-mode" style="display:none;">
                            <option value="M" ${sessionScope.loginUser.UGender == 'M' ? 'selected' : ''}>MALE</option>
                            <option value="F" ${sessionScope.loginUser.UGender == 'F' ? 'selected' : ''}>FEMALE</option>
                            <option value="O" ${sessionScope.loginUser.UGender == 'O' ? 'selected' : ''}>OTHER</option>
                        </select>
                    </div>
            
                    <div class="info-row">
                        <span class="label">PREFERRED GENRE</span>
                        <span class="view-mode value">${not empty sessionScope.loginUser.UPreferredGenre ? sessionScope.loginUser.UPreferredGenre : 'NONE'}</span>
                        <input type="text" name="uPreferredGenre" class="neon-input edit-mode" value="${sessionScope.loginUser.UPreferredGenre}" style="display:none;">
                    </div>
            
                    <div class="btn-group">
                        <button type="button" id="edit-start-btn" class="save-btn" onclick="toggleEditMode(true)">EDIT PROFILE INFO</button>
                        <button type="submit" id="save-btn" class="save-btn edit-mode" style="display:none;">SAVE CHANGES</button>
                        <button type="button" id="cancel-btn" class="withdraw-btn edit-mode" style="display:none; margin-top:10px; width:100%; text-align:center;" onclick="toggleEditMode(false)">CANCEL</button>
                    </div>
                </div>
            </form>

            <div id="security" class="tab-content">
                <c:choose>
                    <c:when test="${sessionScope.loginUser.USocialType == 'LOCAL'}">
                        <div id="pw-change-group">
                            <div class="info-row">
                                <span class="label">CURRENT PASSWORD</span>
                                <input type="password" id="currentPw" class="neon-input" placeholder="********">
                            </div>
                            <div class="info-row">
                                <span class="label">NEW PASSWORD</span>
                                <input type="password" id="newPw" class="neon-input" placeholder="********">
                            </div>
                            <div class="info-row">
                                <span class="label">CONFIRM NEW PASSWORD</span>
                                <input type="password" id="confirmPw" class="neon-input" placeholder="********">
                            </div>
                            <button type="button" class="save-btn" onclick="changePassword()">CHANGE PASSWORD</button>
                            <div id="pwMsg" style="font-size: 12px; margin-top: 10px; text-align: center;"></div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="social-notice">
                            [SYSTEM NOTICE]<br>
                            This account is linked via <strong>${sessionScope.loginUser.USocialType}</strong>.<br>
                            Password management is handled by the provider.
                        </div>
                    </c:otherwise>
                </c:choose>
            
                <div class="danger-zone">
                    <span class="label">DANGER ZONE</span>
                    <p style="font-size:11px; color:#aaa; margin-bottom: 10px;">
                        WARNING: Account deletion is permanent. All data will be lost.
                    </p>
                    <button type="button" class="withdraw-btn" onclick="confirmWithdraw()">DELETE ACCOUNT</button>
                </div>
            </div>

            <div id="notification" class="tab-content">
                <div class="info-row">
                    <span class="label">EMAIL NOTIFICATION</span>
                    <label style="color:#ddd; display:flex; align-items:center; gap:10px;">
                        <input type="checkbox" name="emailNoti" checked style="accent-color: #00f2ff;"> 
                        Receive system updates via email
                    </label>
                </div>
                <div class="info-row">
                    <span class="label">MARKETING PUSH</span>
                    <label style="color:#ddd; display:flex; align-items:center; gap:10px;">
                        <input type="checkbox" name="pushNoti" style="accent-color: #00f2ff;"> 
                        Receive marketing & event news
                    </label>
                </div>
                <button type="button" class="save-btn" onclick="alert('Preferences Saved.')">SAVE PREFERENCES</button>
            </div>

            <div id="sub-container" class="tab-content">
                <c:choose>
                    <c:when test="${not empty subscription}">
                        <div style="border: 1px solid #333; padding: 20px; border-radius: 4px;">
                            <h3 style="color:#00f2ff; margin-top:0;">PLAN: ${subscription.SSub}</h3>
                            
                            <p class="value">STATUS: 
                                <c:choose>
                                    <c:when test="${subscription.SStatus eq 'PENDING_CANCEL'}">
                                        <strong style="color:#ff0055;">CANCELLATION SCHEDULED</strong>
                                    </c:when>
                                    <c:otherwise>
                                        <strong style="color:#00f2ff;">ACTIVE</strong>
                                    </c:otherwise>
                                </c:choose>
                            </p>
                        
                            <p class="value">PERIOD: <br><span style="font-size:13px; color:#888;">${subscription.SStartDate} ~ ${subscription.SEndDate}</span></p>
                        
                            <c:if test="${subscription.SStatus ne 'PENDING_CANCEL'}">
                                <p class="value">NEXT BILLING: <br><span style="font-size:13px; color:#888;">${subscription.SNextSub}</span></p>
                            </c:if>
                            
                            <c:choose>
                                <c:when test="${subscription.SCancelReserved == 'F'}">
                                     <button class="save-btn" onclick="cancelSubscription()" style="border-color:#ff0055; color:#ff0055;">CANCEL SUBSCRIPTION</button>
                                </c:when>
                                <c:otherwise>
                                    <p style="color:#ff0055; font-size:12px; margin-top:15px;">
                                        * Access remains until ${subscription.SEndDate}.
                                    </p>
                                    <button class="save-btn" onclick="reverseCancelSubscription()">
                                        REACTIVATE SUBSCRIPTION
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="text-align:center; padding: 30px; border: 1px dashed #444;">
                            <p style="color:#888;">No active subscription found.</p>
                            <button class="save-btn" onclick="location.href='/user/subscription'">UPGRADE PLAN</button>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

        </div>
    </div>

    <script>
        // 수정 모드 토글
        function toggleEditMode(isEdit) {
            if (isEdit) {
                $('.view-mode').hide();
                $('.edit-mode').show();
                $('#edit-start-btn').hide();
            } else {
                $('.view-mode').show();
                $('.edit-mode').hide();
                $('#edit-start-btn').show();
            }
        }

        // 구독 해지 로직
        function cancelSubscription() {
            if (confirm("Are you sure you want to cancel your subscription?")) {
                $.ajax({
                    url: '/api/subscription/cancel',
                    type: 'POST',
                    success: function() { alert("Cancellation scheduled."); location.reload(); },
                    error: function(xhr) { alert("Error: " + xhr.responseText); }
                });
            }
        }
        
        // 구독 해지 철회 로직
        function reverseCancelSubscription() {
            if (confirm("Reactivate your subscription?")) {
                $.ajax({
                    url: '/api/subscription/reverseCancel',
                    type: 'POST',
                    success: function() { alert("Subscription reactivated."); location.reload(); },
                    error: function(xhr) { alert("Error: " + xhr.responseText); }
                });
            }
        }

        // 탈퇴 로직
        function confirmWithdraw() {
            if(confirm("FINAL WARNING: This action cannot be undone.")) {
                $.ajax({
                    url: '/api/user/withdraw',
                    type: 'GET',
                    success: function(res) { alert(res); location.href = "/"; },
                    error: function(xhr) { alert("Error: " + xhr.responseText); }
                });
            }
        }
        
        // 비밀번호 변경 로직
        function changePassword() {
            const currentPw = $('#currentPw').val();
            const newPw = $('#newPw').val();
            const confirmPw = $('#confirmPw').val();

            if (!currentPw || !newPw || !confirmPw) { alert("Please fill in all fields."); return; }
            if (newPw !== confirmPw) { $('#pwMsg').text("❌ Passwords do not match.").css("color", "#ff0055"); return; }

            $.ajax({
                url: '/api/user/update-pw',
                type: 'POST',
                data: { currentPw: currentPw, newPw: newPw },
                success: function() { alert("Password changed successfully."); location.reload(); },
                error: function(xhr) { $('#pwMsg').text("❌ " + xhr.responseText).css("color", "#ff0055"); }
            });
        }
        
        function goToUpdateProfile() {
            // 세션에 있는 ID를 자바스크립트 변수로 안전하게 가져옵니다.
            const userId = "${sessionScope.loginUser.UId}"; 
            
            if(!userId) {
                alert("세션이 만료되었습니다. 다시 로그인해주세요.");
                return;
            }

            // 경로를 직접 생성해서 이동합니다.
            location.href = "/signup/step3?uId=" + encodeURIComponent(userId) + "&mode=edit";
        }
    </script>
</body>
</html>