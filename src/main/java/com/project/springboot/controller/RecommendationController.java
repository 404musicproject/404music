package com.project.springboot.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.project.springboot.dto.MusicDTO;
import com.project.springboot.dto.UserDTO;
import com.project.springboot.service.RecommendationService; // 변경된 서비스 임포트

import jakarta.servlet.http.HttpSession;

@Controller // JSP 이동과 데이터 처리를 같이 하는 클래스
public class RecommendationController {

    private final RecommendationService recommendationService;

    public RecommendationController(RecommendationService recommendationService) {
        this.recommendationService = recommendationService;
    }

    // 1. 페이지 이동 (View 리턴)
    @GetMapping("/recommendationCategories")
    public String showRecommendationPage() {
        return "recommendationCategories"; 
    }

    // 2. AJAX 데이터 리턴 (JSON 리턴을 위해 @ResponseBody 필수!)
    @GetMapping("/api/recommendations/tag/{tagName}")
    @ResponseBody
    public List<MusicDTO> getMusicByTag(
            @PathVariable("tagName") String tagName, 
            HttpSession session) {
        
        // 1. 세션에서 "loginUser" 키로 객체를 꺼냅니다. (UserRestController와 일치)
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        
        // 2. 객체가 있으면 번호를 추출, 없으면 0(비로그인)으로 설정
        int u_no = (loginUser != null) ? loginUser.getUNo() : 0; 
        
        // 디버깅용 로그
        System.out.println("로그인 확인 - 닉네임: " + (loginUser != null ? loginUser.getUNick() : "비로그인"));
        System.out.println("전달될 u_no: " + u_no);

        return recommendationService.getRecommendationsByTag(tagName, u_no);
    }
    
    @GetMapping("/music/recommendationList")
    public String showRecommendationList(@RequestParam("tagName") String tagName, Model model) {
        // JSP에서 어떤 태그를 보여줄지 알 수 있도록 tagName을 전달
        model.addAttribute("tagName", tagName);
        return "RecommendationList"; // -> /WEB-INF/views/recommendationList.jsp 실행
    }
    
}