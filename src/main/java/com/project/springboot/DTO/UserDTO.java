package com.project.springboot.DTO;

import java.time.LocalDate;
import java.time.LocalDateTime;

import lombok.Data;

@Data
public class UserDTO {
    private int uNo;
    private String uId;             // 이메일 주소 (로그인 ID로 사용)
    private String uPassword;       // 비밀번호
    private String uNick;           // 닉네임
    private String uGender;         // 성별
    private LocalDate uBirth;       // 생년월일
    private String uTel;            // 전화번호
    private Integer uSignupStep;    // 가입 단계
    private String uSocialType;     // 소셜 로그인 구분 (LOCAL, KAKAO, NAVER, GOOGLE)
    private String uSocialId;       // 소셜 제공 고유 ID
    private String uRegion;         // 지역
    private String uPreferredGenre; // 선호 장르
    private LocalDateTime uCreateAt; 
    private String uAuth;           // 권한 (ROLE_USER 등)
    private boolean uEmailVerified; // 이메일 인증 여부 (2026 표준: boolean 처리)
}

