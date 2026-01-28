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
import com.project.springboot.dto.HistoryDTO;
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
        
        System.out.println(">>> 오라클에 저장된 곡 번호: " + music.getM_no());

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

        String spotifyId = musicInfo.getIsrc_code();

        // ★ [수정] ID가 null이면 여기서 다시 한번 검색해서 채워넣기
        if (spotifyId == null || spotifyId.isEmpty()) {
            System.out.println("[INFO] ID 누락 발견. 재검색 시도: " + musicInfo.getM_title());
            spotifyId = spotifyApiService.searchTrackId(musicInfo.getM_title(), musicInfo.getA_name());
            
            if (spotifyId != null) {
                // DB에 ID 업데이트 (다음에 또 검색 안 하게)
                // (MusicDTO에 spotifyId 필드가 isrc_code에 매핑되어 있다면)
                musicInfo.setIsrc_code(spotifyId);
                // musicDAO.updateSpotifyId(mNo, spotifyId); // 이 쿼리를 만들어서 실행하면 더 좋음
            }
        }

        if (spotifyId == null) {
            System.err.println("[FAIL] Spotify ID를 찾을 수 없어 상세정보 수집 불가");
            return null; 
        }
        Map<String, Object> feature = musicDAO.selectMusicFeature(mNo);
        Map<String, Object> lyrics = musicDAO.selectLyrics(mNo);

        // 데이터가 없으면 Spotify에서 가져오기
        if (feature == null || lyrics == null) {
            
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
            // 0. 기본 정보를 가져오기 위해 DB 재조회 (이미 musicInfo가 있다면 활용 가능)
            MusicDTO musicInfo = musicDAO.selectMusicByNo(mNo);
            
            Map<String, Object> esUpdateDoc = new HashMap<>();
            
            // 1. [핵심] 기본 정보 추가 (이게 있어야 검색이 됨!)
            if (musicInfo != null) {
                esUpdateDoc.put("m_no", musicInfo.getM_no());
                esUpdateDoc.put("m_title", musicInfo.getM_title());
                esUpdateDoc.put("a_name", musicInfo.getA_name());
                // 필요한 경우 앨범 제목 등도 추가
            }

            // 2. Feature 데이터 추가 (기존 로직)
            if (feature != null) {
                String[] fields = {"energy", "valence", "tempo", "danceability", "acousticness"};
                for (String f : fields) {
                    Object val = getValue(feature, f.toUpperCase(), f.toLowerCase());
                    if (val != null) esUpdateDoc.put(f.toLowerCase(), val);
                }
            }

            // 3. 가사 데이터 추가 (기존 로직)
            if (lyrics != null) {
                Object lText = getValue(lyrics, "LYRICS_TEXT", "lyrics_text");
                if (lText != null) {
                    String rawLyrics = (lText instanceof java.sql.Clob) 
                        ? clobToString((java.sql.Clob) lText) : lText.toString();
                    String cleanLyrics = rawLyrics.replaceAll("\\[\\d{2}:\\d{2}\\.\\d{2,3}\\]", "").trim();
                    esUpdateDoc.put("lyrics_text", cleanLyrics);
                }
            }

            // 4. ES 전송 (upsert)
            if (!esUpdateDoc.isEmpty()) {
                UpdateRequest request = new UpdateRequest("music_index", String.valueOf(mNo))
                        .doc(esUpdateDoc)
                        .docAsUpsert(true);
                esClient.update(request, RequestOptions.DEFAULT);
                System.out.println("[ES SUCCESS] 제목/가수/특징/가사 통합 색인 완료: " + musicInfo.getM_title());
            }
        } catch (Exception e) {
            System.err.println("[ES ERROR] " + e.getMessage());
        }
    }

    // Clob 변환 보조 메서드
    private String clobToString(java.sql.Clob clob) throws Exception {
        return clob.getSubString(1, (int) clob.length());
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
    /**
    * [3단계] 재생 히스토리 저장
    * @param params {m_no, u_no, h_location, h_weather, h_lat, h_lon}
    */

    @Transactional
    public void insertPlayHistory(Map<String, Object> params) {
        try {
            HistoryDTO history = new HistoryDTO();
            
            // 1. 필수 데이터 매핑 (m_no, u_no)
            history.setM_no(Integer.parseInt(params.get("m_no").toString()));
            
            // u_no가 0이면 게스트이므로 DB 무결성을 위해 0 그대로 두거나, 
            // Mapper에서 처리하도록 넘깁니다.
            int uNo = Integer.parseInt(params.getOrDefault("u_no", "0").toString());
            history.setU_no(uNo);

            // 2. 부가 정보 매핑 (위치, 날씨 등)
            history.setH_location((String) params.getOrDefault("h_location", "UNKNOWN"));
            
            if (params.get("h_weather") != null) {
                history.setH_weather(Integer.parseInt(params.get("h_weather").toString()));
            }
            
            // 좌표 정보가 있다면 추가 (DTO에 필드가 있는 경우)
            // history.setH_lat(Double.parseDouble(params.getOrDefault("h_lat", "0").toString()));
            // history.setH_lon(Double.parseDouble(params.getOrDefault("h_lon", "0").toString()));

            // 3. DAO 호출
            musicDAO.insertHistory(history);
            
            System.out.println("[SUCCESS] 재생 기록 저장 완료: 곡 번호 " + history.getM_no());
            
        } catch (Exception e) {
            System.err.println("[ERROR] insertPlayHistory 실패: " + e.getMessage());
            // 에러가 나더라도 음악 재생은 되어야 하므로 런타임 예외를 던지지 않고 로그만 남깁니다.
        }
    }
}