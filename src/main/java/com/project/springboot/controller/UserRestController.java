package com.project.springboot.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.project.springboot.dao.IUserDAO;
import com.project.springboot.dto.UserDTO;

import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/user") 
public class UserRestController {

    @Autowired
    private IUserDAO userDAO;

    /**
     * 1. 일반 회원가입 (이메일 아이디 사용)
     */
    @PostMapping("/guest/signup/step1")
    public ResponseEntity<?> signUp(@RequestBody UserDTO userDTO, HttpSession session) { // HttpSession 추가
        if (userDAO.findById(userDTO.getUId()) != null) {
            return ResponseEntity.badRequest().body("이미 사용 중인 이메일입니다.");
        }
        
        // 1. 임의 닉네임 부여
        String tempNick = "USER_" + (System.currentTimeMillis() % 10000);
        userDTO.setUNick(tempNick);
        
        userDTO.setUSignupStep(1); 
        userDTO.setUSocialType("LOCAL");
        userDTO.setUEmailVerified(true); 
        
        int result = userDAO.insertUser(userDTO);
        
        if (result > 0) {
            // 2. 가입 직후 세션에 유저 정보 저장 (자동 로그인 효과)
            // password 등 민감 정보가 포함된 userDTO를 다시 조회해서 넣는 것이 안전합니다.
            UserDTO loginUser = userDAO.findById(userDTO.getUId());
            session.setAttribute("loginUser", loginUser);
            
            String nextUrl = "/signup/step2?email=" + userDTO.getUId();
            return ResponseEntity.ok(nextUrl);
        }
        return ResponseEntity.internalServerError().body("가입 처리 중 오류가 발생했습니다.");
    }

    /**
     * 2. 이메일 인증 처리 (이름 명시 추가)
     */
    @GetMapping("/verify-email")
    public ResponseEntity<String> verifyEmail(@RequestParam("email") String email) {
        int result = userDAO.updateEmailVerification(email);
        if (result > 0) return ResponseEntity.ok("이메일 인증 완료");
        return ResponseEntity.badRequest().body("인증 실패");
    }

    /**
     * 3. 닉네임 중복 체크 (이름 명시 추가)
     */
    @GetMapping("/guest/check-nick")
    public ResponseEntity<Boolean> checkNick(@RequestParam("uNick") String uNick) {
        int count = userDAO.countByNick(uNick);
        return ResponseEntity.ok(count == 0);
    }

    @PutMapping("/guest/signup/step2")
    public ResponseEntity<?> signUpStep2(@RequestBody UserDTO userDTO, HttpSession session) {
        // 1. 현재 DB에 저장된 원본 데이터를 가져옵니다.
        UserDTO existingUser = userDAO.findById(userDTO.getUId());
        
        if (existingUser != null) {
            // 2. 클라이언트에서 보낸 값이 비어있다면(null or ""), 기존 DB 값을 그대로 유지합니다.
            if (userDTO.getUNick() == null || userDTO.getUNick().trim().isEmpty()) {
                userDTO.setUNick(existingUser.getUNick());
            }
            // 다른 필드들도 선택 사항이라면 동일하게 처리 가능
        }

        // 3. 업데이트 실행
        int result = userDAO.updateUserStep2(userDTO);

        if (result > 0) {
            // 4. 최신 정보를 다시 세션에 저장
            UserDTO updatedUser = userDAO.findById(userDTO.getUId());
            session.setAttribute("loginUser", updatedUser);
            return ResponseEntity.ok("가입 완료");
        }
        return ResponseEntity.badRequest().body("업데이트 실패");
    }
    
    /**
     * 4. 로그인
     */
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginData, HttpSession session) {
        UserDTO user = userDAO.findById(loginData.get("uId"));
        if (user == null) return ResponseEntity.status(401).body("존재하지 않는 계정입니다.");
        if (!user.isUEmailVerified()) return ResponseEntity.status(403).body("이메일 인증 미완료");

        if (user.getUPassword().equals(loginData.get("uPassword"))) {
            session.setAttribute("loginUser", user);
            return ResponseEntity.ok(user); 
        }
        
        return ResponseEntity.status(401).body("비밀번호 불일치");
    }

   

    /**
     * 6. 비밀번호 변경 (이름 명시 완료)
     */
    @PostMapping("/update-pw")
    public ResponseEntity<?> updatePassword(
            @RequestParam("currentPw") String currentPw,
            @RequestParam("newPw") String newPw,
            HttpSession session) {

        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) return ResponseEntity.status(401).body("로그인 필요");

        if (!loginUser.getUPassword().equals(currentPw)) {
            return ResponseEntity.badRequest().body("현재 비밀번호가 틀립니다.");
        }

        int result = userDAO.updatePassword(loginUser.getUId(), newPw);
        if (result > 0) {
            loginUser.setUPassword(newPw);
            session.setAttribute("loginUser", loginUser);
            return ResponseEntity.ok("비밀번호 변경 성공");
        }
        return ResponseEntity.internalServerError().body("변경 실패");
    }

    /**
     * 7. 회원 탈퇴
     */
    @GetMapping("/withdraw")
    public ResponseEntity<?> withdraw(HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) return ResponseEntity.status(401).body("로그인 필요");

        int result = userDAO.deleteUser(loginUser.getUId());
        if (result > 0) {
            session.invalidate();
            return ResponseEntity.ok("탈퇴 완료");
        }
        return ResponseEntity.internalServerError().body("탈퇴 실패");
    }
    
   
}