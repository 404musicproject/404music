package com.project.springboot.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class UserDTO {
    private int uNo;
    @JsonProperty("uId") // JSON의 "uId"를 이 필드에 강제로 넣음
    private String uId;            // 이메일 주소 (로그인 ID로 사용)
    @JsonProperty("uPassword")
    private String uPassword;      // 비밀번호
    @JsonProperty("uNick")      
    private String uNick;           // 닉네임
    
    @JsonProperty("uGender")   
    private String uGender;         // 성별
    
    @JsonProperty("uBirth")    
    private java.time.LocalDate uBirth;      // 생년월일
    
    private String uTel;            // 전화번호
    private Integer uSignupStep;    // 가입 단계
    private String uSocialType;     // 소셜 로그인 구분 (LOCAL, KAKAO, NAVER, GOOGLE)
    private String uSocialId;       // 소셜 제공 고유 ID
    @JsonProperty("uRegion")
    private String uRegion;       // 지역
    
    @JsonProperty("uPreferredGenre")
    private String uPreferredGenre; // 선호 장르
    private LocalDateTime uCreateAt; 
    private String uAuth;           // 권한 (ROLE_USER 등)
    private boolean uEmailVerified; // 이메일 인증 여부 (2026 표준: boolean 처리)
    private String uProfileImg = "/img/default-profile.png";
    
 // JSP EL (${loginUser.uProfileImg})이 확실하게 인식할 수 있도록 수동 Getter 추가
    public String getUProfileImg() {
        return uProfileImg;
    }

    public int getUNo() {
        return uNo;
    }

    // 2. JSP EL용 (PropertyNotFoundException 해결사)
    // JSP의 ${loginUser.uNo}가 찾는 소문자 버전입니다.
    public int getuNo() {
        return uNo;
    }

    // 3. 닉네임도 마찬가지로 두 버전 모두 제공
    public String getUNick() {
        return uNick;
    }
    public String getuNick() {
        return uNick;
    }
 // UserDTO.java 안에 추가
    public String getuAuth() {
        return uAuth;
    }
    public String getUAuth() {
        return uAuth;
    }

    // JSP EL (${loginUser.uauth})이 소문자로 접근할 때를 대비
    public String getUauth() {
        return uAuth;
    }
}

