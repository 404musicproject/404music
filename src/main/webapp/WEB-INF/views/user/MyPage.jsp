<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>SETTINGS | SYSTEM</title>
    <style>
        /* 기본 네온 테마 스타일 */
        html, body { margin: 0; padding: 0; background-color: #000; color: #fff; font-family: 'Courier New', monospace; }
        .mypage-container { display: flex; justify-content: center; align-items: center; min-height: 100vh; padding-top: 50px; }
        
        .neon-card { width: 550px; padding: 40px; border: 2px solid #ff0055; box-shadow: 0 0 15px #ff0055; background: #000; }
        
        /* 탭 버튼 스타일 */
        .tab-menu { display: flex; gap: 10px; margin-bottom: 30px; border-bottom: 1px solid #333; }
        .tab-btn { 
            padding: 10px 20px; background: transparent; border: none; color: #888; 
            cursor: pointer; font-weight: bold; transition: 0.3s;
        }
        .tab-btn.active { color: #00f2ff; border-bottom: 2px solid #00f2ff; text-shadow: 0 0 5px #00f2ff; }

        /* 섹션 제어 */
        .tab-content { display: none; }
        .tab-content.active { display: block; }

        .info-row { margin-bottom: 20px; }
        .label { color: #ff0055; font-size: 12px; display: block; margin-bottom: 8px; text-transform: uppercase; }
        .neon-input { width: 100%; background: transparent; border: 1px solid #444; color: #fff; padding: 10px; box-sizing: border-box; }
        .neon-input:focus { border-color: #00f2ff; outline: none; box-shadow: 0 0 5px #00f2ff; }
        
        /* 알림/안내 문구 */
        .social-notice { background: #111; padding: 15px; border-left: 4px solid #00f2ff; color: #00f2ff; font-size: 13px; margin-bottom: 20px; }
        .danger-zone { border: 1px solid #ff0055; padding: 15px; margin-top: 30px; }
        .withdraw-btn { background: transparent; border: none; color: #ff0055; cursor: pointer; text-decoration: underline; font-size: 12px; }

        .save-btn { width: 100%; padding: 15px; background: transparent; border: 1px solid #00f2ff; color: #00f2ff; font-weight: bold; cursor: pointer; margin-top: 20px; }
        .save-btn:hover { background: #00f2ff; color: #000; box-shadow: 0 0 15px #00f2ff; }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/Header.jsp" />

    <div class="mypage-container">
        <div class="neon-card">
            <h2 style="text-align:center; color:#ff0055; text-shadow: 0 0 10px #ff0055;">SYSTEM SETTINGS</h2>

            <!-- 탭 메뉴 -->
            <div class="tab-menu">
                <button class="tab-btn active" onclick="openTab(event, 'general')">GENERAL</button>
                <button class="tab-btn" onclick="openTab(event, 'security')">SECURITY</button>
                <button class="tab-btn" onclick="openTab(event, 'notification')">NOTI</button>
            </div>

            <form action="/api/user/update" method="POST">
                <!-- [1] 일반 정보 탭 -->
					<div id="general" class="tab-content active">
					    <form action="/api/user/update" method="POST">
					        <!-- 아이디 (고정) -->
					        <div class="info-row">
					            <span class="label">ID / EMAIL</span>
					            <span class="value">${sessionScope.loginUser.UId}</span>
					            <input type="hidden" name="uId" value="${sessionScope.loginUser.UId}">
					        </div>
					
					        <!-- 닉네임 (조회/수정 공용) -->
					        <div class="info-row">
					            <span class="label">NICKNAME</span>
					            <span class="view-mode">${sessionScope.loginUser.UNick}</span>
					            <input type="text" name="uNick" class="neon-input edit-mode" value="${sessionScope.loginUser.UNick}" style="display:none;">
					        </div>
					
					        <!-- 지역 (조회/수정 공용) -->
					        <div class="info-row">
					            <span class="label">REGION</span>
					            <span class="view-mode">${not empty sessionScope.loginUser.URegion ? sessionScope.loginUser.URegion : '미설정'}</span>
					            <input type="text" name="uRegion" class="neon-input edit-mode" value="${sessionScope.loginUser.URegion}" style="display:none;">
					        </div>
					
					        <!-- 성별 (조회/수정 공용) -->
					        <div class="info-row">
					            <span class="label">GENDER</span>
					            <span class="view-mode">
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
					
					        <!-- 선호 장르 -->
					        <div class="info-row">
					            <span class="label">PREFERRED GENRE</span>
					            <span class="view-mode">${not empty sessionScope.loginUser.UPreferredGenre ? sessionScope.loginUser.UPreferredGenre : 'NONE'}</span>
					            <input type="text" name="uPreferredGenre" class="neon-input edit-mode" value="${sessionScope.loginUser.UPreferredGenre}" style="display:none;">
					        </div>
					
					        <!-- 버튼 제어 -->
					        <div class="btn-group">
					            <button type="button" id="edit-start-btn" class="save-btn" onclick="toggleEditMode(true)">EDIT PROFILE INFO</button>
					            <button type="submit" id="save-btn" class="save-btn edit-mode" style="display:none;">SAVE CHANGES</button>
					            <button type="button" id="cancel-btn" class="withdraw-btn edit-mode" style="display:none; margin-top:10px;" onclick="toggleEditMode(false)">CANCEL</button>
					        </div>
					    </form>
					</div>
					
                <!-- [2] 계정 보안 탭 -->
					<div id="security" class="tab-content">
					    <c:choose>
					        <c:when test="${sessionScope.loginUser.USocialType == 'LOCAL'}">
					            <!-- 비밀번호 변경 전용 입력 그룹 -->
					            <div id="pw-change-group">
					                <div class="info-row">
					                    <span class="label">CURRENT PASSWORD</span>
					                    <input type="password" id="currentPw" class="neon-input" placeholder="현재 비밀번호를 입력하세요">
					                </div>
					                <div class="info-row">
					                    <span class="label">NEW PASSWORD</span>
					                    <input type="password" id="newPw" class="neon-input" placeholder="새 비밀번호를 입력하세요">
					                </div>
					                <div class="info-row">
					                    <span class="label">CONFIRM NEW PASSWORD</span>
					                    <input type="password" id="confirmPw" class="neon-input" placeholder="새 비밀번호를 한 번 더 입력하세요">
					                </div>
					                <button type="button" class="save-btn" onclick="changePassword()">CHANGE PASSWORD</button>
					                <div id="pwMsg" style="font-size: 12px; margin-top: 10px; text-align: center;"></div>
					            </div>
					        </c:when>
					        <c:otherwise>
					            <div class="social-notice">
					                이 계정은 <strong>${sessionScope.loginUser.USocialType}</strong>를 통해 연동되었습니다.<br>
					                비밀번호 수정은 해당 소셜 서비스에서 가능합니다.
					            </div>
					        </c:otherwise>
					    </c:choose>
					
					    <!-- 탈퇴 구역 -->
					    <div class="danger-zone">
					        <span class="label">DANGER ZONE</span>
					        <p style="font-size:11px; color:#888;">회원 탈퇴 시 모든 데이터가 즉시 삭제되며 복구할 수 없습니다.</p>
					        <button type="button" class="withdraw-btn" onclick="confirmWithdraw()">DELETE ACCOUNT</button>
					    </div>
					</div>

                <!-- [3] 알림 설정 탭 -->
                <div id="notification" class="tab-content">
                    <div class="info-row">
                        <span class="label">EMAIL NOTIFICATION</span>
                        <input type="checkbox" name="emailNoti" checked> Receive system updates via email
                    </div>
                    <div class="info-row">
                        <span class="label">MARKETING PUSH</span>
                        <input type="checkbox" name="pushNoti"> Receive marketing & event news
                    </div>
                    <button type="submit" class="save-btn">SAVE PREFERENCES</button>
                </div>
            </form>
        </div>
    </div>

    <script>
    	//탭 함수
        function openTab(evt, tabName) {
            var i, tabcontent, tablinks;
            tabcontent = document.getElementsByClassName("tab-content");
            for (i = 0; i < tabcontent.length; i++) { tabcontent[i].classList.remove("active"); }
            tablinks = document.getElementsByClassName("tab-btn");
            for (i = 0; i < tablinks.length; i++) { tablinks[i].classList.remove("active"); }
            document.getElementById(tabName).classList.add("active");
            evt.currentTarget.classList.add("active");
        }

        // 수정 모드 토글 함수
        function toggleEditMode(isEdit) {
            const viewElements = document.querySelectorAll('.view-mode');
            const editElements = document.querySelectorAll('.edit-mode');
            const startBtn = document.getElementById('edit-start-btn');
            const saveBtn = document.getElementById('save-btn');
            const cancelBtn = document.getElementById('cancel-btn');

            if (isEdit) {
                // 수정 모드 활성화
                viewElements.forEach(el => el.style.display = 'none');
                editElements.forEach(el => el.style.display = 'block');
                startBtn.style.display = 'none';
                saveBtn.style.display = 'block';
                cancelBtn.style.display = 'block';
            } else {
                // 조회 모드 복귀
                viewElements.forEach(el => el.style.display = 'block');
                editElements.forEach(el => el.style.display = 'none');
                startBtn.style.display = 'block';
                saveBtn.style.display = 'none';
                cancelBtn.style.display = 'none';
            }
        }

        //탈퇴
        function confirmWithdraw() {
            if(confirm("정말로 탈퇴하시겠습니까? 모든 정보가 삭제되며 복구할 수 없습니다.")) {
                $.ajax({
                    url: '/api/user/withdraw',
                    type: 'GET',
                    success: function(res) {
                        alert(res);
                        location.href = "/"; // 메인 페이지로 이동
                    },
                    error: function(xhr) {
                        alert("오류 발생: " + xhr.responseText);
                    }
                });
            }
        }
        
        //비밀번호 변경
        function changePassword() {
            const currentPw = $('#currentPw').val();
            const newPw = $('#newPw').val();
            const confirmPw = $('#confirmPw').val();

            if (!currentPw || !newPw || !confirmPw) {
                alert("모든 필드를 입력해주세요.");
                return;
            }

            if (newPw !== confirmPw) {
                $('#pwMsg').text("❌ 새 비밀번호가 일치하지 않습니다.").css("color", "#ff0055");
                return;
            }

            // 서버로 비밀번호 변경 요청 전송
            $.ajax({
                url: '/api/user/update-pw',
                type: 'POST',
                data: {
                    currentPw: currentPw,
                    newPw: newPw
                },
                success: function(res) {
                    alert("비밀번호가 성공적으로 변경되었습니다.");
                    location.reload(); // 입력창 초기화
                },
                error: function(xhr) {
                    // 현재 비밀번호가 틀렸을 경우 서버에서 에러 메시지 반환
                    $('#pwMsg').text("❌ " + xhr.responseText).css("color", "#ff0055");
                }
            });
        }
    </script>
</body>
</html>