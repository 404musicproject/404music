package com.project.springboot.controller;

import java.util.Arrays;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.project.springboot.dto.LibrarySongDTO;
import com.project.springboot.dto.MusicDTO;
import com.project.springboot.dto.PlaylistDTO;
import com.project.springboot.dto.PlaylistTrackViewDTO;
import com.project.springboot.dto.UserDTO;
import com.project.springboot.service.MusicService;
import com.project.springboot.service.PlaylistService;
import com.project.springboot.service.RecommendationService;

// 스프링 부트 버전에 따라 아래 import 중 맞는 것을 사용하세요.
// import javax.servlet.http.HttpSession; // 구버전 (Spring Boot 2.x)
import jakarta.servlet.http.HttpSession; // 신버전 (Spring Boot 3.x)

@Controller
public class MusicPageController {

    @Autowired
    private PlaylistService playlistService;
    
    @Autowired
    private MusicService musicService;
    
    // =====================================================
    // 0. 검색
    // =====================================================
    		
    @GetMapping("/productSearchfh")
    public String searchPage(@RequestParam(value = "searchKeyword", required = false) String keyword, Model model) {
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            // 1. 실시간 수집 및 DB 저장 (Last.fm + iTunes + Spotify)
            musicService.searchAndSave(keyword);
            
            // 2. 방금 수집/업데이트된 데이터를 DB에서 다시 읽어옴
            List<MusicDTO> searchResults = musicService.getMusicListByKeyword(keyword);
            
            // 3. 결과를 JSP로 전달
            model.addAttribute("musicList", searchResults);
            model.addAttribute("keyword", keyword);
        }
        
        return "SearchResult"; // 이 JSP로 이동하면서 musicList 데이터를 들고 감
    }
    
    // =====================================================
    // 1. 페이지 이동 관련 (View Rendering)
    // =====================================================

    @Autowired
    private RecommendationService recommendationService;
    
    // 메인 홈 화면 (3단 레이아웃)
    // 주의: 다른 컨트롤러(UserViewController 등)에 @GetMapping("/")이 있다면 지워야 충돌이 안 납니다.
    @GetMapping({"/", "/home"}) 
    public String home(HttpSession session, Model model) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        Long uNo = (user != null) ? (long)user.getUNo() : 0L;

        // 1. 우측 사이드바 데이터
        List<PlaylistDTO> myPlaylists = playlistService.getMyPlaylists(uNo);
        model.addAttribute("myPlaylists", myPlaylists);
        
        // 2. [추가] 사용자 맞춤 태그 TOP 5 가져오기
        List<String> topTags;
        if (uNo > 0) {
            topTags = recommendationService.getUserTopTags(uNo.intValue());
        } else {
            // 비로그인 시 보여줄 기본 태그 5개
            topTags = Arrays.asList("운동", "휴식", "잠잘 때", "행복한 기분", "로맨스");
        }
        
        // 만약 로그인 유저인데 감상 기록이 없어 빈 리스트가 왔을 때를 대비
        if (topTags == null || topTags.isEmpty()) {
            topTags = Arrays.asList("운동", "휴식", "잠잘 때", "행복한 기분", "로맨스");
        }
        
        model.addAttribute("topTags", topTags);
        
        return "Home"; 
    }
    // 음악 메인 인덱스 (실시간 차트 등)
    @GetMapping("/music/Index")
    public String mainIndex() {
        return "guest/Index"; 
    }

    // 지역별 차트 페이지
    @GetMapping("/music/regional")
    public String regionalChart(@RequestParam("city") String city, Model model) {
        model.addAttribute("city", city.toUpperCase());
        return "guest/RegionalIndex"; 
    }

    // 테스트 페이지 (필요 없으면 삭제 가능)
    @GetMapping("/music/test")
    public String musicTest() {
        return "music_test";
    }

    // =====================================================
    // 2. 데이터 처리 API (AJAX / JSON)
    // =====================================================

    // 찜한 노래 가져오기 (좌측 사이드바)
    @GetMapping("/api/user/library")
    @ResponseBody
    public List<LibrarySongDTO> getMyLibrary(HttpSession session) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        Long uNo = (user != null) ? (long)user.getUNo() : 0L;
        return playlistService.getLikedSongs(uNo);
    }

    // 플레이리스트 상세 곡 목록
    @GetMapping("/api/playlist/tracks")
    @ResponseBody
    public List<PlaylistTrackViewDTO> getPlaylistTracks(@RequestParam("tNo") Long tNo) {
        return playlistService.getPlaylistTracks(tNo);
    }

    // [핵심] 플레이리스트 생성 API
    @PostMapping("/api/playlist/create")
    @ResponseBody
    public String createPlaylist(@RequestParam("title") String title, HttpSession session) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        if (user == null) {
            return "fail"; // 로그인 안 했으면 fail
        }

        Long uNo = (long) user.getUNo();
        // 기본 커버이미지 ID는 1번으로 고정 (필요시 수정)
        playlistService.createPlaylist(uNo, title, 1L); 
        
        return "success";
    }

    // [핵심] 우측 사이드바용 플레이리스트 목록 갱신 API
    @GetMapping("/api/playlist/my")
    @ResponseBody
    public List<PlaylistDTO> getMyPlaylistsAPI(HttpSession session) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        if (user == null) return null;
        
        return playlistService.getMyPlaylists((long)user.getUNo());
    }
 // 기존 MusicPageController 클래스 안에 이 메서드를 추가해주세요.

    // [추가] 플레이리스트 상세 페이지 이동
    @GetMapping("/user/playlists/detail")
    public String playlistDetail(@RequestParam("tNo") Long tNo, Model model, HttpSession session) {
        
        // 1. 플레이리스트 정보 가져오기 (제목, 커버 등)
        // (주의: PlaylistService에 getPlaylistInfo 메서드가 있어야 함. 없으면 아래 단계 참고)
        PlaylistDTO playlist = playlistService.getPlaylistInfo(tNo);
        model.addAttribute("playlist", playlist);
        
        // 2. JSP 파일 위치 지정 [여기가 틀렸었음!]
        // 실제 경로: /WEB-INF/views/playlist/PlaylistDetail.jsp
        return "playlist/PlaylistDetail"; 
    }
    @PostMapping("/user/playlists/tracks/add")
    @ResponseBody
    public String addTrackToPlaylist(
            @RequestParam("tNo") Long tNo, 
            @RequestParam("mNo") Long mNo, 
            HttpSession session) {
        
        // 1. 로그인 체크
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        if (user == null) return "fail";

        // 2. 서비스 호출 (곡 담기)
        try {
            playlistService.addTrackToPlaylist(tNo, mNo);
            return "success";
        } catch (Exception e) {
            e.printStackTrace();
            return "error";
        }
    }
 // 기존 Controller 클래스 안에 아래 메서드를 추가해주세요.

    // [추가] 플레이리스트 삭제 기능
    @PostMapping("/user/playlist/delete")
    @ResponseBody
    public String deletePlaylist(@RequestParam("tNo") Long tNo) {
        try {
            // 서비스에 deletePlaylist 메서드가 있어야 합니다.
            playlistService.deletePlaylist(tNo); 
            return "success";
        } catch (Exception e) {
            e.printStackTrace();
            return "fail";
        }
    }
}