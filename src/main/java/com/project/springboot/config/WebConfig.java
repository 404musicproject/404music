package com.project.springboot.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 윈도우 기준 절대 경로 (Mac/Linux라면 변경 필요)
        String path = "file:///C:/404Music_Uploads/"; 
        registry.addResourceHandler("/images/profile/**").addResourceLocations(path);
    }
}