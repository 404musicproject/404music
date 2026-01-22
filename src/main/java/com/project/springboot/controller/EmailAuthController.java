package com.project.springboot.controller;

import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/auth")
public class EmailAuthController {
	@Autowired
    private JavaMailSender mailSender;

    // 1. 인증번호 발송
    @PostMapping("/send-email")
    public String sendEmail(@RequestParam("email") String email, HttpSession session) {
        // 6자리 난수 생성
        String authCode = String.valueOf(new Random().nextInt(899999) + 100000);
        
        // 세션에 인증번호와 이메일 저장 (3분 동안만 유효하게 설정 가능)
        session.setAttribute("authCode", authCode);
        session.setAttribute("authEmail", email);
        session.setMaxInactiveInterval(180); // 3분 제한

        // 메일 발송 로직
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(email);
        message.setSubject("[서비스명] 회원가입 인증번호입니다.");
        message.setText("인증번호: " + authCode);
        mailSender.send(message);

        return "success";
    }

    // 2. 인증번호 검증
    @PostMapping("/verify-code")
    public String verifyCode(@RequestParam("code") String code, HttpSession session) {
        String serverCode = (String) session.getAttribute("authCode");

        if (serverCode != null && serverCode.equals(code)) {
            session.setAttribute("isVerified", true); // 인증 완료 표시
            return "success";
        }
        return "fail";
    }
}