package com.project.springboot.auth;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

import jakarta.servlet.http.HttpSession;

@Configuration
@EnableWebSecurity
public class WebSecurtyConfig {
	
	@Autowired
    private com.project.springboot.service.CustomOAuth2UserService customOAuth2UserService;
	
	@Bean
	public PasswordEncoder passwordEncoder() {
	    return new org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder();
	}

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.disable())
            .sessionManagement(session -> session
                    .sessionFixation().migrateSession() // 세션 고정 보호 강화
                    //.sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED) // 필요시 세션 생성
                    .sessionCreationPolicy(SessionCreationPolicy.ALWAYS)
                )
            .authorizeHttpRequests(auth -> auth
            	    // 패키지 경로를 통째로 적어서 타입을 강제합니다.
            	    .dispatcherTypeMatchers(jakarta.servlet.DispatcherType.FORWARD).permitAll()
            	    .dispatcherTypeMatchers(jakarta.servlet.DispatcherType.INCLUDE).permitAll()
            	    .dispatcherTypeMatchers(jakarta.servlet.DispatcherType.ERROR).permitAll()
                .requestMatchers("/login/oauth2/**", "/oauth2/**").permitAll() 
                .requestMatchers("/signup/**", "/api/user/guest/**", "/api/user/login", "/api/auth/**", "/verify-email").permitAll()
                .requestMatchers("/", "/home","/common/**", "/guest/**","/api/music/**","/support/**","/music/**", "/artist/**", "/album/**").permitAll()
                // ✅ 검색 결과 페이지 경로 추가
                .requestMatchers("/musicSearch").permitAll() 
                .requestMatchers("/api/chat/**").permitAll()
                .requestMatchers("/css/**", "/js/**", "/img/**", "/img/Location/**", "/img/Tag/**", "/favicon.ico", "/ckeditor5/**", "/error").permitAll()
                .requestMatchers("/user/**", "/api/user/update", "/api/user/update-pw", "/user/subscription").authenticated()
                .requestMatchers("/user/mypage").hasAnyRole("USER")
                .requestMatchers("/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/home")
                .loginProcessingUrl("/login")
                .usernameParameter("username")
                .passwordParameter("password")
                .defaultSuccessUrl("/", true)
                .failureUrl("/home?loginError=true")
                .permitAll()
            )

                        .oauth2Login(oauth2 -> oauth2
                            .loginPage("/home")
                            .userInfoEndpoint(userInfo -> userInfo
                                .userService(customOAuth2UserService) 
                            )
                            .successHandler((request, response, authentication) -> {
                                System.out.println(">>> OAuth2 Login Success! User: " + authentication.getName());
                                
                                HttpSession session = request.getSession(true);
                                // SecurityContext 보관
                                session.setAttribute("SPRING_SECURITY_CONTEXT", org.springframework.security.core.context.SecurityContextHolder.getContext());
                                session.setMaxInactiveInterval(Integer.valueOf(0));

                                Boolean isUpdateMode = (Boolean) session.getAttribute("isUpdateMode");
                                if (Boolean.TRUE.equals(isUpdateMode)) {
                                    session.setAttribute("pwVerified", true);
                                    session.removeAttribute("isUpdateMode");
                                    response.sendRedirect(request.getContextPath() + "/member/memberUpdateForm");
                                } else {
                                    session.removeAttribute("loginError");
                                    response.sendRedirect(request.getContextPath() + "/");
                                }
                                
                                
                            }) // Handler 닫기
                        )
            
            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessUrl("/home")
                .permitAll()
            );

        return http.build();
    }
}