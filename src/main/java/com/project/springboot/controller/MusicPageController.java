package com.project.springboot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.project.springboot.dto.MusicDTO;
import com.project.springboot.service.MusicService;

@Controller
public class MusicPageController {

	@Autowired // 이 서비스 주입도 잊지 마세요!
    private MusicService musicService;

    
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
}