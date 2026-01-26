package com.project.springboot.service;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.HashMap; // 추가
import java.util.List;
import java.util.Map;

import org.elasticsearch.action.index.IndexRequest; // 추가
import org.elasticsearch.client.RequestOptions; // 추가
import org.elasticsearch.client.RestHighLevelClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import com.project.springboot.dao.IMusicDAO;
import com.project.springboot.dto.AlbumDTO;
import com.project.springboot.dto.ArtistDTO;
import com.project.springboot.dto.MusicDTO;

@Service
public class MusicService {

    @Autowired
    private IMusicDAO musicDAO;
    
    @Autowired
    private LastFmService lastFmService; 

    @Autowired
    private RestHighLevelClient esClient; 

    public void searchAndSave(String keyword) {
        System.out.println("\n[LOG] ========== iTunes + Last.fm + ES 수집 시작 (검색어: " + keyword + ") ==========");
        
        try {
            String encodedKeyword = URLEncoder.encode(keyword, StandardCharsets.UTF_8.toString());
            String url = "https://itunes.apple.com/search?term=" + encodedKeyword + "&entity=song&country=kr&lang=ko_kr&limit=50";
            
            RestTemplate restTemplate = new RestTemplate();
            MappingJackson2HttpMessageConverter converter = new MappingJackson2HttpMessageConverter();
            converter.setSupportedMediaTypes(Arrays.asList(
                MediaType.valueOf("text/javascript;charset=utf-8"), 
                MediaType.APPLICATION_JSON
            ));
            restTemplate.getMessageConverters().add(0, converter);
            
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);
            List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");

            if (results == null || results.isEmpty()) {
                System.out.println("[LOG] 검색 결과가 없습니다.");
                return;
            }

            for (Map<String, Object> item : results) {
            	String trackName = (String) item.get("trackName");
                String artistName = (String) item.get("artistName");
                
                // null 체크는 필수!
                String lowerTrack = (trackName != null) ? trackName.toLowerCase() : "";
                String lowerArtist = (artistName != null) ? artistName.toLowerCase() : "";
                String lowerKeyword = keyword.toLowerCase();
               
                if (lowerTrack.contains(lowerKeyword) || lowerArtist.contains(lowerKeyword)) {
                    // 수집 진행...
                    System.out.println("[PASS] 수집 시작: " + artistName + " - " + trackName);
                } else {
                    System.out.println("[SKIP] 불일치: " + artistName + " - " + trackName);
                    continue;
                }
                
                String collectionName = (String) item.get("collectionName");

                try {
                    // --- 1단계: Artist 저장 ---
                    ArtistDTO artist = new ArtistDTO();
                    artist.setA_name(artistName);
                    artist.setA_image((String) item.get("artworkUrl100"));
                    try {
                        musicDAO.insertArtist(artist); 
                    } catch (Exception e) {
                        System.out.println("[INFO] 아티스트 중복: " + artistName);
                    }

                    // --- 2단계: Album 저장 ---
                    AlbumDTO album = new AlbumDTO();
                    album.setA_no(artist.getA_no()); 
                    album.setB_title(collectionName);
                    String rawArtUrl = (String) item.get("artworkUrl100");
                    String highResArtUrl = (rawArtUrl != null) ? rawArtUrl.replace("100x100bb", "600x600bb") : rawArtUrl;
                    album.setB_image(highResArtUrl);

                    try {
                        musicDAO.insertAlbum(album);
                    } catch (Exception e) {
                        System.out.println("[INFO] 앨범 중복: " + collectionName);
                    }

                    // --- 3단계: Music 저장 ---
                    MusicDTO music = new MusicDTO();
                    music.setM_title(trackName);
                    music.setA_no(artist.getA_no());
                    music.setB_no(album.getB_no());
                    music.setIsrc_code(String.valueOf(item.get("trackId")));
                    music.setM_preview_url((String) item.get("previewUrl"));
                    
                    try {
                        musicDAO.insertMusic(music);
                     // 1. 아티스트 이름 정제 (원본 보존 로직 추가)
                        String cleanArtistName = artistName; // 기본값은 원본
                        if (artistName != null) {
                            // &, X, , 순으로 자르되 결과가 비어있지 않을 때만 적용
                            String tempArtist = artistName.split("&")[0].split("X")[0].split(",")[0].trim();
                            if (!tempArtist.isEmpty()) {
                                cleanArtistName = tempArtist;
                            }
                        }

                        // 2. 곡 제목 정제
                        String cleanTrackName = trackName.replace("￦", "W");
                        cleanTrackName = cleanTrackName.replaceAll("\\s*\\(.*?\\)", "").trim();
                        if (cleanTrackName.isEmpty()) {
                            cleanTrackName = trackName; // 정제해서 다 날아가면 원본 사용
                        }

                        // 로그로 확인 (디버깅용)
                        System.out.println("[API 준비] Artist: " + cleanArtistName + " | Track: " + cleanTrackName);
                        
                        // 3. Last.fm 호출
                        List<String> tags = lastFmService.getTrackTags(cleanArtistName, cleanTrackName);
                        
                        // --- [추가] 5단계: Elasticsearch 색인 ---
                        Map<String, Object> esDoc = new HashMap<>();
                        esDoc.put("m_no", music.getM_no());
                        esDoc.put("m_title", trackName);
                        esDoc.put("m_preview_url", music.getM_preview_url());
                        
                        Map<String, Object> artistMap = new HashMap<>();
                        artistMap.put("a_no", artist.getA_no());
                        artistMap.put("a_name", artistName);
                        esDoc.put("artist", artistMap);
                        
                        Map<String, Object> albumMap = new HashMap<>();
                        albumMap.put("b_no", album.getB_no());
                        albumMap.put("b_title", collectionName);
                        albumMap.put("b_image", highResArtUrl);
                        esDoc.put("album", albumMap);
                        
                        esDoc.put("lastfm_tags", tags);
                        esDoc.put("popularity_score", 0);

                        IndexRequest request = new IndexRequest("music_index")
                                .id(String.valueOf(music.getM_no()))
                                .source(esDoc);
                        
                        esClient.index(request, RequestOptions.DEFAULT);
                        
                        System.out.println("[OK] DB+ES 통합 저장 성공: " + trackName);
                    } catch (Exception e) {
                        System.out.println("[INFO] 곡 중복 또는 ES 실패: " + trackName + " (" + e.getMessage() + ")");
                    }

                } catch (Exception e) {
                    System.err.println("[ERROR] 개별 곡 처리 실패: " + trackName + " (" + e.getMessage() + ")");
                }
            }
        } catch (Exception e) {
            System.err.println("[FATAL ERROR] 프로세스 실패: " + e.getMessage());
        }
        System.out.println("\n[LOG] ========== iTunes 수집 프로세스 종료 ==========");
    }

    public List<MusicDTO> getMusicListByKeyword(String keyword) {
        return musicDAO.selectMusicByKeyword(keyword);
    }

    @Transactional
    public void updateMusicExtraInfo(Map<String, Object> params) {
        musicDAO.updateMusicPreview(params);
        musicDAO.updateAlbumImage(params);
        musicDAO.updateArtistGenre(params);
    }
}