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

	@PostMapping("/send-email")
    public String sendEmail(@RequestParam("email") String email, HttpSession session) {
		System.setProperty("com.sun.net.ssl.checkRevocation", "false");
	    
	    // 이 부분이 핵심입니다 (인증서 신뢰 설정 강제 주입)
	    java.security.Security.setProperty("jdk.tls.disabledAlgorithms", "");
		
        try {
            // 6자리 난수 생성
            String authCode = String.valueOf(new Random().nextInt(899999) + 100000);
            
            // 세션에 저장
            session.setAttribute("authCode", authCode);
            session.setAttribute("authEmail", email);
            session.setMaxInactiveInterval(180);

            // 메일 발송 로직
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(email);
            message.setSubject("[404Music] 회원가입 인증번호입니다.");
            message.setText("인증번호: " + authCode);
            
            mailSender.send(message);
            System.out.println(">>> 메일 발송 성공: " + email);
            
            return "success";
        } catch (Exception e) {
            System.err.println("!!! 메일 발송 에러 발생 !!!");
            e.printStackTrace(); // 콘솔에 상세 에러 출력
            return "error: " + e.getMessage();
        }
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