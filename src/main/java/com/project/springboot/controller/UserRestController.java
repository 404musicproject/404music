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
    public ResponseEntity<?> signUp(@RequestBody UserDTO userDTO) {
        if (userDAO.findById(userDTO.getUId()) != null) {
            return ResponseEntity.badRequest().body("이미 사용 중인 이메일입니다.");
        }
        userDTO.setUSignupStep(1); 
        userDTO.setUSocialType("LOCAL");
        userDTO.setUEmailVerified(true); 
        int result = userDAO.insertUser(userDTO);
        if (result > 0) {
            String nextUrl = "/signup/step2?email=" + userDTO.getUId();
            return ResponseEntity.ok(nextUrl);
        }
        return ResponseEntity.internalServerError().body("가입 처리 중 오류가 발생했습니다.");
    }
    
    @PutMapping("/guest/signup/step2")
    public ResponseEntity<?> signUpStep2(@RequestBody UserDTO userDTO, jakarta.servlet.http.HttpSession session) {
        // 기존 사용자를 찾아 닉네임, 성별, 생년월일, 지역 등을 업데이트
        int result = userDAO.updateUserStep2(userDTO);

        if (result > 0) {
            // 💡 중요: DB 업데이트 후 최신 정보를 다시 읽어와서 세션에 담아줘야 합니다.
            UserDTO updatedUser = userDAO.findById(userDTO.getUId());
            if (updatedUser != null) {
                session.setAttribute("loginUser", updatedUser);
            }
            return ResponseEntity.ok("가입 완료 및 로그인 처리 완료");
        }
        return ResponseEntity.badRequest().body("사용자를 찾을 수 없거나 업데이트 실패");
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
     * 5. 프로필 업데이트 (AJAX 대응을 위해 @RequestBody 또는 @RequestParam 이름 명시)
     */
    @PostMapping("/update")
    // 반환 타입을 ResponseEntity<?> 에서 String 으로 변경합니다.
    public String updateProfile(@RequestParam Map<String, String> params, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            // 로그인이 필요한 경우 로그인 페이지로 리다이렉트
            return "redirect:/"; 
        }

        // 세션 객체 업데이트 (데이터 유실 방지를 위해 DTO에 다시 담습니다)
        loginUser.setUNick(params.get("uNick"));
        loginUser.setURegion(params.get("uRegion"));
        loginUser.setUGender(params.get("uGender"));
        loginUser.setUPreferredGenre(params.get("uPreferredGenre"));

        // DB 업데이트 수행
        int result = userDAO.updateUserStep2(loginUser); 
        
        if (result > 0) {
            // DB 업데이트 성공 시 세션 갱신
            session.setAttribute("loginUser", loginUser);
            
            // 성공 후 마이페이지로 이동 (서버 측 리다이렉트)
            return "redirect:/mypage";
        }
        
        // 업데이트 실패 시 에러 페이지 또는 메시지 반환
        // 여기서는 간단히 마이페이지로 돌려보내거나 에러 처리 로직 추가
        return "redirect:/mypage?error=updateFailed";
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