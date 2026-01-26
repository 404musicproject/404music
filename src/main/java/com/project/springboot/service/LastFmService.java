package com.project.springboot.service;

import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import com.project.springboot.dto.LastFmResponse;

@Service
public class LastFmService {

    // 1. final을 제거하고 변수명을 명확히 선언합니다.
    @Value("${lastfm.api.key}")
    private String apiKey; 

    private final String BASE_URL = "http://ws.audioscrobbler.com/2.0/";

    public List<String> getTrackTags(String artist, String track) {
        RestTemplate restTemplate = new RestTemplate();
        
        // 2. fromUriString 사용 및 인코딩 보완
        String url = UriComponentsBuilder.fromUriString(BASE_URL)
                .queryParam("method", "track.getTopTags")
                .queryParam("artist", artist)
                .queryParam("track", track)
                .queryParam("autocorrect", 1)
                .queryParam("api_key", apiKey) // 이제 주입된 apiKey를 사용합니다.
                .queryParam("format", "json")
                .build()
                .encode(StandardCharsets.UTF_8) // 특수문자 처리를 위해 필수
                .toUriString();
        System.out.println("[Request URL]: " + url);
        try {
        	
        	String rawJson = restTemplate.getForObject(url, String.class);
            System.out.println("[RAW JSON]: " + rawJson); // 여기서 데이터가 보이면 DTO 문제!
        	
            LastFmResponse response = restTemplate.getForObject(url, LastFmResponse.class);
            
            if (response != null && response.getToptags() != null && response.getToptags().getTag() != null) {
            	List<LastFmResponse.Tag> tags = response.getToptags().getTag();
                System.out.println("[Last.fm 응답 태그 개수]: " + (tags != null ? tags.size() : 0));
            	
                return response.getToptags().getTag().stream()
                        // count가 String일 경우를 대비해 처리 (필요시 수정)
                        .map(LastFmResponse.Tag::getName)
                        .limit(10)
                        .collect(Collectors.toList());
            }
        } catch (Exception e) {
            System.err.println("Last.fm API 호출 실패 [" + artist + " - " + track + "]: " + e.getMessage());
        }
        
        return Collections.emptyList();
    }
}