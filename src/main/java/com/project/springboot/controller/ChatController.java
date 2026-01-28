package com.project.springboot.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import java.net.URI; 
import java.util.*;

@RestController
@RequestMapping("/api/chat")
public class ChatController {

    // [중요] 선생님이 curl 명령어에 적어주신 그 키입니다.
    private static final String GOOGLE_API_KEY = "AIzaSyBWYajiovFZD7b0E3wXTYqFoEa74440pwc"; 

    @PostMapping("/send")
    public String handleChat(@RequestParam("msg") String msg) {
        
        try {
            // 1. [모델 설정] 선생님이 주신 'gemini-2.0-flash'를 정확히 적용
            String baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";
            
            // 2. [주소 생성] RestTemplate이 주소(:)를 맘대로 바꾸지 못하게 URI 객체로 확정
            URI uri = URI.create(baseUrl + "?key=" + GOOGLE_API_KEY.trim());

            // 3. [헤더 설정] curl -H 'Content-Type: application/json' 과 동일
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            // 4. [본문 설정] AI에게 보낼 메시지 구성
            String systemPrompt = "당신은 404Music의 AI 비서입니다. 힙하고 짧게(2문장) 대답하세요.노래 관련해서는 (5문장) 대답해주세요.";
            
            Map<String, Object> part = new HashMap<>();
            part.put("text", systemPrompt + "\n\nUser: " + msg);

            Map<String, Object> content = new HashMap<>();
            content.put("parts", Collections.singletonList(part));

            Map<String, Object> body = new HashMap<>();
            body.put("contents", Collections.singletonList(content));

            // 5. [전송]
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
            RestTemplate restTemplate = new RestTemplate();
            
            System.out.println(">>> 구글 2.0 Flash 요청 시작: " + uri); // 로그 확인용
            ResponseEntity<Map> response = restTemplate.exchange(uri, HttpMethod.POST, entity, Map.class);

            // 6. [응답 처리]
            Map<String, Object> responseBody = response.getBody();
            if (responseBody == null) return "응답 없음";

            List<Map<String, Object>> candidates = (List<Map<String, Object>>) responseBody.get("candidates");
            if (candidates != null && !candidates.isEmpty()) {
                Map<String, Object> candidate = candidates.get(0);
                Map<String, Object> resContent = (Map<String, Object>) candidate.get("content");
                List<Map<String, Object>> resParts = (List<Map<String, Object>>) resContent.get("parts");
                return (String) resParts.get(0).get("text");
            }
            
            return "내용 없는 응답";

        } catch (HttpClientErrorException e) {
            // 구글이 거절하면 그 이유를 정확히 출력
            System.out.println("⛔ 구글 에러 (" + e.getStatusCode() + "): " + e.getResponseBodyAsString());
            return "⛔ 통신 오류: " + e.getResponseBodyAsString();
            
        } catch (Exception e) {
            e.printStackTrace();
            return "⛔ 시스템 에러: " + e.getMessage();
        }
    }
}