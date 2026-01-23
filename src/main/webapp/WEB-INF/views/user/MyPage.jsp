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
    
    <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
    <script>
    // [보완] 탭 함수 (evt가 null이어도 작동하도록 수정)
    function openTab(evt, tabName) {
            // 모든 컨텐츠 숨기기
            const contents = document.querySelectorAll('.tab-content');
            contents.forEach(content => {
                content.classList.remove('active');
            });

            // 모든 버튼 비활성화
            const buttons = document.querySelectorAll('.tab-btn');
            buttons.forEach(btn => {
                btn.classList.remove('active');
            });

            // 해당 탭 및 버튼 활성화
            const targetTab = document.getElementById(tabName);
            if (targetTab) {
                targetTab.classList.add('active');
            }

            // 클릭 이벤트가 있는 경우(버튼 클릭)와 없는 경우(URL 파라미터 호출) 대응
            if (evt && evt.currentTarget) {
                evt.currentTarget.classList.add('active');
            } else {
                // tabName을 포함하는 onclick 속성을 가진 버튼을 찾아서 active 추가
                const targetBtn = document.querySelector(`.tab-btn[onclick*='${tabName}']`);
                if (targetBtn) targetBtn.classList.add('active');
            }
        }

        $(document).ready(function() {
            // URL에 ?tab=sub 등이 있는지 확인하여 해당 탭을 바로 띄움
            const urlParams = new URLSearchParams(window.location.search);
            const tabParam = urlParams.get('tab');

            if (tabParam === 'sub') {
                openTab(null, 'sub-container');
            } else {
                // 기본값: 첫 번째 탭 활성화
                openTab(null, 'general');
            }
        });
        
        let nickChecked = true; // 처음엔 본인 닉네임이므로 true
        const originalNick = "${sessionScope.loginUser.UNick}"; // 기존 닉네임 저장
        let timer; 

        $('#uNick').on('input', function() {
            const nick = $(this).val();
            
            // 1. 기존 닉네임과 동일할 경우 (본인 확인)
            if (nick === originalNick) {
                $('#nickMsg').text("현재 사용 중인 닉네임입니다.").css("color", "gray");
                nickChecked = true;
                $('#save-btn').prop('disabled', false); // 저장 버튼 활성화
                return;
            }

            nickChecked = false; // 글자가 바뀌면 일단 false
            $('#save-btn').prop('disabled', true); // 중복 확인 전까지 저장 버튼 비활성화
            
            clearTimeout(timer);
            
            if (nick.length < 2) {
                $('#nickMsg').text("닉네임은 2자 이상 입력해주세요.").css("color", "orange");
                return;
            }

            // 0.3초 대기 후 서버 통신
            timer = setTimeout(function() {
                $.get("/api/user/guest/check-nick", { uNick: nick }, function(isAvailable) {
                    if (isAvailable) {
                        $('#nickMsg').text("✅ 사용 가능한 닉네임입니다.").css("color", "cyan");
                        nickChecked = true;
                        $('#save-btn').prop('disabled', false); // 중복 없으면 저장 버튼 활성화
                    } else {
                        $('#nickMsg').text("❌ 이미 사용 중인 닉네임입니다.").css("color", "red");
                        nickChecked = false;
                        $('#save-btn').prop('disabled', true); // 중복이면 저장 버튼 비활성화
                    }
                });
            }, 300);
        });

        // 폼 제출 시 최종 확인 (엔터 키 등으로 제출 방지)
        $('form').on('submit', function(e) {
            if (!nickChecked) {
                alert("닉네임을 확인해주세요.");
                e.preventDefault(); // 전송 중단
                return false;
            }
        });
    </script>

    
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
                <button class="tab-btn" onclick="openTab(event, 'sub-container')">SUBSCRIPTION</button>
            </div>

            <form action="/api/user/update" method="POST">
                <!-- [1] 일반 정보 탭 -->
					<div id="general" class="tab-content active">
					        <!-- 아이디 (고정) -->
					        <div class="info-row">
					            <span class="label">ID / EMAIL</span>
					            <span class="value">${sessionScope.loginUser.UId}</span>
					            <input type="hidden" name="uId" value="${sessionScope.loginUser.UId}">
					        </div>
					
					        <!-- 닉네임 (조회/수정 공용) -->
							<div class="info-row">
							    <span class="label">NICKNAME</span>
							    <!-- 조회 모드 -->
							    <span class="view-mode">${sessionScope.loginUser.UNick}</span>
							    
							    <!-- 수정 모드 -->
							    <div class="edit-mode"style="display:none;" >
							        <input type="text" name="uNick" id="uNick" class="neon-input" value="${sessionScope.loginUser.UNick}">
							        <div id="nickMsg""></div>
							    </div>
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
					  
					</div>
			</form>
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
                <!-- [4] 구독 정보 탭 -->
                <div id="sub-container" class="tab-content">
				    <h2>나의 구독 관리</h2>
				    <c:choose>
				        <c:when test="${not empty subscription}">
							<div class="card active">
							    <h3>이용 중인 상품: ${subscription.SSub}</h3>
							    
							    <!-- 결제 상태에 따라 텍스트 및 다음 결제일 표시 제어 -->
							    <p>결제 상태: 
							        <c:choose>
							            <c:when test="${subscription.SStatus eq 'PENDING_CANCEL'}">
							                <strong style="color:#ff0055;">취소 예정</strong>
							            </c:when>
							            <c:otherwise>
							                <strong>${subscription.SStatus}</strong>
							            </c:otherwise>
							        </c:choose>
							    </p>
							
							    <p>이용 기간: ${subscription.SStartDate} ~ ${subscription.SEndDate}</p>
							
							    <!-- '취소 예정' 상태가 아닐 때만 다음 결제 예정일을 표시 -->
							    <c:if test="${subscription.SStatus ne 'PENDING_CANCEL'}">
							        <p>다음 결제 예정일: <strong>${subscription.SNextSub}</strong></p>
							    </c:if>
							    
							    <!-- 해지 상태에 따른 버튼/메시지 제어 -->
							    <c:choose>
							        <c:when test="${subscription.SCancelReserved == 'F'}">
							             <!-- 해지 예약 안 됨: 해지 예약 버튼 표시 -->
							             <button class="save-btn" onclick="cancelSubscription()">정기 결제 해지 예약</button>
							        </c:when>
							        <c:otherwise>
							            <!-- 해지 예약 됨 (T): 예약 철회 버튼 표시 -->
							            <p class="text-danger" style="margin-top:15px;">
							                [해지 예약 완료] ${subscription.SEndDate}에 자동 종료됩니다.
							            </p>
							            <button class="save-btn" onclick="reverseCancelSubscription()">
							                해지 예약 철회 및 구독 유지
							            </button>
							        </c:otherwise>
							    </c:choose>
							</div>
				        </c:when>
				     	<c:otherwise>
				            <div class="card empty">
				                <p>구독 중인 상품이 없습니다.</p>
				                <button onclick="location.href='/user/subscription'">이용권 구매</button>
				            </div>
				    	</c:otherwise>
				    </c:choose>
				</div>
        </div>
    </div>

    <script>
    $(document).ready(function() {
        // 1. URL 파라미터 확인 (?tab=sub 확인)
        const urlParams = new URLSearchParams(window.location.search);
        const tabParam = urlParams.get('tab');

        // 2. 파라미터가 'sub'이면 구독 탭 강제 활성화
        if (tabParam === 'sub') {
            openTab(null, 'sub-container');
        }
    });


    
    function cancelSubscription() {
        if (confirm("정기 결제를 해지하시겠습니까? 해지 후에도 이용 기간까지는 계속 사용 가능합니다.")) {
            $.ajax({
                url: '/api/subscription/cancel',
                type: 'POST',
                success: function(res) {
                    alert("해지 예약이 완료되었습니다.");
                    location.reload(); // 상태 업데이트를 위해 새로고침
                },
                error: function(xhr) {
                    alert("해지 처리 중 오류가 발생했습니다: " + xhr.responseText);
                }
            });
        }
    }
    
    function reverseCancelSubscription() {
        // 1. 사용자 확인창
        if (!confirm("정기 결제 해지 예약을 철회하고 구독을 유지하시겠습니까?")) {
            return; // 사용자가 취소를 누르면 함수 종료
        }

        // 2. 서버로 예약 철회 요청 전송 (jQuery 사용)
        $.ajax({
            url: '/api/subscription/reverseCancel', // 컨트롤러에 만든 새로운 URL
            type: 'POST',
            success: function(res) {
                alert("구독이 유지됩니다.");
                location.reload(); // 화면 새로고침하여 '취소 예정' 문구 제거
            },
            error: function(xhr) {
                alert("오류가 발생했습니다: " + xhr.responseText);
            }
        });
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