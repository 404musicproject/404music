package com.project.springboot.controller;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
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
    @Autowired private com.project.springboot.service.UserService userService;
    @PostMapping("/guest/signup/step1")
    public ResponseEntity<?> signUp(UserDTO userDTO, HttpSession session) {
        if (userDAO.findById(userDTO.getUId()) != null) return ResponseEntity.badRequest().body("이미 사용 중인 이메일");
        
        // 비밀번호 암호화
        userDTO.setUPassword(passwordEncoder.encode(userDTO.getUPassword()));
        userDTO.setUNick("USER_" + (System.currentTimeMillis() % 10000));
        userDTO.setUSignupStep(1); 
        userDTO.setUSocialType("LOCAL"); 
        userDTO.setUEmailVerified(true); 

        if (userDAO.insertUser(userDTO) > 0) {
            session.setAttribute("loginUser", userDAO.findById(userDTO.getUId()));

            // ✅ Spring Security 인증도 같이 세팅 (회원가입 직후 /user/** 접근 가능하게)
            Authentication auth = new UsernamePasswordAuthenticationToken(
                userDTO.getUId(), null, AuthorityUtils.createAuthorityList("ROLE_USER"));
            SecurityContext context = SecurityContextHolder.createEmptyContext();
            context.setAuthentication(auth);
            SecurityContextHolder.setContext(context);
            session.setAttribute(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY, context);
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
    public ResponseEntity<?> signUpStep2(UserDTO userDTO, HttpSession session) {
        UserDTO existing = userDAO.findById(userDTO.getUId());
        if (existing != null && (userDTO.getUNick() == null || userDTO.getUNick().trim().isEmpty())) {
            userDTO.setUNick(existing.getUNick());
        }

        if (userDAO.updateUserStep2(userDTO) > 0) {
            // 1. 최신 유저 정보 다시 불러오기
            UserDTO updatedUser = userDAO.findById(userDTO.getUId());
            session.setAttribute("loginUser", updatedUser);

            // 2. Spring Security 인증 정보 갱신
            // 기존에 권한이 없거나 익명 사용자인 경우 실제 권한을 심어줍니다.
            if (SecurityContextHolder.getContext().getAuthentication() == null || 
                SecurityContextHolder.getContext().getAuthentication().getPrincipal().equals("anonymousUser")) {
                
                // ✅ 'user' 대신 위에서 조회한 'updatedUser'를 사용해야 합니다.
                Authentication auth = new UsernamePasswordAuthenticationToken(
                    updatedUser.getUId(), 
                    null, 
                    AuthorityUtils.createAuthorityList(updatedUser.getuAuth()) // DB의 권한을 그대로 주입!
                );
                
                SecurityContext context = SecurityContextHolder.createEmptyContext();
                context.setAuthentication(auth);
                SecurityContextHolder.setContext(context);
                
                // 세션에 시큐리티 컨텍스트 저장
                session.setAttribute(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY, context);
            }

            return ResponseEntity.ok("가입 완료");
        }
        return ResponseEntity.badRequest().body("업데이트 실패");
    }

    // Step 3 & 프로필 수정 공통 업로드
    @PostMapping("/guest/signup/step3") 
    public ResponseEntity<?> uploadProfileSignup(
            @RequestParam(value="profileFile", required=false) MultipartFile file,
            @RequestParam(value="profilePreset", required=false) String profilePreset,
            @RequestParam("uId") String uId,
            HttpSession session) {

        // ✅ 1) 프리셋 선택이 우선 (파일 업로드 없이도 저장 가능)
        if (profilePreset != null && !profilePreset.trim().isEmpty()) {
            String preset = profilePreset.trim();

            // ✅ 간단 화이트리스트: profile01.png ~ profile08.png 만 허용
            if (!preset.matches("^profile0[1-8]\\.png$")) {
                return ResponseEntity.badRequest().body("잘못된 프리셋 파일명");
            }

            String webPath = "/img/Profile/" + preset;
            userDAO.updateProfileImage(uId, webPath);

            UserDTO user = userDAO.findById(uId);
            if (user != null) session.setAttribute("loginUser", user);

            // ✅ 혹시 인증 컨텍스트가 없으면 생성(회원가입 흐름에서 로그인처럼 동작)
         // uploadProfileSignup 메서드 내부
            if (SecurityContextHolder.getContext().getAuthentication() == null) {
                // ✅ 수정: "ROLE_USER" -> user.getuAuth() 로 변경
                Authentication auth = new UsernamePasswordAuthenticationToken(
                    uId, null, AuthorityUtils.createAuthorityList(user.getuAuth())); 
                SecurityContext context = SecurityContextHolder.createEmptyContext();
                context.setAuthentication(auth);
                SecurityContextHolder.setContext(context);
                session.setAttribute(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY, context);
            }
            return ResponseEntity.ok(webPath);
        }

        // ✅ 2) 프리셋이 없으면 기존 파일 업로드 로직 유지
        return processProfileUpload(file, uId, session);
    }

@PostMapping("/update/profile") 
    public ResponseEntity<?> updateProfileImage(@RequestParam("profileFile") MultipartFile file, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) return ResponseEntity.status(401).body("로그인 필요");
        return processProfileUpload(file, loginUser.getUId(), session);
    }

    private ResponseEntity<?> processProfileUpload(MultipartFile file, String uId, HttpSession session) {
        // ✅ 파일이 아예 안 왔거나(프론트가 preset만 보낼 때) 비어있으면 스킵
        if (file == null || file.isEmpty()) return ResponseEntity.ok("skip");

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
 // 2. 로그인 메서드를 아래와 같이 수정하세요
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginData, HttpSession session) {
        UserDTO user = userDAO.findById(loginData.get("uId"));
        
        if (user == null || !passwordEncoder.matches(loginData.get("uPassword"), user.getUPassword())) {
            return ResponseEntity.status(401).body("로그인 실패");
        }
        
        // ✅ 수정: "ROLE_USER" -> user.getuAuth() 로 변경
        Authentication auth = new UsernamePasswordAuthenticationToken(
            user.getUId(), null, AuthorityUtils.createAuthorityList(user.getuAuth())); 
        
        SecurityContext context = SecurityContextHolder.createEmptyContext();
        context.setAuthentication(auth);
        SecurityContextHolder.setContext(context);
        
        session.setAttribute(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY, context);
        session.setAttribute("loginUser", user);

        Map<String, String> response = new HashMap<>();
        response.put("result", "success");
        response.put("userName", user.getUNick());
        
        return ResponseEntity.ok(response); 
    }
    
    
 // 3. 비밀번호 변경 - 기존 비번 체크 및 새 비번 암호화
    @PostMapping("/update-password") // JSP의 ajax url과 동일하게 맞춤
    public ResponseEntity<?> updatePassword(@RequestParam("currentPw") String currentPw, 
                                            @RequestParam("newPw") String newPw, 
                                            HttpSession session) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        
        if (user == null) return ResponseEntity.status(401).body("session_expired");

        // 1. 기존 비밀번호 확인
        if (!passwordEncoder.matches(currentPw, user.getUPassword())) {
            return ResponseEntity.ok("wrong_password"); // 'wrong_password'라는 문자열 전송
        }
        
        // 2. 새 비밀번호 암호화 및 저장
        String encodedNewPw = passwordEncoder.encode(newPw);
        if (userDAO.updatePassword(user.getUId(), encodedNewPw) > 0) {
            user.setUPassword(encodedNewPw); 
            session.setAttribute("loginUser", user); 
            return ResponseEntity.ok("success"); // 'success'라는 문자열 전송
        }
        
        return ResponseEntity.ok("fail");
    }
    
    @GetMapping("/withdraw")
    public ResponseEntity<?> withdraw(HttpSession session) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        if (user == null) return ResponseEntity.status(401).body("로그인 필요");

        try {
            // 1. 자식 데이터들을 GUEST(0번)로 이전 (에러 방지 핵심!)
            userDAO.transferToGuest(user.getUId());

            // 2. 이제 실제 유저 테이블에서 삭제 (자식이 없으므로 에러 안 남)
            userDAO.deleteUser(user.getUId());

            // 3. 세션 및 시큐리티 정보 초기화
            session.invalidate();
            SecurityContextHolder.clearContext();

            return ResponseEntity.ok("탈퇴 완료");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("탈퇴 처리 중 오류가 발생했습니다.");
        }
    }
 // 1. 이메일로 재설정 링크 발송
    @PostMapping("/find-password")
    public ResponseEntity<String> processFindPassword(@RequestBody Map<String, String> payload) {
        String email = payload.get("email");
        String result = userService.sendResetLink(email); // 서비스 호출

        if ("SUCCESS".equals(result)) {
            return ResponseEntity.ok("이메일로 재설정 링크를 발송했습니다.");
        } else {
            return ResponseEntity.status(400).body(result);
        }
    }

    // 2. 실제 비밀번호 변경 처리
    @PostMapping("/reset-password")
    public ResponseEntity<String> handleResetPassword(@RequestBody Map<String, String> params) {
        String token = params.get("token");
        String newPw = params.get("password");
        
        boolean success = userService.resetPassword(token, newPw); // 서비스 호출
        if (success) {
            return ResponseEntity.ok("비밀번호가 성공적으로 변경되었습니다.");
        } else {
            return ResponseEntity.status(400).body("토큰이 만료되었거나 유효하지 않습니다.");
        }
    }
}
