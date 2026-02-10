package com.project.springboot.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.project.springboot.dao.IUserDAO;
import com.project.springboot.dto.UserDTO;

import jakarta.servlet.http.HttpSession;

@Controller
public class UserViewController {

    @Autowired
    private IUserDAO userDAO;

    @GetMapping("/signup")
    public String showSignupForm() {
        return "guest/SignupFormStep1"; 
    }
  
    @GetMapping("/signup/step2")
    public String step2Page(@RequestParam("email") String email, Model model, HttpSession session) {
        UserDTO user = userDAO.findById(email);
        
        if (session.getAttribute("loginUser") == null) {
            session.setAttribute("loginUser", user);
        }
        
        model.addAttribute("email", email);
        model.addAttribute("user", user);
        
        return "guest/SignupFormStep2";
    }
    
    // [추가됨] 3단계 페이지 연결
    @GetMapping("/signup/step3")
    public String step3Page(@RequestParam("uId") String uId, Model model) {
        model.addAttribute("uId", uId);
        return "guest/SignupFormStep3";
    }

    // ✅ 마이페이지에서 쓰는 '프로필 선택' 전용 페이지 (Step 문구/진행바 없이 별도 화면)
    @GetMapping("/user/profile")
    public String profileSelectPage(HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/home";
        return "user/ProfileSelect";
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        if (session != null) {
            session.invalidate(); // 1. 세션 무효화
        }
        // 2. Spring Security 인증 정보 삭제 (필수)
        SecurityContextHolder.clearContext(); 
        
        return "redirect:/home"; // 메인 화면으로 리다이렉트
    }
   
    @PostMapping("/api/user/update")
    public String updateProfile(@RequestParam Map<String, String> params, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/home";

        // 데이터 세팅
        loginUser.setUNick(params.get("uNick"));
        loginUser.setURegion(params.get("uRegion"));
        loginUser.setUGender(params.get("uGender"));
        loginUser.setUPreferredGenre(params.get("uPreferredGenre"));

        if (userDAO.updateUserStep2(loginUser) > 0) {
            // 1. JSP용 세션 갱신
            session.setAttribute("loginUser", loginUser);
            
            // 2. Spring Security 인증 정보 갱신 (핵심)
            // 이걸 안 하면 Header.jsp 등에서 시큐리티 Principal을 쓸 때 옛날 닉네임이 나옵니다.
            Authentication oldAuth = SecurityContextHolder.getContext().getAuthentication();
            Authentication newAuth = new UsernamePasswordAuthenticationToken(
                loginUser, // Principal을 DTO 객체로 교체
                oldAuth.getCredentials(), 
                oldAuth.getAuthorities()
            );
            SecurityContextHolder.getContext().setAuthentication(newAuth);
            
            return "redirect:/user/mypage"; 
        }
        return "redirect:/user/mypage?error=updateFailed";
    
}
    
    @RequestMapping("/user/subscription")
    public String subscription() {
        return "user/SubscriptionPlans";
    }
    
    @RequestMapping("/user/Kibana")
    public String Kibana() {
    	return "user/Kibana";
    }
 // 비밀번호 찾기 (이메일 입력창) 열기
    @GetMapping("/find-password")
    public String showFindPasswordForm() {
        return "common/Find-password"; // Find-password.jsp 열기
    }

    // 메일 링크 클릭 시 새 비밀번호 입력창 열기
    @GetMapping("/reset-password")
    public String resetPasswordPage(@RequestParam("token") String token, Model model) {
        model.addAttribute("token", token);
        return "common/reset-password-form"; // reset-password-form.jsp 열기
    }
  
}