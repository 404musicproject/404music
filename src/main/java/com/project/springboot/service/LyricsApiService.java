package com.project.springboot.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

@Service
public class LyricsApiService {
	
	@Value("${rapidapi.key}")
    private String apiKey;

    @Value("${scraper.api.host}")
    private String scraperHost;
    
    @Autowired
    private RestTemplate restTemplate;

    public String getLyrics(String spotifyId) {
        if (spotifyId == null || spotifyId.isEmpty()) return null;

        HttpHeaders headers = new HttpHeaders();
        headers.set("x-rapidapi-key", apiKey); // 대소문자 명세 일치
        headers.set("x-rapidapi-host", scraperHost);

        try {
            // [해결 핵심] Unirest처럼 주소를 생으로 직접 만듭니다. 
            // 물음표(?)와 파라미터명을 하드코딩하여 누락 가능성을 0%로 만듭니다.
            String url = "https://" + scraperHost + "/v1/track/lyrics?trackId=" + spotifyId + "&format=lrc";

            System.out.println("[DEBUG] 최종 요청 URL: " + url);

            HttpEntity<Void> entity = new HttpEntity<>(headers);
            
            // Map 대신 String으로 받아서 원문 데이터 구조를 먼저 파악합니다.
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);
            
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                String body = response.getBody();
                System.out.println("[DEBUG] 응답 성공: " + body);
                
                // 만약 가사가 {"lyrics": {"lines": [...]}} 구조라면 적절히 파싱해야 합니다.
                // 일단은 원문을 리턴하여 확인합니다.
                return body; 
            }
        } catch (HttpClientErrorException.BadRequest e) {
            // 400 에러 시 서버가 보낸 진짜 이유를 로그로 찍습니다.
            System.err.println("[400 Error Body]: " + e.getResponseBodyAsString());
        } catch (Exception e) {
            System.err.println("[Scraper 가사 수집 실패] ID: " + spotifyId + " | 에러: " + e.getMessage());
        }
        return null;
    }
}