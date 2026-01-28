<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="sidebar-left">
    <div class="nav-label">MENU</div>
    <a href="/home" class="nav-item ${param.page == 'home' ? 'active' : ''}">
        <i class="fas fa-home"></i> HOME
    </a>
    <a href="#" onclick="alert('준비중')" class="nav-item">
        <i class="fas fa-search"></i> SEARCH
    </a>
    
    <div class="nav-label">LIBRARY</div>
    <a href="/user/library" class="nav-item ${param.page == 'library' ? 'active' : ''}">
        <i class="fas fa-heart"></i> LIKED SONGS
    </a>
</div>