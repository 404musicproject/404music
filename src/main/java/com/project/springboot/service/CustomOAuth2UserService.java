package com.project.springboot.service;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.DefaultOAuth2User;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import com.project.springboot.dao.IUserDAO;
import com.project.springboot.dto.UserDTO;

import jakarta.servlet.http.HttpSession;

@Service
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    @Autowired
    private IUserDAO userDAO;
    
    @Autowired
    private HttpSession httpSession;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);
        Map<String, Object> attributes = oAuth2User.getAttributes();
        
        String registrationId = userRequest.getClientRegistration().getRegistrationId();
        String userNameAttributeName = userRequest.getClientRegistration()
                .getProviderDetails().getUserInfoEndpoint().getUserNameAttributeName();

        String socialId = "";
        String nickname = "";
        String email = "";

        if ("naver".equals(registrationId)) {
            Map<String, Object> response = (Map<String, Object>) attributes.get("response");
            socialId = String.valueOf(response.get("id"));
            nickname = (String) response.get("nickname");
            email = (String) response.get("email");
        } else if ("kakao".equals(registrationId)) {
            socialId = String.valueOf(attributes.get("id"));
            Map<String, Object> kakaoAccount = (Map<String, Object>) attributes.get("kakao_account");
            Map<String, Object> profile = (Map<String, Object>) kakaoAccount.get("profile");
            nickname = (String) profile.get("nickname");
            email = (String) kakaoAccount.get("email");
        } else if ("google".equals(registrationId)) {
            // 구글은 데이터가 최상위(attributes)에 바로 들어있음
            socialId = String.valueOf(attributes.get("sub")); // 구글의 유니크 ID는 'sub'
            nickname = (String) attributes.get("name");
            email = (String) attributes.get("email");
        }

        // DB 연동 및 세션 저장 (이전과 동일)
     // [수정된 로직]
     // 1. 소셜 타입 + 소셜 ID로 기존 가입 여부 확인
        UserDTO user = userDAO.findBySocialInfo(registrationId.toUpperCase(), socialId);

        if (user == null) {
            // 2. [중요] 소셜 정보는 없지만, 이미 해당 이메일(uId)로 가입된 유저가 있는지 한 번 더 확인
            // 탈퇴 후 u_id가 남아있거나, 일반 회원가입을 미리 한 경우 ORA-00001 방지용
            UserDTO existingEmailUser = userDAO.findById(email);
            
            if (existingEmailUser != null) {
                // 이메일이 이미 존재한다면 그 유저 정보를 그대로 사용 (로그인 처리)
                user = existingEmailUser;
                System.out.println(">>> 기존 이메일 유저로 로그인 진행: " + email);
            } else {
                // 3. 진짜 신규 유저일 때만 INSERT 실행
                user = new UserDTO();
                String prefix = registrationId.substring(0, 1).toUpperCase() + "_"; 
                user.setUId(email != null ? email : prefix + socialId); 
                user.setUNick(nickname);
                user.setUPassword("OAUTH_USER");
                user.setUSocialType(registrationId.toUpperCase());
                user.setUSocialId(socialId);
                user.setUAuth("ROLE_USER");
                user.setUSignupStep(1);
                user.setUEmailVerified(true);
                user.setUCreateAt(LocalDateTime.now());
                
                userDAO.insertUser(user);
                System.out.println(">>> 신규 소셜 회원가입 완료: " + user.getUId());
            }
        }
        
        httpSession.setAttribute("loginUser", user); 

        return new DefaultOAuth2User(
            Collections.singleton(new SimpleGrantedAuthority(user.getuAuth())), 
            attributes,
            userNameAttributeName
        );
    }
}