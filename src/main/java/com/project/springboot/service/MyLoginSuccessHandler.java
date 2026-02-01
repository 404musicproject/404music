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
        
        // 1. 카카오에서 넘어온 principal(사용자 정보) 가져오기
        OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();
        String socialId = String.valueOf(oAuth2User.getAttribute("id"));
        
        // 2. DB에서 실제 유저 정보 조회
        UserDTO user = userDAO.findBySocialInfo("KAKAO", socialId);
        
        // 3. JSP에서 쓸 수 있도록 세션에 "loginUser"라는 이름으로 저장
        HttpSession session = request.getSession();
        session.setAttribute("loginUser", user);
        
        // 4. 메인 페이지로 이동
        response.sendRedirect("/");
    }
}