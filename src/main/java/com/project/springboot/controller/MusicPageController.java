package com.project.springboot.controller;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.project.springboot.dao.IMusicDAO;
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
    
    @Autowired
    private RecommendationService recommendationService;
    // =====================================================
    // 0. 검색
    // =====================================================
    		
    @GetMapping("/musicSearch")
    public String searchPage(
            @RequestParam(value = "searchType", required = false, defaultValue = "TITLE") String searchType,
            @RequestParam(value = "searchKeyword", required = false) String keyword,
            HttpSession session, // 1. 세션 추가
            Model model
    ) {
        // 2. 로그인한 유저 정보 가져오기
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        int uNo = (user != null) ? user.getUNo() : 0; 

        String type = (searchType == null) ? "TITLE" : searchType.trim().toUpperCase();
        if (!List.of("TITLE", "ARTIST", "ALBUM", "LYRICS", "ALL").contains(type)) {
            type = "TITLE";
        }

        model.addAttribute("searchType", type);
        model.addAttribute("keyword", keyword);

        if (keyword == null || keyword.trim().isEmpty()) {
            return "guest/SearchResult";
        }

        List<MusicDTO> searchResults;
        // 3. DAO 호출 시 uNo를 두 번째 인자로 반드시 전달!
        switch (type) {
            case "ARTIST" -> searchResults = musicDAO.selectMusicByArtist(keyword, uNo);
            case "ALBUM" -> searchResults = musicDAO.selectMusicByAlbum(keyword, uNo);
            case "LYRICS" -> searchResults = musicDAO.selectMusicByLyrics(keyword, uNo);
            case "ALL" -> searchResults = musicDAO.selectMusicByKeyword(keyword, uNo);
            default -> searchResults = musicDAO.selectMusicByTitle(keyword, uNo);
        }

        // 결과 없을 때 재수집 로직에서도 마찬가지로 uNo 추가
        if ((searchResults == null || searchResults.isEmpty()) && !"LYRICS".equals(type)) {
            musicService.searchAndSave(keyword);

            switch (type) {
                case "ARTIST" -> searchResults = musicDAO.selectMusicByArtist(keyword, uNo);
                case "ALBUM" -> searchResults = musicDAO.selectMusicByAlbum(keyword, uNo);
                case "ALL" -> searchResults = musicDAO.selectMusicByKeyword(keyword, uNo);
                default -> searchResults = musicDAO.selectMusicByTitle(keyword, uNo);
            }
        }

        model.addAttribute("musicList", searchResults);
        return "guest/SearchResult";
    }
    
    // =====================================================
    // 1. 페이지 이동 관련 (View Rendering)
    // =====================================================

    // 메인 홈 화면 (3단 레이아웃)
    // 주의: 다른 컨트롤러(UserViewController 등)에 @GetMapping("/")이 있다면 지워야 충돌이 안 납니다.
    @GetMapping({"/", "/home"}) 
    public String home(HttpSession session, Model model) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        Long uNo = (user != null) ? (long)user.getUNo() : 0L; 
        
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
        
        
        return "Home"; // src/main/webapp/WEB-INF/views/Home.jsp
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
        
        // 2. 로그인 안되어 있을 때 (프로젝트의 실제 로그인 페이지 경로로 수정하세요)
        if (user == null) {
            // 만약 로그인 페이지가 /user/login 이라면 아래처럼 수정
            return "redirect:/user/login"; 
        }

        // 3. 데이터 조회 (반드시 u_no를 넘겨야 함)
        // 여기서 musicDAO.selectMusicByLibrary를 호출해야 보관함 곡이 나옵니다.
        // 만약 musicService.getTop100() 등을 호출하고 있다면 인덱스 곡이 나옵니다.
        List<MusicDTO> libraryList = musicDAO.selectMusicByLibrary(user.getUNo());
        
        model.addAttribute("libraryList", libraryList);
        model.addAttribute("keyword", "MY LIBRARY"); // 제목 표시용
        
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

    // 앨범도 같은 방식으로 통일해두면 에러를 방지할 수 있습니다.
    @GetMapping("/album/detail")
    public String albumDetail(@RequestParam("b_no") int bNo, HttpSession session, Model model) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        int uNo = (user != null) ? user.getUNo() : 0;

        model.addAttribute("album", musicDAO.selectAlbumByNo(bNo));
        model.addAttribute("musicList", musicDAO.selectMusicByAlbumNo(bNo, uNo));
        
        return "guest/AlbumDetail";
    }
    
    @GetMapping("/api/popup/list")
    @ResponseBody  // 👈 이게 빠지면 500 에러 혹은 404 에러가 발생합니다!
    public List<Map<String, Object>> getPopupList() {
        try {
            List<Map<String, Object>> popups = new ArrayList<>();
            
            // 테스트용 데이터 (이 데이터가 프론트에 나오면 성공입니다)
            Map<String, Object> testPopup = new HashMap<>();
            testPopup.put("title", "연결 성공");
            testPopup.put("content", "이제 500 에러가 나지 않습니다.");
            popups.add(testPopup);
            
            return popups; // 이제 JSON 형태로 깔끔하게 반환됩니다.
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>(); // 에러 시 빈 리스트 반환
        }
    }
}