package com.project.springboot.service;

import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import com.project.springboot.dao.IUserDAO;
import com.project.springboot.dto.UserDTO;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Component
public class MyLoginSuccessHandler implements AuthenticationSuccessHandler {
    @Autowired
    private IUserDAO userDAO;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) throws IOException, ServletException {
        
        HttpSession session = request.getSession();
        UserDTO user = null;

        // 1. 소셜 로그인(OAuth2User)인 경우
        if (authentication.getPrincipal() instanceof org.springframework.security.oauth2.core.user.OAuth2User) {
            org.springframework.security.oauth2.core.user.OAuth2User oAuth2User = (org.springframework.security.oauth2.core.user.OAuth2User) authentication.getPrincipal();
            // registrationId를 알 수 없으니 이메일이나 ID로 조회 (로그 기반으로 이메일 권장)
            String email = oAuth2User.getAttribute("email"); 
            user = userDAO.findById(email);
        } 
        // 2. 일반 로그인(UserDetails)인 경우
        else {
            String userId = authentication.getName(); // 로그인의 아이디(이메일)
            user = userDAO.findById(userId);
        }

        // 3. 세션 설정 (중요: 시간 설정 3600초)
        if (user != null) {
            session.setAttribute("loginUser", user);
            session.setMaxInactiveInterval(3600); // 0으로 되어있으면 403 납니다!
            System.out.println(">>> 로그인 성공! 세션 저장 완료: " + user.getUId() + " (권한: " + user.getuAuth() + ")");
        }

        // 4. 메인 페이지로 이동
        response.sendRedirect("/");
    }
}