package com.project.springboot.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/music")
public class MusicPageController {

	@RequestMapping("/test")
    public String test() {
        // WEB-INF/views/guest/index.jsp 로 연결
        return "music_test"; 
    }
	// 1. 일반 메인 인덱스 (실시간 차트 등)
    @RequestMapping("/Index")
    public String mainIndex() {
        // WEB-INF/views/guest/index.jsp 로 연결
        return "guest/Index"; 
    }

    // 2. 지역별 인덱스 (분리된 버전)
    @RequestMapping("/regional")
    public String regionalChart(@RequestParam("city") String city, Model model) {
        model.addAttribute("city", city.toUpperCase());
        // WEB-INF/views/guest/RegionalIndex.jsp 로 연결
        return "guest/RegionalIndex"; 
    }
}