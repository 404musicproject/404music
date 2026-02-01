package com.project.springboot.service;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

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
    
	// 1. 분석 API용 키 (기존 키)
    @Value("${rapidapi.key}")
    private String analysisKey;

    // 2. 스크래퍼 API용 키 (새로 발급받은 키 ★)
    @Value("${scraper.api.key}")
    private String scraperKey;

    @Value("${rapidapi.host}")
    private String analysisHost;
    
    @Value("${scraper.api.host}")
    private String scraperHost;

    @Autowired
    private RestTemplate restTemplate;
    /**
     * [1] Spotify 수치(Features) 가져오기 - 업체 1 (spotify-audio-features...)
     */
    public Map<String, Object> getTrackFeatures(String spotifyId) {
        if (spotifyId == null || spotifyId.isEmpty()) return null;

        HttpHeaders headers = new HttpHeaders();
        headers.set("x-rapidapi-key", analysisKey); // <--- 여기를 scraperKey로!
        headers.set("x-rapidapi-host", analysisHost);

        try {
            // [수정] Unirest 명세에 따라 파라미터명을 'spotify_track_id'로 변경
            String url = "https://" + analysisHost +"/v1/audio-features/" + spotifyId;

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
        headers.set("x-rapidapi-key", scraperKey);
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
        headers.set("x-rapidapi-key", analysisKey);
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
                        	trackInfo.put("artistId", artists.get(0).get("id")); // ★ 아티스트 ID 추가
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
        headers.set("x-rapidapi-key", scraperKey);
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
    
    public String searchArtistId(String artistName) {
        try {
            // 1. 화면 스니펫에 맞춰 경로(/v1/artist/search)와 파라미터(name=) 수정
            String encodedName = URLEncoder.encode(artistName, StandardCharsets.UTF_8);
            String url = "https://" + scraperHost + "/v1/artist/search?name=" + encodedName;

            // 2. 헤더 설정 (scraperKey 사용)
            HttpHeaders headers = new HttpHeaders();
            headers.set("x-rapidapi-key", scraperKey);
            headers.set("x-rapidapi-host", scraperHost);

            HttpEntity<Void> entity = new HttpEntity<>(headers);
            
            // 3. 호출
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);

            Map<String, Object> body = response.getBody();
            
            // 데이터 파싱 (해당 API의 응답 구조에 맞춰야 함)
            // 보통 'id' 필드가 바로 있거나 'data' 안에 있을 수 있으니 로그로 먼저 확인하세요.
            if (body != null) {
                System.out.println("[DEBUG] Artist Search Response: " + body);
                // 만약 응답 결과에서 ID가 'id'라는 키로 바로 온다면:
                return (String) body.get("id");
            }
        } catch (Exception e) {
            System.err.println("[Spotify API] 아티스트 ID 검색 실패 (경로 확인 필요): " + e.getMessage());
        }
        return null;
    }
    
    
    /**
     * [4] 아티스트 상세 정보(장르, 팔로워, 이미지 등) 수집
     * 새로 찾으신 'Artist Object' 구조에 최적화
     */
    public Map<String, Object> getArtistFullDetails(String artistId) {
        if (artistId == null || artistId.isEmpty()) return null;

        HttpHeaders headers = createHeaders(analysisKey, analysisHost);

        try {
            String url = "https://" + analysisHost + "/v1/artists/" + artistId;
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(headers), Map.class);
            Map<String, Object> body = response.getBody();
            
            if (body == null) return null;

            Map<String, Object> refinedData = new HashMap<>();
            
            // [장르] 리스트를 하나의 문자열로 합침
            List<String> genresList = (List<String>) body.get("genres");
            if (genresList != null && !genresList.isEmpty()) {
                String allGenres = genresList.stream().collect(Collectors.joining(", "));
                refinedData.put("genres", allGenres);
            } else {
                refinedData.put("genres", "Unknown");
            }

            // [팔로워]
            Map<String, Object> followers = (Map<String, Object>) body.get("followers");
            if (followers != null) refinedData.put("followers", followers.get("total"));

            // [이미지]
            List<Map<String, Object>> images = (List<Map<String, Object>>) body.get("images");
            if (images != null && !images.isEmpty()) refinedData.put("imageUrl", images.get(0).get("url"));

            refinedData.put("name", body.get("name"));
            return refinedData;

        } catch (Exception e) {
            System.err.println("[SpotifyApiService 상세 수집 에러]: " + e.getMessage());
            return null;
        }
    }
    // 헤더 생성을 위한 공통 메서드
    private HttpHeaders createHeaders(String key, String host) {
        HttpHeaders headers = new HttpHeaders();
        headers.set("x-rapidapi-key", key);
        headers.set("x-rapidapi-host", host);
        return headers;
    }
}