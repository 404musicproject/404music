package com.project.springboot.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpSession;

@Controller
public class UserViewController {

	@GetMapping("/")
	public String root() {
		return "/Home";
	}
	
	  @GetMapping("/signup")
	    public String showSignupForm() {
	        return "guest/SignupFormStep1"; // JSP 파일 경로를 반환
	    }
	  
	  @GetMapping("/signup/step2")
	  public String step2Page(@RequestParam String email, Model model) {
	      model.addAttribute("email", email);
	      return "guest/SignupFormStep2"; // WEB-INF/views/signup/step2.jsp 를 찾아감
	  }
	  
	  // UserRestController.java 또는 별도의 Controller 클래스
	    @GetMapping("/logout")
	    public String logout(jakarta.servlet.http.HttpSession session) {
	        if (session != null) {
	            session.invalidate(); // 1. 세션 무효화 (모든 로그인 정보 삭제)
	        }
	        return "redirect:/"; // 2. 로그아웃 후 메인 페이지로 이동
	    }
	    
	    @GetMapping("/mypage")
	    public String myPage(HttpSession session) {
	        // 로그인이 안 된 사용자는 로그인 페이지(또는 메인)로 보냄
	        if (session.getAttribute("loginUser") == null) {
	            return "redirect:/"; 
	        }
	        return "/user/MyPage"; // mypage.jsp를 호출
	    }
}
