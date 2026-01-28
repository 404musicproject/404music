package com.project.springboot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.project.springboot.dao.IMusicDAO;
import com.project.springboot.dto.MusicDTO;
import com.project.springboot.dto.UserDTO;
import com.project.springboot.service.MusicService;

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
    		
    @GetMapping("/musicSearch") // 소문자로 시작
    public String searchPage(@RequestParam(value = "searchKeyword", required = false) String keyword, Model model) {
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            musicService.searchAndSave(keyword);
            List<MusicDTO> searchResults = musicService.getMusicListByKeyword(keyword);
            
            model.addAttribute("musicList", searchResults);
            model.addAttribute("keyword", keyword);
        }
        
        // 이 파일이 views/guest/ 폴더 안에 있는게 확실하다면 이대로 둡니다.
        // 만약 views/ 폴더 바로 아래에 있다면 "SearchResult"로 고쳐야 합니다.
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
}