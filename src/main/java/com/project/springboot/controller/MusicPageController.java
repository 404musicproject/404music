package com.project.springboot.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/music")
public class MusicPageController {

    @GetMapping("/test")
    public String musicTestPage() {
        System.out.println("[PAGE LOG] 테스트 페이지 접속");
        return "music_test"; // music_test.jsp 호출
    }
}