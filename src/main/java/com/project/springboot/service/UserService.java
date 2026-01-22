package com.project.springboot.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.project.springboot.dao.IUserDAO;
import com.project.springboot.dto.UserDTO;

@Service
public class UserService {

	@Autowired
    private IUserDAO userDAO;

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
}
