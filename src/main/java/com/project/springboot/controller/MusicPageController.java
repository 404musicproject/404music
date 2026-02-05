package com.project.springboot.controller;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.project.springboot.dao.IMusicDAO;
import com.project.springboot.dto.AlbumDTO;
import com.project.springboot.dto.ArtistDTO;
import com.project.springboot.dto.MusicDTO;
import com.project.springboot.dto.UserDTO;
import com.project.springboot.service.MusicService;
import com.project.springboot.service.RecommendationService;

// 스프링 부트 버전에 따라 아래 import 중 맞는 것을 사용하세요.
// import javax.servlet.http.HttpSession; // 구버전 (Spring Boot 2.x)
import jakarta.servlet.http.HttpSession; // 신버전 (Spring Boot 3.x)

@Controller
public class MusicPageController {

    @Autowired
    private MusicService musicService;
    @Autowired
    private IMusicDAO musicDAO;
    // =====================================================
    // 0. 검색
    // =====================================================
    		
    @GetMapping("/musicSearch")
    public String searchPage(
            @RequestParam(value = "searchType", required = false, defaultValue = "TITLE") String searchType,
            @RequestParam(value = "searchKeyword", required = false) String keyword,
            HttpSession session, 
            Model model
    ) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        int uNo = (user != null) ? user.getUNo() : 0; 

        String type = (searchType == null) ? "TITLE" : searchType.trim().toUpperCase();
        model.addAttribute("searchType", type);
        model.addAttribute("keyword", keyword);

        if (keyword == null || keyword.trim().isEmpty()) {
            return "guest/SearchResult";
        }

        List<MusicDTO> searchResults;

        if ("LYRICS".equals(type)) {
            searchResults = musicDAO.selectMusicByLyrics(keyword, uNo);
        } else {
            // [1] 먼저 정규화 키워드를 가져옵니다 (예: 백예린 -> thevolunteers)
            // MusicService에 public으로 getNormalizedKeyword가 있어야 합니다.
            String normalized = musicService.getNormalizedKeyword(keyword);

            // [2] ES 검색 (keyword, type, uNo 순서 확인)
            searchResults = musicService.getMusicListByES(keyword, type, uNo);

            // [3] ES 결과가 없거나 백예린처럼 솔로곡을 더 긁어와야 하는 상황일 때
            if (searchResults == null || searchResults.isEmpty()) {
                // [수정 핵심] 인자 3개를 정확히 전달: (원본, 정규화, 타입)
                musicService.searchAndSave(keyword, normalized, type);
                
                // 다시 조회
                searchResults = musicService.getMusicListByES(keyword, type, uNo);
            }
        }

        model.addAttribute("musicList", searchResults);
        return "guest/SearchResult";
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
        
        // 1. DB에서 노래가 있는 실제 상위 태그들을 넉넉히 가져옴 (예: 15개)
        List<String> allTopTags = recommendationService.getUserTopTags(uNo);
        
        // 2. 분류 기준 정의 (DB의 g_name과 정확히 일치해야 함)
        List<String> contextRef = Arrays.asList("카페/작업", "바다", "헬스장", "공원/피크닉", "산/등산", "맑음", "흐림", "비 오는 날", "눈 오는 날");
        
        // 3. 섹션별로 분류
        List<String> homeContextTags = new ArrayList<>(); // 📍 NOW & HERE
        List<String> homeMoodTags = new ArrayList<>();    // ✨ FOR YOUR MOOD
        
        for (String tag : allTopTags) {
            if (contextRef.contains(tag)) {
                homeContextTags.add(tag);
            } else {
                homeMoodTags.add(tag);
            }
        }
        
        // 만약 데이터가 너무 없으면 기본값이라도 넣어줌 (DB에 존재하는 이름 기준)
        if (allTopTags.isEmpty()) {
            homeMoodTags.addAll(Arrays.asList("행복한 기분", "새벽 감성", "휴식"));
            homeContextTags.addAll(Arrays.asList("카페/작업", "맑음"));
        }

        model.addAttribute("homeContextTags", homeContextTags);
        model.addAttribute("homeMoodTags", homeMoodTags);
        
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
    
    @GetMapping("/music/myLibrary")
    public String myLibrary(HttpSession session, Model model) {
        // 1. 세션 확인
        UserDTO user = (UserDTO) session.getAttribute("loginUser");

        // 2. 로그인 안되어 있을 때 처리
        if (user == null) {
            return "redirect:/user/login"; 
        }

        // 3. 데이터 조회
        int uNo = user.getUNo();

        List<MusicDTO> libraryList = musicDAO.selectMusicByLibrary(uNo);
        List<MusicDTO> likedList = musicDAO.selectLikedMusic(uNo);

        model.addAttribute("libraryList", libraryList);
        model.addAttribute("likedList", likedList);
        model.addAttribute("keyword", "MY LIBRARY");

        return "user/MyLibrary";
    }

    
    // [수정] 주소에 슬래시(/)를 넣어서 브라우저 요청과 일치시킵니다.
    @GetMapping("/artist/detail")
    public String artistDetail(@RequestParam("a_no") int aNo, HttpSession session, Model model) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        int uNo = (user != null) ? user.getUNo() : 0;

        // [변경] 서비스 호출을 통해 사진이 없으면 채워오도록 함
        // (서비스에 로직 짜기 귀찮다면 일단 기존 데이터가 잘 들어왔는지 확인부터 해야합니다)
        ArtistDTO artist = musicDAO.selectArtistByNo(aNo); 
        List<MusicDTO> musicList = musicDAO.selectMusicByArtistNo(aNo, uNo);

        model.addAttribute("artist", artist);
        model.addAttribute("musicList", musicList);
        
        return "guest/ArtistDetail";
    }

    @RequestMapping("/album/detail")
    public String albumDetail(@RequestParam("b_no") int b_no, HttpSession session, Model model) {
        // 1. 앨범 정보 가져오기
        AlbumDTO album = musicDAO.selectAlbumByNo(b_no);
        
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        int uNo = (user != null) ? user.getUNo() : 0;
        
        // 2. 해당 앨범 번호를 가진 곡 목록 가져오기
        List<MusicDTO> musicList = musicDAO.selectMusicByAlbumNo(b_no, uNo);
        
        // 3. [핵심] 만약 앨범 정보가 null이라면 곡 목록에서 정보를 추출
        if (album == null && musicList != null && !musicList.isEmpty()) {
            album = new AlbumDTO();
            album.setB_no(b_no);
            album.setB_title(musicList.get(0).getM_title()); // 첫 번째 곡 제목을 앨범 제목으로 사용
            album.setB_image(musicList.get(0).getB_image()); // 곡의 이미지를 앨범 이미지로 사용
        }

        model.addAttribute("album", album);
        model.addAttribute("musicList", musicList);
        
        return "guest/AlbumDetail";
    }
}