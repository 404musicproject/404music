<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>${album.b_title} - 앨범 상세</title>
    <style>
        .album-header { display: flex; padding: 40px; background: #222; color: white; }
        .album-img { width: 250px; height: 250px; object-fit: cover; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        .album-info { margin-left: 30px; display: flex; flex-direction: column; justify-content: flex-end; }
        .album-info h1 { font-size: 4rem; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="album-header">
        <img src="${album.b_image}" class="album-img">
        <div class="album-info">
            <p>ALBUM</p>
            <h1>${album.b_title}</h1>
            <p>아티스트: <a href="/artistDetail?a_no=${album.a_no}" style="color:white;">${artistName}</a></p>
        </div>
    </div>
    </body>
</html>