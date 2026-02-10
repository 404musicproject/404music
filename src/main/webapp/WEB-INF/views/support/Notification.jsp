<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>404Music // 전체공지</title>
    <meta http-equiv="Content-Security-Policy" content="img-src 'self' * data:;">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <style>
    /* 1. 기본 배경 및 폰트 설정 (FAQ와 동일) */
    body { 
        background-color: #050505; 
        color: #00f2ff; 
    }
    
    .main-container { 
     		font-family: 'Courier New', monospace;
		    min-height: auto;
		    padding: 40px;
		    max-width: 900px; 
		    margin: 0 auto;
		}
    
    /* 2. 제목 스타일 (FAQ glitch-title 그대로 적용) */
    .glitch-title { 
        text-shadow: 2px 2px #ff0055; 
        border-left: 5px solid #ff0055; 
        padding-left: 15px; 
        margin-bottom: 30px; 
        font-size: 30px; /* 24px에서 30px로 변경 */
        font-family: inherit;
    }
    
    /* notice-body 내 이미지 및 영상 크기 자동 조절 */
	.notice-body img {
	    max-width: 100%;    /* 부모 영역을 넘지 않게 */
	    height: auto;       /* 비율 유지 */
	    display: block;     /* 하단 여백 방지 */
	    margin: 15px 0;     /* 이미지 위아래 간격 */
	    border: 1px solid #333; /* 이미지 테두리 (디자인 컨셉) */
	}
	
	/* 에디터에서 설정한 글자 색상이 다크모드에서 안 보일 경우를 대비 */
	.notice-body {
	    word-break: break-all; /* 긴 영문/링크 줄바꿈 */
	    overflow-wrap: break-word;
	}
	
	/* 테이블 내 HTML 태그 출력 시 텍스트 정렬 */
	.notice-body p {
	    margin: 8px 0;
	}
    
    /* 3. 테이블 스타일 (FAQ 항목 느낌으로 수정) */
    .retro-table { 
        width: 100%; 
        border-collapse: collapse; 
        border-top: 1px solid #333; /* FAQ 상단 라인 스타일 */
        table-layout: fixed;
    }
    
    .retro-table th { 
        background: #0a0a0a; 
        color: #ff0055; 
        padding: 12px 15px; 
        border-bottom: 1px solid #222; 
        font-size: 13px; 
        font-weight: bold;
        text-align: center;
    }
    
    .retro-table td { 
        padding: 12px 15px; 
        border-bottom: 1px solid #222; 
        color: #00f2ff; 
        font-size: 13px; /* FAQ 질문 크기 */
        font-family: inherit;
        text-align: center;
        transition: background 0.3s;
    }
    
    /* 테이블 행 호버 효과 (FAQ 질문 호버와 동일) */
    .notice-item-header:hover { 
        background: rgba(0, 242, 255, 0.05); 
        cursor: pointer; 
    }

    /* 제목 영역 (FAQ 질문 스타일 적용) */
    .retro-table .subject {
        text-align: left;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap; 
        font-weight: bold; /* FAQ 질문처럼 굵게 */
    }        
    .notice-tag { color: #ff0055; margin-right: 12px; }

    /* 4. 아코디언 내용 영역 (FAQ 답변 스타일 적용) */
    .content-row { display: none; }
    .content-cell { 
        padding: 18px 20px 18px 45px !important; /* FAQ 답변 패딩 적용 */
        background-color: #0a0a0a; /* FAQ 답변 배경색 */
        color: #ccc; /* FAQ 답변 글자색 */
        line-height: 1.5; 
        border-top: 1px dashed #333; /* FAQ 답변 상단 점선 */
        border-bottom: 1px solid #222;
        text-align: left !important; 
        font-size: 12px; /* FAQ 답변 크기 */
        font-family: inherit;
    }
    
    /* 관리자 컨트롤 영역 */
    .admin-controls { 
        text-align: right; 
        margin-top: 15px; 
        padding-top: 10px; 
        border-top: 1px dotted #333; 
    }
    
    .btn-admin { 
        background: transparent; 
        border: 1px solid #00f2ff; 
        color: #00f2ff; 
        padding: 5px 10px; 
        cursor: pointer; 
        font-size: 11px; 
        transition: 0.3s; 
        margin-left: 5px; 
        font-family: inherit;
    }
    .btn-admin:hover { border-color: #ff0055; color: #ff0055; }

	 /* 버튼 컨테이너: 테이블 오른쪽 하단(날짜 컬럼 끝)에 배치 */
	.write-container { 
	    text-align: right;    /* 오른쪽 정렬 */
	    margin-top: 20px;     /* 테이블과의 수직 간격 */
	    padding-right: 0;     /* 오른쪽 여백 제거하여 테이블 라인에 맞춤 */
	}
		
	/* 버튼 컨테이너: 테이블 오른쪽 하단에 바짝 붙임 */
	.write-container { 
	    text-align: right;    /* 오른쪽 정렬 */
	    margin-top: -35px;     /* 🔥 테이블 쪽으로 위로 끌어올림 */
	    margin-bottom: 10px;
	    padding-right: 0;     /* 오른쪽 끝 라인 맞춤 */
	}
	
	/* 1:1 문의 버튼 디자인과 100% 동일하게 */
	.btn-write { 
	    background: transparent; 
	    border: 1px solid #00f2ff; 
	    color: #00f2ff;
	    padding: 6px 15px;         
	    font-size: 11px;          
	    cursor: pointer; 
	    font-family: inherit;
	    transition: 0.3s; 
	    text-transform: uppercase;
	    display: inline-block;
	}
	
	/* 호버 효과 */
	.btn-write:hover { 
	    border-color: #ff0055; 
	    color: #ff0055; 
	    box-shadow: 0 0 10px rgba(255, 0, 85, 0.4);
	}
    
    /* 5. 페이징 스타일 (FAQ와 완전 동일) */
    .pagination-container { 
        text-align: center; 
        margin-top: 20px; 
        display: flex; 
        justify-content: center; 
        gap: 8px; 
        padding-bottom: 40px; 
    }
    .page-btn { 
        background: transparent; 
        border: 1px solid #00f2ff; 
        color: #00f2ff; 
        padding: 5px 10px; 
        cursor: pointer; 
        font-size: 11px; 
        font-family: inherit;
        transition: 0.3s;
    }
    .page-btn.active { 
        background: #00f2ff; 
        color: #000; 
        box-shadow: 0 0 10px #00f2ff; 
    }
    .page-btn:hover:not(.active) {
        border-color: #ff0055;
        color: #ff0055;
    }
</style>
</head>
<body>

<div class="main-container">
    <h2 class="glitch-title"> 전체공지</h2>

    <table class="retro-table">
        <thead>
            <tr>
                <th width="15%">NO.</th>
                <th width="60%">로그제목</th>
                <th width="25%">로그날짜</th>
            </tr>
        </thead>
        <tbody id="noticeTbody">
            <c:forEach var="notice" items="${list}" varStatus="status">
                <tr onclick="toggleNotice('${status.index}')" class="notice-item-header">
                    <td>${notice.INo}</td>
                    <td class="subject">
                        <span class="notice-tag">Q.</span> ${notice.ITitle}
                    </td>
                    <td><fmt:formatDate value="${notice.IDate}" pattern="yy.MM.dd"/></td>
                </tr>
                
                <tr id="content-${status.index}" class="content-row">
                    <td colspan="3" class="content-cell">
                        <div class="notice-body">
                            <c:out value="${notice.IContent}" escapeXml="false" />
                        </div>

                        <c:if test="${sessionScope.loginUser.UAuth == 'ADMIN'}">
                            <div class="admin-controls">
                                <button type="button" class="btn-admin" 
                                        onclick="location.href='${pageContext.request.contextPath}/support/noticeUpdate?nNo=${notice.INo}'">
                                    수정버튼
                                </button>
                                <button type="button" class="btn-admin" 
        								onclick="deleteNotice('${notice.INo}')" style="border-color:#ff0055; color:#ff0055;">
    								삭제버튼
								</button>
                            </div>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <div id="pagination" class="pagination-container"></div>

    <c:if test="${mode == 'notice' && sessionScope.loginUser.UAuth == 'ADMIN'}">
        <div class="write-container">
            <button type="button" class="btn-write" onclick="location.href='${pageContext.request.contextPath}/support/noticeWrite'">
                + 새로운 공지등록
            </button>
        </div>
    </c:if>
</div>

<script>
function toggleNotice(index) {
    const target = document.getElementById("content-" + index);
    const isVisible = (target.style.display === "table-row");
    
    // 다른 열려있는 내용 닫기
    document.querySelectorAll(".content-row").forEach(row => row.style.display = "none");
    
    if (!isVisible) {
        target.style.display = "table-row";
    }
}

function deleteNotice(num) {
    if(confirm("정말 삭제하시겠습니까?")) {
        location.href = '${pageContext.request.contextPath}/support/noticeDelete.do?nNo=' + num;
    }
}

const rowsPerPage = 10; 
const titleRows = document.querySelectorAll('.notice-item-header'); 
const pageCount = Math.ceil(titleRows.length / rowsPerPage);
const paginationContainer = document.getElementById('pagination');

function showPage(page) {
    const start = (page - 1) * rowsPerPage;
    const end = start + rowsPerPage;
    
    // 모든 행 숨기기 (헤더와 컨텐츠 모두)
    document.querySelectorAll('#noticeTbody tr').forEach(row => row.style.display = 'none');
    
    // 현재 페이지의 헤더만 보여주기
    titleRows.forEach((row, idx) => {
        if (idx >= start && idx < end) {
            row.style.display = 'table-row';
        }
    });
    
    // 버튼 활성화
    document.querySelectorAll('.page-btn').forEach((btn, idx) => {
        btn.classList.toggle('active', idx === page - 1);
    });
}

function initPagination() {
    if (!paginationContainer) return;
    paginationContainer.innerHTML = ''; 
    if (pageCount <= 1 && titleRows.length > 0) {
        showPage(1);
        return;
    }
    for (let i = 1; i <= pageCount; i++) {
        const btn = document.createElement('button');
        btn.innerText = i;
        btn.className = 'page-btn';
        btn.onclick = () => { showPage(i); window.scrollTo(0,0); };
        paginationContainer.appendChild(btn);
    }
    showPage(1); 
}

document.addEventListener('DOMContentLoaded', initPagination);
</script>
</body>
</html>