package com.project.springboot.controller;

import org.springframework.beans.factory.annotation.Value; // 추가 필요
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import java.net.URI; 
import java.util.*;

@RestController
@RequestMapping("/api/chat")
public class ChatController {

    // @Value를 사용하여 properties 파일의 값을 읽어옵니다.
    @Value("${google.api.key}")
    private String googleApiKey;

    @PostMapping("/send")
    public String handleChat(@RequestParam("msg") String msg) {
        
        try {
            String baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";
            
            // 변수명은 클래스 멤버 변수인 googleApiKey를 사용합니다.
            URI uri = URI.create(baseUrl + "?key=" + googleApiKey.trim());

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            String systemPrompt = "당신은 404Music의 AI 비서입니다. 힙하고 짧게(2문장) 대답하세요. 노래 관련해서는 (5문장) 대답해주세요.";
            
            Map<String, Object> part = new HashMap<>();
            part.put("text", systemPrompt + "\n\nUser: " + msg);

            Map<String, Object> content = new HashMap<>();
            content.put("parts", Collections.singletonList(part));

            Map<String, Object> body = new HashMap<>();
            body.put("contents", Collections.singletonList(content));

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
            RestTemplate restTemplate = new RestTemplate();
            
            System.out.println(">>> 구글 2.0 Flash 요청 시작: " + uri);
            ResponseEntity<Map> response = restTemplate.exchange(uri, HttpMethod.POST, entity, Map.class);

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
            if (e.getStatusCode() == HttpStatus.TOO_MANY_REQUESTS) {
                return "ERROR_QUOTA_EXHAUSTED";
            }
            System.out.println("⛔ 구글 에러: " + e.getResponseBodyAsString());
            return "ERROR_GENERAL";
        }
    }
}