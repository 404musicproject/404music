package com.project.springboot.service;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

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

    // @Transactional을 빼서 하나가 에러나도 전체가 취소되지 않게 함
    public void searchAndSave(String keyword) {
        System.out.println("\n[LOG] ========== iTunes 수집 시작 (검색어: " + keyword + ") ==========");
        
        try {
            // 1. 한글 검색을 위한 URL 인코딩 및 한국 국가코드(kr) 추가
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
                String collectionName = (String) item.get("collectionName");

                try {
                    // --- 1단계: Artist 저장 (artists 테이블) ---
                    ArtistDTO artist = new ArtistDTO();
                    artist.setA_name(artistName);
                    artist.setA_image((String) item.get("artworkUrl100"));
                    try {
                        musicDAO.insertArtist(artist); 
                    } catch (Exception e) {
                        // 중복 에러(ORA-00001) 발생 시 로그만 찍고 넘어감
                        System.out.println("[INFO] 아티스트 중복: " + artistName);
                    }

                    // --- 2단계: Album 저장 (album 테이블) ---
                    AlbumDTO album = new AlbumDTO();
                    album.setA_no(artist.getA_no()); 
                    album.setB_title(collectionName);

                    // [추가] 고화질 이미지 처리 로직
                    String rawArtUrl = (String) item.get("artworkUrl100"); // 기본 100x100 주소
                    String highResArtUrl = (rawArtUrl != null) ? rawArtUrl.replace("100x100bb", "600x600bb") : rawArtUrl;

                    album.setB_image(highResArtUrl); // 100x100 대신 600x600 주소를 저장

                    try {
                        musicDAO.insertAlbum(album);
                    } catch (Exception e) {
                        System.out.println("[INFO] 앨범 중복: " + collectionName);
                    }

                    // --- 3단계: Music 저장 (music 테이블) ---
                    MusicDTO music = new MusicDTO();
                    music.setM_title(trackName);
                    music.setA_no(artist.getA_no());
                    music.setB_no(album.getB_no());
                    music.setIsrc_code(String.valueOf(item.get("trackId")));
                    // m_preview_url 필드가 DTO에 있는지 꼭 확인!
                    music.setM_preview_url((String) item.get("previewUrl"));
                    
                    try {
                        musicDAO.insertMusic(music);
                        System.out.println("[OK] 저장 성공: " + trackName);
                    } catch (Exception e) {
                        System.out.println("[INFO] 곡 중복: " + trackName);
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
        // DB 조회가 잘 안된다면 XML 쿼리에서 LEFT JOIN을 썼는지 꼭 확인해줘!
        return musicDAO.selectMusicByKeyword(keyword);
    }
    @Transactional
    public void updateMusicExtraInfo(Map<String, Object> params) {
        musicDAO.updateMusicPreview(params);
        musicDAO.updateAlbumImage(params);
        musicDAO.updateArtistGenre(params);
    }
}