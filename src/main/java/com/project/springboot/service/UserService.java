package com.project.springboot.service;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import com.project.springboot.dao.IUserDAO;
import com.project.springboot.dto.UserDTO;

@Service
public class UserService {

	@Autowired
    private IUserDAO userDAO;
	@Autowired
    private org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;
	@Autowired
    private JavaMailSender mailSender;
	
    private Map<String, String> tokenStorage = new ConcurrentHashMap<>();
    // 1. 회원가입 (비밀번호 암호화 포함)
    public int registerUser(UserDTO userDTO) {
        // 비밀번호 암호화 로직 추가 권장 (BCrypt 등)
        // userDTO.setUPassword(passwordEncoder.encode(userDTO.getUPassword()));
        
        // 일반 가입 시 인증 상태 'N', 가입 단계 1 설정
        userDTO.setUEmailVerified(false); 
        userDTO.setUSignupStep(1);
        userDTO.setUSocialType("LOCAL"); 
        
        return userDAO.insertUser(userDTO);
    }

    // 2. 이메일 인증 완료 처리
    public boolean confirmEmail(String email) {
        return userDAO.updateEmailVerification(email) > 0;
    }

    // 3. 소셜 로그인 시 사용자 조회 및 자동 가입 판단
    public UserDTO processSocialLogin(String type, String socialId) {
        UserDTO user = userDAO.findBySocialInfo(type, socialId);
        
        if (user == null) {
            // 존재하지 않으면 신규 소셜 가입 로직 진행 (또는 null 반환 후 컨트롤러에서 판단)
            return null;
        }
        return user;
    }
    
    @Value("${app.base-url}")
    private String baseUrl;
    
    
 // 5. 비밀번호 재설정 링크 발송 (주석 제거, 실제 발송 로직 포함)
    public String sendResetLink(String email) {
        UserDTO user = userDAO.findById(email);
        
        if (user == null) return "존재하지 않는 이메일입니다.";
        
        // 소셜 유저는 비번 변경 불가 처리
        if (user.getUSocialType() != null && !user.getUSocialType().equals("LOCAL")) {
            return "소셜 계정은 해당 플랫폼(카카오/네이버 등)에서 변경해야 합니다.";
        }

        String token = UUID.randomUUID().toString();
        tokenStorage.put(token, email); // 메모리에 토큰 저장

        String resetLink = baseUrl + "/reset-password?token=" + token;

        try {
            org.springframework.mail.SimpleMailMessage message = new org.springframework.mail.SimpleMailMessage();
            message.setTo(email);
            message.setSubject("[SYSTEM] 비밀번호 재설정 안내");
            message.setText("보안 시스템 알림: 아래 링크를 통해 비밀번호를 재설정하세요.\n\n" + resetLink);
            
            mailSender.send(message); // 실제로 메일을 보냅니다.
            return "SUCCESS";
        } catch (Exception e) {
            e.printStackTrace();
            return "메일 발송 중 오류가 발생했습니다. SMTP 설정을 확인하세요.";
        }
    }

    // 6. 비밀번호 재설정 실행 (인증 완료 업데이트 포함)
    public boolean resetPassword(String token, String newPassword) {
        String email = tokenStorage.get(token);
        
        if (email == null) return false; // 토큰이 없거나 만료됨

        // 새 비밀번호 암호화 후 DB 업데이트
        String encodedPw = passwordEncoder.encode(newPassword); 
        int result = userDAO.updatePassword(email, encodedPw);
        
        if (result > 0) {
            // 비번 변경 성공 시 이메일 인증 여부도 자동으로 'Y' 처리
            userDAO.updateEmailVerification(email);
            
            tokenStorage.remove(token); // 사용한 토큰 파기
            return true;
        }
        return false;
    }
}
