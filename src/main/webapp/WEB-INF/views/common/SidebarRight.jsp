<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="sidebar-right">
    <div class="pl-header">
        <div style="font-weight:bold; font-size:0.85rem;">MY LIBRARY</div>
        <button class="btn-create" onclick="createNewPlaylist()">+ NEW</button>
    </div>
    
    <div id="common-playlist-box">
        <div style="text-align:center; padding:20px; color:#555;">Loading...</div>
    </div>
</div>

<script>
// 1. 페이지 로딩 시 목록 불러오기
$(document).ready(function() {
    loadSidebarPlaylists();
});

// 2. 플레이리스트 목록 가져오기 (AJAX)
function loadSidebarPlaylists() {
    $.get('${pageContext.request.contextPath}/api/playlist/my', function(data) {
        let html = '';
        if(!data || data.length === 0) {
            html = '<div style="color:#555; font-size:0.8rem; text-align:center; padding-top:20px;">NO PLAYLISTS</div>';
        } else {
            $.each(data, function(i, pl) {
                // 클릭 시 상세 페이지 이동
                html += '<div class="pl-item" onclick="location.href=\'${pageContext.request.contextPath}/user/playlists/detail?tNo=' + pl.tNo + '\'">' +
                        '   <div class="pl-icon"><i class="fas fa-compact-disc"></i></div>' +
                        '   <div class="pl-title">' + pl.tTitle + '</div>' +
                        '</div>';
            });
        }
        $('#common-playlist-box').html(html);
    }).fail(function() {
        // 로그인 안 되어 있을 때 처리
        $('#common-playlist-box').html('<div style="color:#555; font-size:0.8rem; text-align:center; padding-top:20px;">Login Required</div>');
    });
}

// 3. [핵심] 플레이리스트 생성하기
function createNewPlaylist() {
    let t = prompt("새 플레이리스트 이름:");
    if(t) {
        $.post('${pageContext.request.contextPath}/api/playlist/create', {title: t}, function(res) {
            if(res === 'success') {
                // 성공하면 즉시 목록을 새로고침합니다! (페이지 리로드 X)
                loadSidebarPlaylists(); 
            } else {
                alert('로그인이 필요하거나 오류가 발생했습니다.');
                location.href = '${pageContext.request.contextPath}/common/Login';
            }
        }).fail(function() {
            alert("서버 연결 실패: Controller를 확인해주세요.");
        });
    }
}
</script>