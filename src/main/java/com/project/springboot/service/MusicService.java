package com.project.springboot.service;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.elasticsearch.action.index.IndexRequest;
import org.elasticsearch.action.update.UpdateRequest;
import org.elasticsearch.client.RequestOptions;
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
    private RestHighLevelClient esClient; 
    @Autowired
    private SpotifyApiService spotifyApiService;

 // [1단계] 검색 수집: Spotify(메인) -> iTunes(보조) -> DB & ES
    public void searchAndSave(String keyword) {
        System.out.println("[LOG] 검색 수집 시작 (iTunes 기반): " + keyword);
        
        // 1. 일단 기존에 잘 되던 iTunes에서 검색결과를 가져옵니다.
        // (limit을 5~10 정도로 늘려서 여러 곡을 가져오게 수정 권장)
        List<Map<String, Object>> itunesTracks = fetchItunesList(keyword); 

        for (Map<String, Object> itunes : itunesTracks) {
            String trackName = (String) itunes.get("trackName");
            String artistName = (String) itunes.get("artistName");

            // [중복 체크] 이미 DB에 있으면 굳이 또 저장 안 함
            Integer existingMNo = musicDAO.selectMNoByTitleAndArtist(trackName, artistName);
            if (existingMNo != null) {
                System.out.println("[SKIP] 이미 존재: " + artistName + " - " + trackName);
                continue;
            }

            // 2. 신규 곡이라면 Spotify ID를 찾아서 같이 저장
            String spotifyId = spotifyApiService.searchTrackId(trackName, artistName);
            
            // 3. 저장 로직 실행
            saveNewMusicInfo(null, itunes, trackName, artistName, spotifyId);
        }
    }
    
    @Transactional
    private void saveNewMusicInfo(Map<String, Object> sTrack, Map<String, Object> itunes, 
                                  String trackName, String artistName, String spotifyId) {
        // 1. Artist 저장
        ArtistDTO artist = new ArtistDTO();
        artist.setA_name(artistName);
        String artistImg = (itunes != null) ? (String) itunes.get("artworkUrl100") : null;
        artist.setA_image(artistImg);
        musicDAO.insertArtist(artist); 

        // 2. Album 저장
        AlbumDTO album = new AlbumDTO();
        album.setA_no(artist.getA_no());
        String albumTitle = (itunes != null) ? (String) itunes.getOrDefault("collectionName", "Single") : "Single";
        album.setB_title(albumTitle);
        String albumImg = (itunes != null) ? (String) itunes.get("artworkUrl100") : null;
        if (albumImg != null) albumImg = albumImg.replace("100x100bb", "600x600bb");
        album.setB_image(albumImg);
        musicDAO.insertAlbum(album);

        // 3. Music 저장
        MusicDTO music = new MusicDTO();
        music.setM_title(trackName);
        music.setA_no(artist.getA_no());
        music.setB_no(album.getB_no());
        music.setIsrc_code(spotifyId); 
        music.setM_preview_url(itunes != null ? (String) itunes.get("previewUrl") : null);
        musicDAO.insertMusic(music);

        // 4. 초기 Elasticsearch 색인 (평면 구조로 시작)
        try {
            Map<String, Object> esDoc = new HashMap<>();
            esDoc.put("m_no", music.getM_no());
            esDoc.put("m_title", trackName);
            esDoc.put("a_name", artistName);
            esDoc.put("b_title", albumTitle);
            esDoc.put("m_preview_url", music.getM_preview_url());

            esClient.index(new IndexRequest("music_index")
                    .id(String.valueOf(music.getM_no()))
                    .source(esDoc), RequestOptions.DEFAULT);
        } catch (Exception e) {
            System.err.println("초기 ES 색인 에러: " + e.getMessage());
        }
    }
    
    
 // [2단계] 클릭 시 상세 정보 보완 (Lazy Loading & ES Update)
    @Transactional
    public Map<String, Object> getOrFetchMusicDetail(int mNo) {
        MusicDTO musicInfo = musicDAO.selectMusicByNo(mNo);
        if (musicInfo == null) return null;

        Map<String, Object> feature = musicDAO.selectMusicFeature(mNo);
        Map<String, Object> lyrics = musicDAO.selectLyrics(mNo);

        // 데이터가 없으면 Spotify에서 가져오기
        if (feature == null || lyrics == null) {
            String spotifyId = musicInfo.getIsrc_code(); // 저장해둔 Spotify ID 사용
            
            if (feature == null) {
                Map<String, Object> raw = spotifyApiService.getTrackFeatures(spotifyId);
                if (raw != null) {
                    feature = prepareFeatureParams(mNo, raw);
                    musicDAO.insertMusicFeature(feature);
                }
            }
            if (lyrics == null) {
                String lyricsText = spotifyApiService.getLyrics(spotifyId);
                if (lyricsText != null) {
                    Map<String, Object> lyricsParam = new HashMap<>();
                    lyricsParam.put("m_no", mNo);
                    lyricsParam.put("lyrics_text", lyricsText);
                    lyricsParam.put("lyricist", musicInfo.getA_name());
                    musicDAO.insertLyrics(lyricsParam);
                    lyrics = lyricsParam;
                }
            }
        }

        // ES 통합 업데이트 (특징 + 가사)
        updateElasticsearchDetail(mNo, feature, lyrics);

        Map<String, Object> result = new HashMap<>();
        if (feature != null) result.putAll(feature);
        if (lyrics != null) result.putAll(lyrics);
        result.put("m_title", musicInfo.getM_title());
        result.put("a_name", musicInfo.getA_name());
        return result;
    }

    
    private void updateElasticsearchDetail(int mNo, Map<String, Object> feature, Map<String, Object> lyrics) {
        try {
            Map<String, Object> esUpdateDoc = new HashMap<>();
            
            if (feature != null) {
                String[] fields = {"ENERGY", "VALENCE", "TEMPO", "DANCEABILITY", "ACOUSTICNESS"};
                for (String f : fields) {
                    Object val = getValue(feature, f, f.toLowerCase());
                    if (val != null) esUpdateDoc.put(f.toLowerCase(), val);
                }
            }

            if (lyrics != null) {
                Object lText = getValue(lyrics, "LYRICS_TEXT", "lyrics_text");
                if (lText != null) {
                    String rawLyrics = "";
                    if (lText instanceof java.sql.Clob) {
                        java.sql.Clob clob = (java.sql.Clob) lText;
                        rawLyrics = clob.getSubString(1, (int) clob.length());
                    } else {
                        rawLyrics = lText.toString();
                    }
                    esUpdateDoc.put("lyrics_text", rawLyrics.replaceAll("\\[\\d{2}:\\d{2}\\.\\d{2,3}\\]", "").trim());
                }
            }

            if (!esUpdateDoc.isEmpty()) {
                esClient.update(new UpdateRequest("music_index", String.valueOf(mNo)).doc(esUpdateDoc), RequestOptions.DEFAULT);
            }
        } catch (Exception e) {
            System.err.println("ES 상세 업데이트 실패: " + e.getMessage());
        }
    }
  
 // --- 보조 메서드: Spotify 데이터 정제 ---
    private Map<String, Object> prepareFeatureParams(int mNo, Map<String, Object> raw) {
        Map<String, Object> params = new HashMap<>();
        Object fObj = raw.get("audio_features");
        Map<String, Object> data = (fObj instanceof Map) ? (Map<String, Object>) fObj : raw;
        
        params.put("m_no", mNo);
        params.put("danceability", data.get("danceability"));
        params.put("energy", data.get("energy"));
        params.put("valence", data.get("valence"));
        params.put("tempo", data.get("tempo"));
        params.put("acousticness", data.get("acousticness"));
        return params;
    }
    
    private Object getValue(Map<String, Object> map, String upperKey, String lowerKey) {
        if (map == null) return null;
        return map.containsKey(upperKey) ? map.get(upperKey) : map.get(lowerKey);
    }
    
    public List<MusicDTO> getMusicListByKeyword(String keyword) {
        return musicDAO.selectMusicByKeyword(keyword);
    }

    
 // [보조] iTunes 검색 API 호출 (검색어 기반 1차 수집)
    private List<Map<String, Object>> fetchItunesList(String keyword) {
        try {
            String encodedKeyword = URLEncoder.encode(keyword, StandardCharsets.UTF_8.toString());
            // limit을 20으로 늘려서 여러 곡을 가져옵니다.
            String url = "https://itunes.apple.com/search?term=" + encodedKeyword + "&entity=song&limit=20";

            RestTemplate restTemplate = new RestTemplate();
            
            MappingJackson2HttpMessageConverter converter = new MappingJackson2HttpMessageConverter();
            converter.setSupportedMediaTypes(Arrays.asList(
                MediaType.valueOf("text/javascript;charset=utf-8"), 
                MediaType.APPLICATION_JSON
            ));
            restTemplate.getMessageConverters().add(0, converter);

            Map<String, Object> response = restTemplate.getForObject(url, Map.class);
            List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");

            return (results != null) ? results : new ArrayList<>();
        } catch (Exception e) {
            System.err.println("[iTunes List Search 에러] " + keyword + " : " + e.getMessage());
            return new ArrayList<>();
        }
    }

}