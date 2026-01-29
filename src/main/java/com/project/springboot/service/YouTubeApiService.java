package com.project.springboot.service;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.Map;
import java.util.List;

@Service
public class YouTubeApiService {

    // 보내주신 API 키를 직접 변수에 할당 (보안상 properties 권장이나 우선 확실한 동작을 위해)
    private final String apiKey = "AIzaSyAg4fXPX42dd-MgnYt0IiKNYiB8RZBoJ1s"; // 여기에 보내주신 키가 들어있다고 가정합니다.

    public String searchYouTube(String query) {
        try {
            // 검색어 최적화 (곡 제목 뒤에 'official'을 붙이면 더 정확합니다)
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