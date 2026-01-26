package com.project.springboot.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.project.springboot.dao.IUserDAO;
import com.project.springboot.dto.UserDTO;

import jakarta.servlet.http.HttpSession;

@Controller
public class UserViewController {

	@Autowired
    private IUserDAO userDAO;
	
	@GetMapping("/")
	public String root() {
		return "/Home";
	}
	
	  @GetMapping("/signup")
	    public String showSignupForm() {
	        return "guest/SignupFormStep1"; // JSP 파일 경로를 반환
	    }
	  
	  @GetMapping("/signup/step2")
	  public String step2Page(@RequestParam("email") String email, Model model, HttpSession session) {
	      // 1. DB에서 이메일로 유저 정보를 다시 가져옴
	      UserDTO user = userDAO.findById(email);
	      
	      // 2. 만약 세션이 비어있다면 여기서 다시 한번 채워줌 (안전장치)
	      if (session.getAttribute("loginUser") == null) {
	          session.setAttribute("loginUser", user);
	      }
	      
	      model.addAttribute("email", email);
	      model.addAttribute("user", user); // 모델에 직접 담아서 JSP로 전달
	      
	      return "guest/SignupFormStep2";
	  }
	 
	  
	  // UserRestController.java 또는 별도의 Controller 클래스
	    @GetMapping("/logout")
	    public String logout(jakarta.servlet.http.HttpSession session) {
	        if (session != null) {
	            session.invalidate(); // 1. 세션 무효화 (모든 로그인 정보 삭제)
	        }
	        return "redirect:/"; // 2. 로그아웃 후 메인 페이지로 이동
	    }
	   
	 
	    
	    @PostMapping("/api/user/update")
	    public String updateProfile(@RequestParam Map<String, String> params, HttpSession session) {
	        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
	        
	        if (loginUser == null) {
	            return "redirect:/"; // 세션 만료 시 홈으로
	        }

	        // 1. 폼 데이터로 세션 객체 업데이트
	        loginUser.setUNick(params.get("uNick"));
	        loginUser.setURegion(params.get("uRegion"));
	        loginUser.setUGender(params.get("uGender"));
	        loginUser.setUPreferredGenre(params.get("uPreferredGenre"));

	        // 2. DB 업데이트 수행
	        int result = userDAO.updateUserStep2(loginUser); 
	        
	        if (result > 0) {
	            // 3. DB 성공 시 세션 최신화
	            session.setAttribute("loginUser", loginUser);
	            // 4. 마이페이지 뷰를 담당하는 컨트롤러 주소로 리다이렉트
	            return "redirect:/user/mypage"; 
	        }
	        
	        return "redirect:/mypage?error=updateFailed";
	    }
	    
	    @RequestMapping("user/subscription")
	    public String subscription() {
	    	return "/user/SubscriptionPlans";
	    }
	    
}
