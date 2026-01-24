<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>404Music Support</title>
<!-- 헤더/푸터 CSS 및 메인 컨테이너 스타일은 여기에 포함되어야 합니다. -->
</head>
<body>
<!-- Header include (예시) -->
 <jsp:include page="/WEB-INF/views/common/Header.jsp" />

<div class="support-content">
    <c:choose>
        <%-- mode 값이 'notice'일 때만 noticeList.jsp 파일을 불러옵니다. --%>
        <c:when test="${mode == 'notice'}">
            <jsp:include page="Notification.jsp" />
        </c:when>

        <%-- mode 값이 'faq'일 때만 faqContent.jsp 파일을 불러옵니다. --%>
        <c:when test="${mode == 'faq'}">
            <jsp:include page="FaqContent.jsp" />
        </c:when>
        
        <%-- mode 값이 'inquiry'일 때만 inquiryList.jsp 파일을 불러옵니다. --%>
        <c:when test="${mode == 'inquiry'}">
             <jsp:include page="InquiryList.jsp" />
        </c:when>
        
        <c:otherwise>

        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/Footer.jsp" />
</body>
</html>