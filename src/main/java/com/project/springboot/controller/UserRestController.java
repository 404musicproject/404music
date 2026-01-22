package com.project.springboot.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.project.springboot.dao.IUserDAO;
import com.project.springboot.dto.UserDTO;

@Controller
@RequestMapping("/api/user") 
public class UserRestController {

	@Autowired
    private IUserDAO userDAO;

    /**
     * 1. 일반 회원가입 (이메일 아이디 사용)
     */
    @PostMapping("/guest/signup/step1")
    public ResponseEntity<?> signUp(@RequestBody UserDTO userDTO) {
        // 중복 체크
        if (userDAO.findById(userDTO.getUId()) != null) {
            return ResponseEntity.badRequest().body("이미 사용 중인 이메일입니다.");
        }
        
        // 초기 설정: 1단계 완료, LOCAL 타입
        userDTO.setUSignupStep(1); 
        userDTO.setUSocialType("LOCAL");
        userDTO.setUEmailVerified(true); 

        int result = userDAO.insertUser(userDTO);
        
        if (result > 0) {
            // 성공 시 다음 단계 URL과 이메일 정보를 반환 (JSON 형태로)
            String nextUrl = "/signup/step2?email=" + userDTO.getUId();
            return ResponseEntity.ok(nextUrl); // 응답 바디에 다음 URL 문자열 반환
        }
        return ResponseEntity.internalServerError().body("가입 처리 중 오류가 발생했습니다.");
    }

    /**
     * 2. 이메일 인증 처리 (이메일 링크 클릭 시 호출)
     * 예: http://localhost:8080/api/user/verify-email?email=test@example.com
     */
    @GetMapping("/verify-email")
    public ResponseEntity<String> verifyEmail(@RequestParam("email") String email) {
        int result = userDAO.updateEmailVerification(email);
        if (result > 0) {
            return ResponseEntity.ok("이메일 인증이 성공적으로 완료되었습니다.");
        }
        return ResponseEntity.badRequest().body("유효하지 않은 인증 요청입니다.");
    }

    /**
     * 3. 소셜 로그인 확인
     */
    @PostMapping("/social-login")
    public ResponseEntity<?> socialLogin(@RequestBody Map<String, String> payload) {
        String type = payload.get("uSocialType"); // KAKAO, NAVER, GOOGLE
        String socialId = payload.get("uSocialId");

        UserDTO user = userDAO.findBySocialInfo(type, socialId);

        if (user != null) {
            // 이미 가입된 소셜 사용자
            return ResponseEntity.ok(user);
        } else {
            // 신규 소셜 사용자 -> 추가 정보 입력을 위한 202 Accepted 응답
            return ResponseEntity.status(202).body("신규 소셜 회원입니다. 추가 정보를 입력해주세요.");
        }
    }

    
    @PutMapping("/guest/signup/step2")
    public ResponseEntity<?> signUpStep2(@RequestBody UserDTO userDTO) {
        // 기존 사용자를 찾아 닉네임, 성별, 생년월일, 지역 등을 업데이트
        int result = userDAO.updateUserStep2(userDTO);

        if (result > 0) {
            return ResponseEntity.ok("2단계 정보 업데이트 성공");
        }
        return ResponseEntity.badRequest().body("사용자를 찾을 수 없거나 업데이트 실패");
    }
    
    @GetMapping("/guest/check-nick")
    public ResponseEntity<Boolean> checkNick(@RequestParam("uNick") String uNick) {
        int count = userDAO.countByNick(uNick);
        // count가 0이면 true(사용가능), 1이상이면 false(중복)
        return ResponseEntity.ok(count == 0);
    }
    
    
    /**
     * 4. 로그인 (세션 저장 로직 추가)
     */
    @PostMapping("/login")
    // 1. 파라미터에 HttpSession session 추가
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginData, jakarta.servlet.http.HttpSession session) {
        UserDTO user = userDAO.findById(loginData.get("uId"));

        if (user == null) {
            return ResponseEntity.status(401).body("존재하지 않는 계정입니다.");
        }

        if (!user.isUEmailVerified()) {
            return ResponseEntity.status(403).body("이메일 인증이 완료되지 않았습니다.");
        }

        if (user.getUPassword().equals(loginData.get("uPassword"))) {
            // 2. 중요: 세션에 유저 정보 저장 (JSP에서 부르는 이름 'loginUser'와 일치시켜야 함)
            session.setAttribute("loginUser", user);
            
            return ResponseEntity.ok(user); 
        }

        return ResponseEntity.status(401).body("비밀번호가 일치하지 않습니다.");
    }
    

}
