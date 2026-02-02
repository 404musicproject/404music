package com.project.springboot.controller;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.project.springboot.dto.MusicDTO;
import com.project.springboot.dto.UserDTO;
import com.project.springboot.service.RecommendationService; // 변경된 서비스 임포트

import jakarta.servlet.http.HttpSession;

@Controller
public class RecommendationController {

    private final RecommendationService recommendationService;

    public RecommendationController(RecommendationService recommendationService) {
        this.recommendationService = recommendationService;
    }

    // 1. 페이지 이동 (View 리턴)
    @GetMapping("/recommendationCategories")
    public String showRecommendationPage() {
        return "user/recommendationCategories"; 
    }

    // 2. 유저의 선호 태그 목록 가져오기 (AJAX용)
    @GetMapping("/api/recommendations/user-tags")
    @ResponseBody
    public List<String> getUserTopTags(HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        
        // int uNo를 꺼낸 뒤 서비스(Long)에 맞게 형변환하여 전달
        int uNo = (loginUser != null) ? loginUser.getUNo() : 0;
        return recommendationService.getUserTopTags((long) uNo);
    }

    // 3. 특정 태그의 음악 리스트 가져오기 (수정본)
    @GetMapping("/api/recommendations/tag") // 경로에서 {tagName}을 삭제했습니다.
    @ResponseBody
    public List<MusicDTO> getMusicByTag(
            @RequestParam("tagName") String tagName, // PathVariable을 RequestParam으로 변경
            HttpSession session) {
        
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        int uNo = (loginUser != null) ? loginUser.getUNo() : 0; 

        return recommendationService.getRecommendationsByTag(tagName, (long) uNo);
    }

    // 4. 상세 리스트 페이지로 이동
 // RecommendationController.java 내의 해당 메서드 수정

    @GetMapping("/music/recommendationList")
    public String showRecommendationList(@RequestParam("tagName") String tagName, HttpSession session, Model model) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        Long uNo = (user != null) ? (long)user.getUNo() : 0L;
        
        // 유저가 선호하는 모든 태그 리스트 (이름만 가져옴)
        List<String> userTags = recommendationService.getUserTopTags(uNo);
        
        // 고정된 장소 태그 (Location)
        List<String> placeTags = Arrays.asList("바다", "산/등산", "카페/작업", "헬스장", "공원/피크닉");

        model.addAttribute("tagName", tagName);
        model.addAttribute("userTags", userTags); // 유저 기반 태그들
        model.addAttribute("placeTags", placeTags); // 위치 기반 태그들
        
        return "user/RecommendationList";
    }
}