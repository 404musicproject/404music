package com.project.springboot.controller;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.project.springboot.dao.IUserDAO;
import com.project.springboot.dto.UserDTO;

import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/user") 
public class UserRestController {

    @Autowired private IUserDAO userDAO;
    private final String UPLOAD_DIR = "C:/404Music_Uploads/"; // WebConfig와 동일 경로

    @Autowired private PasswordEncoder passwordEncoder;
    
    @PostMapping("/guest/signup/step1")
    public ResponseEntity<?> signUp(@RequestBody UserDTO userDTO, HttpSession session) {
        if (userDAO.findById(userDTO.getUId()) != null) return ResponseEntity.badRequest().body("이미 사용 중인 이메일");
        
        // 비밀번호 암호화
        userDTO.setUPassword(passwordEncoder.encode(userDTO.getUPassword()));
        userDTO.setUNick("USER_" + (System.currentTimeMillis() % 10000));
        userDTO.setUSignupStep(1); 
        userDTO.setUSocialType("LOCAL"); 
        userDTO.setUEmailVerified(true); 

        if (userDAO.insertUser(userDTO) > 0) {
            session.setAttribute("loginUser", userDAO.findById(userDTO.getUId()));
            return ResponseEntity.ok("/signup/step2?email=" + userDTO.getUId());
        }
        return ResponseEntity.internalServerError().body("가입 오류");
    }

    @GetMapping("/verify-email")
    public ResponseEntity<String> verifyEmail(@RequestParam("email") String email) {
        return userDAO.updateEmailVerification(email) > 0 ? ResponseEntity.ok("인증 완료") : ResponseEntity.badRequest().body("인증 실패");
    }

    @GetMapping("/guest/check-nick")
    public ResponseEntity<Boolean> checkNick(@RequestParam("uNick") String uNick) {
        return ResponseEntity.ok(userDAO.countByNick(uNick) == 0);
    }

    @PutMapping("/guest/signup/step2")
    public ResponseEntity<?> signUpStep2(@RequestBody UserDTO userDTO, HttpSession session) {
        UserDTO existing = userDAO.findById(userDTO.getUId());
        if (existing != null && (userDTO.getUNick() == null || userDTO.getUNick().trim().isEmpty())) {
            userDTO.setUNick(existing.getUNick());
        }
        if (userDAO.updateUserStep2(userDTO) > 0) {
            session.setAttribute("loginUser", userDAO.findById(userDTO.getUId()));
            return ResponseEntity.ok("가입 완료");
        }
        return ResponseEntity.badRequest().body("업데이트 실패");
    }

    // Step 3 & 프로필 수정 공통 업로드
    @PostMapping("/guest/signup/step3") 
    public ResponseEntity<?> uploadProfileSignup(@RequestParam("profileFile") MultipartFile file, @RequestParam("uId") String uId, HttpSession session) {
        return processProfileUpload(file, uId, session);
    }

    @PostMapping("/update/profile") 
    public ResponseEntity<?> updateProfileImage(@RequestParam("profileFile") MultipartFile file, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) return ResponseEntity.status(401).body("로그인 필요");
        return processProfileUpload(file, loginUser.getUId(), session);
    }

    private ResponseEntity<?> processProfileUpload(MultipartFile file, String uId, HttpSession session) {
        if (file.isEmpty()) return ResponseEntity.ok("skip");
        try {
            File dir = new File(UPLOAD_DIR);
            if (!dir.exists()) dir.mkdirs();
            String savedFileName = UUID.randomUUID() + "_" + file.getOriginalFilename();
            Path path = Paths.get(UPLOAD_DIR + savedFileName);
            Files.write(path, file.getBytes());
            String webPath = "/images/profile/" + savedFileName;
            userDAO.updateProfileImage(uId, webPath);
            UserDTO user = userDAO.findById(uId);
            if (user != null) session.setAttribute("loginUser", user);
            return ResponseEntity.ok(webPath);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("업로드 실패");
        }
    }
    
 // 2. 로그인 - 암호화 매칭 체크
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginData, HttpSession session) {
        UserDTO user = userDAO.findById(loginData.get("uId"));
        
        if (user == null || !passwordEncoder.matches(loginData.get("uPassword"), user.getUPassword())) {
            return ResponseEntity.status(401).body("로그인 실패");
        }
        
        // 1. 인증 토큰 생성 (ROLE_USER 권한 부여)
        Authentication auth = new UsernamePasswordAuthenticationToken(
            user.getUId(), null, AuthorityUtils.createAuthorityList("ROLE_USER"));
        
        // 2. 컨텍스트 생성 및 저장
        SecurityContext context = SecurityContextHolder.createEmptyContext();
        context.setAuthentication(auth);
        SecurityContextHolder.setContext(context);
        
        // 3. [핵심] 스프링 시큐리티 전용 세션 저장소에 명시적으로 저장
        session.setAttribute(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY, context);
        session.setAttribute("loginUser", user); // Header.jsp용

        return ResponseEntity.ok(user);
    }
    
    
 // 3. 비밀번호 변경 - 기존 비번 체크 및 새 비번 암호화
    @PostMapping("/update-pw")
    public ResponseEntity<?> updatePassword(@RequestParam("currentPw") String currentPw, @RequestParam("newPw") String newPw, HttpSession session) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        
        // 기존 비밀번호가 맞는지 암호화 매칭 확인
        if (user == null || !passwordEncoder.matches(currentPw, user.getUPassword())) {
            return ResponseEntity.badRequest().body("기존 비밀번호가 일치하지 않습니다.");
        }
        
        // 새 비밀번호 암호화
        String encodedNewPw = passwordEncoder.encode(newPw);
        if (userDAO.updatePassword(user.getUId(), encodedNewPw) > 0) {
            user.setUPassword(encodedNewPw); // 세션 정보 갱신
            session.setAttribute("loginUser", user); 
            return ResponseEntity.ok("성공");
        }
        return ResponseEntity.internalServerError().body("실패");
    }
    
    @GetMapping("/withdraw")
    public ResponseEntity<?> withdraw(HttpSession session) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        if (user == null) return ResponseEntity.status(401).body("로그인 필요");
        userDAO.deleteUser(user.getUId());
        session.invalidate();
        SecurityContextHolder.clearContext(); // 시큐리티 컨텍스트도 비워줌
        return ResponseEntity.ok("탈퇴 완료");
    }
}
