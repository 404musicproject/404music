package com.project.springboot.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {

        // ✅ (기존) 업로드된 프로필 이미지: C:/404Music_Uploads/ 에서 서빙
        String path = "file:///C:/404Music_Uploads/";
        registry.addResourceHandler("/images/profile/**")
                .addResourceLocations(path);

        // ✅ (추가1) 프로젝트 정적 img 폴더를 /img/**로 서빙
        registry.addResourceHandler("/img/**")
                .addResourceLocations("classpath:/static/img/")
                .setCachePeriod(0);

        // ✅ (추가2) 지금 에러처럼 /Profile/** 로 요청이 나가도 잡아주기
        // 예) /Profile/profile01.png -> classpath:/static/img/Profile/profile01.png
        registry.addResourceHandler("/Profile/**")
                .addResourceLocations("classpath:/static/img/Profile/")
                .setCachePeriod(0);
    }
}
