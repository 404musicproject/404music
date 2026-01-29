package com.project.springboot.controller;

import java.util.ArrayList;
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

    // 3. 특정 태그의 음악 리스트 가져오기 (AJAX용)
    @GetMapping("/api/recommendations/tag/{tagName}")
    @ResponseBody
    public List<MusicDTO> getMusicByTag(
            @PathVariable("tagName") String tagName, 
            HttpSession session) {
        
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        int uNo = (loginUser != null) ? loginUser.getUNo() : 0; 

        // 파라미터 tagName과 Long 타입으로 변환된 uNo 전달
        return recommendationService.getRecommendationsByTag(tagName, (long) uNo);
    }

    // 4. 상세 리스트 페이지로 이동
    @GetMapping("/music/recommendationList")
    public String showRecommendationList(@RequestParam("tagName") String tagName, HttpSession session, Model model) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        Long uNo = (user != null) ? (long)user.getUNo() : 0L;
        
        List<String> topTags = recommendationService.getUserTopTags(uNo);
        
        // [핵심] 만약 4번 섹션에서 클릭한 tagName이 topTags 리스트에 없다면 맨 앞에 추가해줌
        if (!topTags.contains(tagName)) {
            topTags = new ArrayList<>(topTags); // 수정 가능한 리스트로 변환
            topTags.add(0, tagName); 
        }
        
        model.addAttribute("tagName", tagName);
        model.addAttribute("topTags", topTags);
        return "user/RecommendationList";
    }
}