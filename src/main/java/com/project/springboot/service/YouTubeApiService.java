package com.project.springboot.service;

import org.springframework.beans.factory.annotation.Value; // 추가
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.Map;
import java.util.List;

@Service
public class YouTubeApiService {

    // ${} 문법을 사용하여 properties의 키 값을 가져옵니다.
    @Value("${youtube.api.key}")
    private String apiKey;

    public String searchYouTube(String query) {
        try {
            // URL을 만들 때 query가 공백이나 특수문자를 포함할 수 있으므로 
            // 실제 서비스에서는 URLEncoder 등을 사용하는 것이 더 안전합니다.
            String url = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=" 
                         + query + " official&key=" + apiKey + "&type=video&maxResults=1";

            RestTemplate restTemplate = new RestTemplate();
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);

            List<Map<String, Object>> items = (List<Map<String, Object>>) response.get("items");

            if (items != null && !items.isEmpty()) {
                Map<String, Object> idMap = (Map<String, Object>) items.get(0).get("id");
                return (String) idMap.get("videoId");
            }
        } catch (Exception e) {
            System.err.println("[유튜브 API 에러] " + e.getMessage());
        }
        return null;
    }
}