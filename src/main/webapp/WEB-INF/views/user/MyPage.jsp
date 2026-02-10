<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>마이페이지 | 404MUSIC</title>
    
    <link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&display=swap" rel="stylesheet">

    <style type="text/css">
        html, body { 
            margin: 0; padding: 0; 
            background-color: #000 !important; 
        }

        .mypage-container { 
            display: flex; justify-content: center; align-items: flex-start; 
            min-height: 100vh; padding: 60px 20px; 
            font-family: 'Pretendard', sans-serif;
            color: #fff;
        }
        
        .mypage-container * { box-sizing: border-box; }

        .neon-card { 
            width: 100%; max-width: 580px; 
            padding: 50px; 
            background: #080808; 
            border: 1px solid #1a1a1a;
            position: relative; 
            box-shadow: 0 20px 50px rgba(0,0,0,0.9);
        }

        .neon-card::before {
            content: ""; position: absolute; top: -1px; left: -1px; right: -1px; height: 3px;
            background: linear-gradient(90deg, #ff0055, #00f2ff, #ff0055);
            background-size: 200% auto;
            animation: neonFlow 3s linear infinite;
        }
        @keyframes neonFlow { to { background-position: 200% center; } }

        .neon-card h2 {
            text-align: center; color: #ff0055 !important; 
            text-shadow: 0 0 15px rgba(255, 0, 85, 0.5); 
            letter-spacing: 4px; font-family: 'Orbitron', sans-serif;
            font-weight: 900; text-transform: uppercase; margin: 0 0 40px 0;
        }

        .tab-menu { 
            display: flex; justify-content: space-around; 
            margin-bottom: 40px; border-bottom: 1px solid #222; 
        }
        .tab-btn { 
            padding: 15px 0; background: transparent; border: none; color: #555; 
            cursor: pointer; font-weight: 700; font-size: 14px;
            transition: 0.3s; font-family: 'Pretendard', sans-serif;
            flex: 1; letter-spacing: 1px;
        }
        .tab-btn.active { 
            color: #00f2ff !important; 
            border-bottom: 2px solid #00f2ff !important; 
            text-shadow: 0 0 10px rgba(0, 242, 255, 0.8); 
        }

        .tab-content { display: none; animation: slideUp 0.4s ease-out; }
        .tab-content.active { display: block; }
        @keyframes slideUp { 
            from { opacity: 0; transform: translateY(10px); } 
            to { opacity: 1; transform: translateY(0); } 
        }

        .profile-section { text-align: center; margin-bottom: 40px; }
        .profile-wrapper {
            width: 130px; height: 130px; margin: 0 auto;
            border-radius: 50%; border: 2px solid #222;
            overflow: hidden; position: relative; cursor: pointer;
            transition: 0.4s; background: #111;
        }
        .profile-wrapper img { width: 100%; height: 100%; object-fit: cover; }
        .profile-wrapper::after {
            content: '변경'; position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.6); color: #00f2ff;
            display: flex; align-items: center; justify-content: center;
            opacity: 0; transition: 0.3s; font-weight: 900;
        }
        .profile-wrapper:hover::after { opacity: 1; }
		/* 닉네임 입력란과 버튼을 가로로 배치하기 위한 스타일 */
		.input-group {
		    display: flex;
		    gap: 10px;
		}
		.check-btn {
		    white-space: nowrap;
		    padding: 0 15px;
		    background: transparent;
		    border: 1px solid #ff0055;
		    color: #ff0055;
		    font-size: 12px;
		    font-weight: bold;
		    cursor: pointer;
		    transition: 0.3s;
		}
		.check-btn:hover {
		    background: #ff0055;
		    color: #fff;
		}
        .info-row { margin-bottom: 25px; text-align: left; }
        .label { 
            color: #ff0055; font-size: 12px; font-weight: 700; 
            display: block; margin-bottom: 10px; 
            letter-spacing: 1px;
        }
        .value { font-size: 15px; color: #ccc; display: block; font-family: 'Pretendard', sans-serif; }
        
        .neon-input { 
            width: 100%; background: #111; border: 1px solid #333; 
            color: #fff; padding: 14px 18px; font-family: 'Pretendard', sans-serif;
            font-size: 14px; transition: 0.3s; border-radius: 4px;
        }
        .neon-input:focus { border-color: #00f2ff; outline: none; box-shadow: 0 0 15px rgba(0, 242, 255, 0.2); }

        .btn-group { margin-top: 40px; display: flex; flex-direction: column; gap: 12px; }
        .save-btn { 
            width: 100%; padding: 18px; background: transparent; 
            border: 1px solid #00f2ff; color: #00f2ff; 
            font-family: 'Pretendard', sans-serif; font-weight: 700; 
            font-size: 15px; cursor: pointer; transition: 0.3s; letter-spacing: 1px;
        }
        .save-btn:hover:not(:disabled) { background: #00f2ff; color: #000; box-shadow: 0 0 25px rgba(0, 242, 255, 0.4); }

        .withdraw-btn { background: transparent; border: none; color: #555; cursor: pointer; text-decoration: underline; font-size: 12px; }
        .withdraw-btn.edit-mode {
            display: block; width: 100%; padding: 16px; border: 1px solid #333; color: #666; 
            text-decoration: none; text-align: center; transition: 0.3s; font-size: 14px; font-weight: 700;
        }
        .withdraw-btn.edit-mode:hover { border-color: #ff0055; color: #ff0055; background: rgba(255,0,85,0.05); }

        .social-notice { background: #0a1012; padding: 18px; border-left: 3px solid #00f2ff; color: #00f2ff; font-size: 14px; margin-bottom: 25px; line-height: 1.6; }
        .danger-zone { border: 1px solid #222; padding: 25px; margin-top: 40px; background: rgba(255, 0, 85, 0.02); }
        .sub-card { border: 1px solid #333; padding: 25px; border-radius: 4px; background: #0c0c0c; }
        
        #nickMsg, #pwMsg { font-weight: 600; font-size: 12px; margin-top: 8px; }
    </style>
    
    <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
    <script>
    // [1] 탭 전환 함수
    function openTab(evt, tabName) {
        $('.tab-content').removeClass('active');
        $('.tab-btn').removeClass('active');
        $('#' + tabName).addClass('active');
        if (evt && evt.currentTarget) { 
            $(evt.currentTarget).addClass('active'); 
        } else { 
            $('.tab-btn').filter(function() { 
                return $(this).attr('onclick').includes(tabName); 
            }).addClass('active'); 
        }
    }

    $(document).ready(function() {
        const originalNick = "${sessionScope.loginUser.UNick}";
        let isNickChecked = true; 
        let timer; // 디바운싱을 위한 타이머

        $('#uNick').on('input', function() {
            const currentNick = $(this).val().trim();
            
            // 입력이 시작되면 일단 저장 버튼 비활성화
            isNickChecked = false;
            $('#save-btn').prop('disabled', true);
            $('#nickMsg').text("입력 중...").css("color", "#888");

            // 이전 타이머 제거 (연속 타이핑 시 중복 요청 방지)
            clearTimeout(timer);

            // 0.5초 동안 입력이 없으면 중복 체크 실행
            timer = setTimeout(function() {
                if (currentNick === originalNick) {
                    $('#nickMsg').text("현재 사용 중인 닉네임입니다.").css("color", "gray");
                    isNickChecked = true;
                    $('#save-btn').prop('disabled', false);
                    return;
                }

                if (currentNick.length < 2) {
                    $('#nickMsg').text("닉네임은 최소 2자 이상이어야 합니다.").css("color", "#ff0055");
                    return;
                }

                // AJAX 요청
                $.get("/api/user/guest/check-nick", { uNick: currentNick }, function(isAvailable) {
                    if (isAvailable) {
                        $('#nickMsg').text("✅ 사용 가능한 닉네임입니다.").css("color", "#00f2ff");
                        isNickChecked = true;
                        $('#save-btn').prop('disabled', false);
                    } else {
                        $('#nickMsg').text("❌ 이미 존재하는 닉네임입니다.").css("color", "#ff0055");
                        isNickChecked = false;
                        $('#save-btn').prop('disabled', true);
                    }
                });
            }, 500); // 500ms 대기
        });
    });

    // [5] 기타 기능 함수들
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

    function confirmWithdraw() {
        if(confirm("정말 탈퇴하시겠습니까? 그동안의 활동 내역이 모두 삭제됩니다.")) {
            $.get("/api/user/withdraw", function(res) {
                alert("탈퇴 처리가 완료되었습니다.");
                location.href="/";
            });
        }
    }
    
 // [추가] 비밀번호 변경 함수
    function changePassword() {
        const currentPw = $('#currentPw').val();
        const newPw = $('#newPw').val();
        const confirmPw = $('#confirmPw').val();
        const pwMsg = $('#pwMsg');

        // 1. 유효성 검사
        if (!currentPw || !newPw || !confirmPw) {
            pwMsg.text("모든 필드를 입력해주세요.").css("color", "#ff0055");
            return;
        }

        if (newPw !== confirmPw) {
            pwMsg.text("새 비밀번호가 일치하지 않습니다.").css("color", "#ff0055");
            return;
        }

        if (newPw.length < 4) {
            pwMsg.text("비밀번호는 최소 4자 이상이어야 합니다.").css("color", "#ff0055");
            return;
        }

        // 2. 서버 전송 (API 경로는 프로젝트 설계에 맞춰 확인 필요)
        $.ajax({
            url: "/api/user/update-password", // 컨트롤러의 @PostMapping 주소와 반드시 일치!
            type: "POST",
            data: {
                currentPw: $('#currentPw').val(),
                newPw: $('#newPw').val()
            },
            success: function(res) {
                console.log("서버 응답:", res); // 디버깅용
                
                if (res === "success") {
                    alert("비밀번호가 성공적으로 변경되었습니다.");
                    location.reload();
                } else if (res === "wrong_password") {
                    $('#pwMsg').text("현재 비밀번호가 일치하지 않습니다.").css("color", "#ff0055");
                } else {
                    $('#pwMsg').text("비밀번호 변경에 실패했습니다.").css("color", "#ff0055");
                }
            },
            error: function(xhr) {
                console.error("에러 발생:", xhr);
                if(xhr.status === 404) {
                    alert("서버 경로를 찾을 수 없습니다(404). URL 매핑을 확인하세요.");
                } else {
                    alert("서버 통신 중 에러가 발생했습니다.");
                }
            }
        });
    }
 
 // 구독 취소 예약 함수
    function cancelSubscription() {
        if(!confirm("정말 구독을 취소하시겠습니까?\n취소하셔도 이용 기간 종료일까지는 혜택이 유지됩니다.")) return;

        $.post("/api/subscription/cancel", function(res) {
            if(res === "SUCCESS") {
                alert("구독 해지 예약이 완료되었습니다.");
                location.reload();
            } else {
                alert("처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
            }
        });
    }

    // 구독 취소 번복(다시 유지) 함수
    function reverseCancel() {
        if(!confirm("구독 해지 예약을 취소하고 구독을 유지하시겠습니까?")) return;

        $.post("/api/subscription/reverseCancel", function(res) {
            if(res === "SUCCESS") {
                alert("구독이 다시 정상 유지 상태로 변경되었습니다.");
                location.reload();
            } else {
                alert("처리 중 오류가 발생했습니다.");
            }
        });
    }
</script>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/Header.jsp" />

    <div class="mypage-container">
        <div class="neon-card">
            <h2>MY PAGE</h2>

            <div class="tab-menu">
                <button class="tab-btn active" onclick="openTab(event, 'general')">기본 정보</button>
                <button class="tab-btn" onclick="openTab(event, 'security')">보안 설정</button>
                <button class="tab-btn" onclick="openTab(event, 'notification')">알림 설정</button>
                <button class="tab-btn" onclick="openTab(event, 'sub-container')">구독 관리</button>
            </div>

            <form action="/api/user/update" method="POST">
                <div id="general" class="tab-content active">
                    <div class="profile-section">
                        <div class="profile-wrapper" onclick="location.href='/user/profile'">
                            <img id="currentProfileImg" src="${not empty sessionScope.loginUser.UProfileImg ? sessionScope.loginUser.UProfileImg : '/img/default-profile.png'}" onerror="this.src='https://via.placeholder.com/150/080808/00f2ff?text=NO+IMG'">
                        </div>
                        <p style="font-size: 12px; color: #555; margin-top: 10px;">이미지 클릭 시 프로필 관리로 이동합니다</p>
                    </div>

                    <div class="info-row">
                        <span class="label">아이디 / 이메일</span>
                        <span class="value">${sessionScope.loginUser.UId}</span>
                        <input type="hidden" name="uId" value="${sessionScope.loginUser.UId}">
                    </div>
            
                    <div class="info-row">
					    <span class="label">닉네임</span>
					    <span class="view-mode value">${sessionScope.loginUser.UNick}</span>
					    <div class="edit-mode" style="display:none;">
					        <input type="text" name="uNick" id="uNick" class="neon-input" value="${sessionScope.loginUser.UNick}">
					        <div id="nickMsg"></div>
					    </div>
					</div>
					            
                    <div class="info-row">
                        <span class="label">지역</span>
                        <span class="view-mode value">${not empty sessionScope.loginUser.URegion ? sessionScope.loginUser.URegion : '미설정'}</span>
                        <input type="text" name="uRegion" class="neon-input edit-mode" value="${sessionScope.loginUser.URegion}" style="display:none;" placeholder="예: 서울, 부산">
                    </div>

                    <div class="info-row">
                        <span class="label">성별</span>
                        <span class="view-mode value">
                            <c:choose>
                                <c:when test="${sessionScope.loginUser.UGender == 'M'}">남성</c:when>
                                <c:when test="${sessionScope.loginUser.UGender == 'F'}">여성</c:when>
                                <c:otherwise>미설정</c:otherwise>
                            </c:choose>
                        </span>
                        <select name="uGender" class="neon-input edit-mode" style="display:none;">
                            <option value="M" ${sessionScope.loginUser.UGender == 'M' ? 'selected' : ''}>남성</option>
                            <option value="F" ${sessionScope.loginUser.UGender == 'F' ? 'selected' : ''}>여성</option>
                            <option value="O" ${sessionScope.loginUser.UGender == 'O' ? 'selected' : ''}>기타</option>
                        </select>
                    </div>
            
                    <div class="info-row">
                        <span class="label">선호 장르</span>
                        <span class="view-mode value">${not empty sessionScope.loginUser.UPreferredGenre ? sessionScope.loginUser.UPreferredGenre : '설정된 장르 없음'}</span>
                        <input type="text" name="uPreferredGenre" class="neon-input edit-mode" value="${sessionScope.loginUser.UPreferredGenre}" style="display:none;" placeholder="예: Rock, Jazz, K-Pop">
                    </div>
            
                    <div class="btn-group">
                        <button type="button" id="edit-start-btn" class="save-btn" onclick="toggleEditMode(true)">정보 수정하기</button>
                        <button type="submit" id="save-btn" class="save-btn edit-mode" style="display:none;">변경사항 저장</button>
                        <button type="button" id="cancel-btn" class="withdraw-btn edit-mode" style="display:none;" onclick="toggleEditMode(false)">취소</button>
                    </div>
                </div>
            </form>

            <div id="security" class="tab-content">
                <c:choose>
                    <c:when test="${sessionScope.loginUser.USocialType == 'LOCAL'}">
                        <div class="info-row"><span class="label">현재 비밀번호</span><input type="password" id="currentPw" class="neon-input" placeholder="본인 확인을 위해 입력하세요"></div>
                        <div class="info-row"><span class="label">새 비밀번호</span><input type="password" id="newPw" class="neon-input" placeholder="새로운 비밀번호를 입력하세요"></div>
                        <div class="info-row"><span class="label">비밀번호 확인</span><input type="password" id="confirmPw" class="neon-input" placeholder="한 번 더 입력하세요"></div>
                        <button type="button" class="save-btn" onclick="changePassword()">비밀번호 변경하기</button>
                        <div id="pwMsg"></div>
                    </c:when>
                    <c:otherwise>
                        <div class="social-notice">이 계정은 <strong>${sessionScope.loginUser.USocialType}</strong>를 통해 로그인되었습니다.<br>소셜 계정은 해당 서비스에서 보안 설정을 관리해주세요.</div>
                    </c:otherwise>
                </c:choose>
                <div class="danger-zone">
                    <span class="label" style="color: #666;">계정 관리</span>
                    <button type="button" class="withdraw-btn" onclick="confirmWithdraw()">회원 탈퇴하기</button>
                </div>
            </div>

            <div id="notification" class="tab-content">
                <div class="info-row">
                    <span class="label">이메일 알림 수신</span>
                    <label style="color:#ccc; display:flex; align-items:center; gap:10px; font-size:15px; cursor:pointer;">
                        <input type="checkbox" checked style="accent-color: #00f2ff; width:18px; height:18px;"> 
                        404MUSIC의 신규 업데이트 및 공지사항 알림을 받습니다.
                    </label>
                </div>
                <button type="button" class="save-btn" onclick="alert('알림 설정이 저장되었습니다.')">설정 저장하기</button>
            </div>

            <div id="sub-container" class="tab-content">
    <c:choose>
        <c:when test="${not empty subscription}">
            <div class="sub-card">
                <h3 style="color:#00f2ff; margin-top:0; font-family:'Orbitron';">PLAN: ${subscription.SSub}</h3>
                
                <p class="value">구독 상태: 
                    <c:choose>
                        <c:when test="${subscription.SCancelReserved == 'T'}">
                            <strong style="color:#ff0055;">해지 예약됨 (종료 예정)</strong>
                        </c:when>
                        <c:otherwise>
                            <strong style="color:#00f2ff;">현재 이용 중</strong>
                        </c:otherwise>
                    </c:choose>
                </p>
                
                <p class="value" style="font-size:14px; color:#888; margin-top:10px;">
                    이용 기간: ${subscription.SStartDate} ~ ${subscription.SEndDate}
                </p>

                <div style="margin-top: 25px; border-top: 1px solid #222; padding-top: 20px;">
                    <c:choose>
                        <c:when test="${subscription.SCancelReserved == 'T'}">
                            <p style="font-size: 12px; color: #ff0055; margin-bottom: 10px;">* 다음 결제일에 구독이 종료될 예정입니다.</p>
                            <button type="button" class="save-btn" style="border-color: #ff0055; color: #ff0055;" onclick="reverseCancel()">구독 유지하기</button>
                        </c:when>
                        <c:otherwise>
                            <button type="button" class="withdraw-btn" onclick="cancelSubscription()">정기 결제 해지 예약하기</button>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div style="text-align:center; padding: 40px; border: 1px dashed #333;">
                <p style="color:#888; margin-bottom: 20px;">현재 활성화된 구독 플랜이 없습니다.</p>
                <button class="save-btn" onclick="location.href='/user/subscription'">구독 플랜 보러가기</button>
            </div>
        </c:otherwise>
    </c:choose>
</div>
        </div>
    </div>
    <footer><jsp:include page="/WEB-INF/views/common/Footer.jsp" /></footer>
</body>
</html>