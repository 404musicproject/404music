package com.project.springboot.controller;

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
        // 로그인 안 했으면 0L을 넘겨서 '전체 인기 순위'를 가져오게 함
        Long uNo = (user != null) ? (long)user.getUNo() : 0L; 
        
        // [수정된 부분] 서비스가 알아서 로그인 유저면 개인 취향, 비로그인이면 전체 트렌드를 가져옵니다.
        List<String> topTags = recommendationService.getUserTopTags(uNo);
        
        // 혹시나 DB에 데이터가 단 하나도 없을 때를 대비한 최후의 방어막만 남깁니다.
        if (topTags == null || topTags.isEmpty()) {
            topTags = Arrays.asList("행복한 기분", "카페/작업", "운동", "새벽 감성", "휴식");
        }
        model.addAttribute("topTags", topTags);

        // [팁] 장소 태그도 나중에는 DB에서 LOCATION 타입만 긁어오도록 바꿀 수 있어요!
        List<String> placeTags = Arrays.asList("카페/작업", "바다", "헬스장", "공원/피크닉");
        model.addAttribute("placeTags", placeTags);
        
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

        // 3. 데이터 조회 (u_no 기준)
        int uNo = user.getUNo();
        
        // [수정된 부분] 보관함 리스트와 좋아요 리스트를 따로 가져옵니다.
        List<MusicDTO> libraryList = musicDAO.selectMusicByLibrary(uNo);
        List<MusicDTO> likedList = musicDAO.selectLikedMusic(uNo); // DAO에 추가한 그 메서드!
        
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
        AlbumDTO album = musicDAO.selectAlbumByNo(b_no);
        
        // [체크] 만약 album이 null이면 musicList의 첫 번째 곡 정보를 활용해서라도 채워야 합니다.
        if (album == null) {
            System.out.println("⚠️ 앨범 정보를 찾을 수 없습니다. b_no: " + b_no);
        }

        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        int uNo = (user != null) ? user.getUNo() : 0;
        List<MusicDTO> musicList = musicDAO.selectMusicByAlbumNo(b_no, uNo);
        
        model.addAttribute("album", album);
        model.addAttribute("musicList", musicList);
        
        return "guest/AlbumDetail";
    }
}