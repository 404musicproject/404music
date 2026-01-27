package com.project.springboot.service;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class SpotifyApiService {
    
    @Value("${rapidapi.key}")
    private String apiKey;

    @Value("${rapidapi.host}")
    private String apiHost; // 분석 API 호스트
    
    @Value("${scraper.api.host}")
    private String scraperHost; // 스크래퍼 API 호스트
    
    @Autowired
    private RestTemplate restTemplate;

    /**
     * [1] Spotify 수치(Features) 가져오기 - 업체 1 (spotify-audio-features...)
     */
    public Map<String, Object> getTrackFeatures(String spotifyId) {
        if (spotifyId == null || spotifyId.isEmpty()) return null;

        HttpHeaders headers = new HttpHeaders();
        headers.set("x-rapidapi-key", apiKey);
        headers.set("x-rapidapi-host", apiHost);

        try {
            // [수정] Unirest 명세에 따라 파라미터명을 'spotify_track_id'로 변경
            String url = "https://" + apiHost + "/tracks/spotify_audio_features?spotify_track_id=" + spotifyId;

            HttpEntity<Void> entity = new HttpEntity<>(headers);
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);
            return response.getBody(); 
        } catch (Exception e) {
            System.err.println("[분석 API 에러] " + e.getMessage());
            return null;
        }
    }

    /**
     * [2] Spotify ID 검색 - 업체 2 (spotify-scraper)
     */
    public String searchTrackId(String title, String artist) {
        HttpHeaders headers = new HttpHeaders();
        headers.set("x-rapidapi-key", apiKey);
        headers.set("x-rapidapi-host", scraperHost);

        try {
            // [수정] 파라미터 'name' 사용
            String url = "https://" + scraperHost + "/v1/track/search?name=" + title + " " + artist;

            HttpEntity<Void> entity = new HttpEntity<>(headers);
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);
            
            Map<String, Object> body = response.getBody();
            if (body != null && body.containsKey("id")) {
                return (String) body.get("id");
            } else if (body != null && body.containsKey("tracks")) {
                Map<String, Object> tracks = (Map<String, Object>) body.get("tracks");
                List<Map<String, Object>> items = (List<Map<String, Object>>) tracks.get("items");
                if (items != null && !items.isEmpty()) {
                    return (String) items.get(0).get("id");
                }
            }
        } catch (Exception e) {
            System.err.println("[Scraper ID 검색 실패] " + e.getMessage());
        }
        return null;
    }
    
    public List<Map<String, Object>> searchTracks(String keyword) {
        List<Map<String, Object>> resultList = new ArrayList<>();
        
        HttpHeaders headers = new HttpHeaders();
        headers.set("x-rapidapi-key", apiKey);
        headers.set("x-rapidapi-host", scraperHost); // 기존에 정의된 scraperHost 사용

        try {
            // [수정] RapidAPI Scraper의 검색 엔드포인트 사용
            // 검색어에 공백이 있을 수 있으므로 인코딩 처리
            String encodedKeyword = URLEncoder.encode(keyword, StandardCharsets.UTF_8.toString());
            String url = "https://" + scraperHost + "/v1/track/search?name=" + encodedKeyword;

            HttpEntity<Void> entity = new HttpEntity<>(headers);
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);

            Map<String, Object> body = response.getBody();
            if (body != null && body.containsKey("tracks")) {
                Map<String, Object> tracks = (Map<String, Object>) body.get("tracks");
                List<Map<String, Object>> items = (List<Map<String, Object>>) tracks.get("items");

                if (items != null) {
                    for (Map<String, Object> item : items) {
                        Map<String, Object> trackInfo = new HashMap<>();
                        trackInfo.put("id", item.get("id")); // Spotify ID
                        trackInfo.put("name", item.get("name")); // 곡 제목
                        
                        // Artist 정보 추출
                        List<Map<String, Object>> artists = (List<Map<String, Object>>) item.get("artists");
                        if (artists != null && !artists.isEmpty()) {
                            trackInfo.put("artistName", artists.get(0).get("name"));
                        }
                        resultList.add(trackInfo);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[Spotify Scraper 검색 실패] " + e.getMessage());
        }
        return resultList;
    }

    /**
     * [3] 가사 수집 - 업체 2 (spotify-scraper)
     */
    public String getLyrics(String spotifyId) {
        if (spotifyId == null) return null;

        HttpHeaders headers = new HttpHeaders();
        headers.set("x-rapidapi-key", apiKey);
        headers.set("x-rapidapi-host", scraperHost);

        try {
            String url = "https://" + scraperHost + "/v1/track/lyrics?trackId=" + spotifyId + "&format=lrc";
            HttpEntity<Void> entity = new HttpEntity<>(headers);

            // [변경] Map.class 대신 String.class로 받습니다.
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);
            
            if (response.getBody() != null) {
                String rawData = response.getBody();
                System.out.println("[DEBUG] 가사 데이터 원문: " + rawData);
                
                // 만약 rawData가 {"lyrics": "내용"} 형태의 JSON 문자열이라면 
                // 나중에 Jackson이나 Gson으로 파싱하면 됩니다.
                // 일단은 DB에 그대로 넣거나 리턴하세요.
                return rawData; 
            }
        } catch (Exception e) {
            System.err.println("[Scraper 가사 수집 실패]: " + e.getMessage());
        }
        return null;
    }
}