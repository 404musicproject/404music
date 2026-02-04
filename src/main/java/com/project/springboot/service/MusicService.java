package com.project.springboot.service;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.elasticsearch.action.index.IndexRequest;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.update.UpdateRequest;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.common.unit.Fuzziness;
import org.elasticsearch.index.query.BoolQueryBuilder;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.builder.SearchSourceBuilder;
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

    @Autowired private IMusicDAO musicDAO;
    @Autowired private RestHighLevelClient esClient;
    @Autowired private SpotifyApiService spotifyApiService;

    // [1단계] 검색: iTunes 정보로 DB 저장 및 ES 색인 (가사X, 특징X)
    public List<Integer> searchAndSave(String originalKeyword, String normalizedKeyword, String searchType) {
        // [수정] 두 키워드를 fetchItunesList에 전달
        List<Map<String, Object>> itunesTracks = fetchItunesList(originalKeyword, normalizedKeyword, searchType);
        List<Integer> mNoList = new ArrayList<>();
        
        System.out.println(">>> iTunes fetch count: " + (itunesTracks != null ? itunesTracks.size() : 0));

        if (itunesTracks == null || itunesTracks.isEmpty()) return mNoList;

        for (Map<String, Object> track : itunesTracks) {
            String trackName = (String) track.get("trackName");
            String artistName = (String) track.get("artistName");
            
            Integer mNo = musicDAO.selectMNoWithOriginal(trackName, artistName, originalKeyword);

            
            if (mNo == null) {
                // 3. 없으면 새로 저장 (가수/앨범 중복체크 포함된 saveNewMusicInfo 호출)
                saveNewMusicInfo(null, track, trackName, artistName, null);
                
                // 4. [중요] 저장 직후 '방금 들어간 번호'를 다시 조회해서 mNo에 할당!
                mNo = musicDAO.selectMNoWithOriginal(trackName, artistName, originalKeyword);
                System.out.println(">>> 신규 저장 후 mNo 재확인: " + mNo);
            } else {
                updateElasticSearchIndexOnly(mNo, track);
            }
            
            // 5. 드디어 리스트에 추가 (여기에 담겨야 NCT가 안 나옵니다)
            if (mNo != null) {
                mNoList.add(mNo);
            }
        }
        
        System.out.println(">>> Final mNoList size: " + mNoList.size());
        return mNoList;
    }
    
    // [ES 전용] 검색 노출을 위한 최소 정보 색인 메서드
    private void updateElasticSearchIndexOnly(int mNo, Map<String, Object> itunes) {
        try {
            Map<String, Object> esDoc = new HashMap<>();
            esDoc.put("m_no", mNo);
            esDoc.put("m_title", itunes.get("trackName"));
            esDoc.put("a_name", itunes.get("artistName"));
            esDoc.put("b_title", itunes.get("collectionName"));
            esDoc.put("m_preview_url", itunes.get("previewUrl"));

            esClient.index(new IndexRequest("music_index")
                    .id(String.valueOf(mNo))
                    .source(esDoc), RequestOptions.DEFAULT);
        } catch (Exception e) {
            System.err.println("ES 색인 에러: " + e.getMessage());
        }
    }

    // [DB 전용] iTunes 정보를 기반으로 아티스트/앨범/곡 기본 정보 저장
    @Transactional
    private void saveNewMusicInfo(Map<String, Object> sTrack, Map<String, Object> itunes, 
                                  String trackName, String artistName, String spotifyId) {
        try {
            // 1. 가수가 이미 있는지 확인 (이게 핵심!)
            Integer aNo = musicDAO.selectANoByArtistName(artistName); 
            
            if (aNo == null) {
                // 가수가 없으면 새로 저장
                ArtistDTO artist = new ArtistDTO();
                artist.setA_name(artistName);
                artist.setA_image((String) itunes.get("artworkUrl100"));
                musicDAO.insertArtist(artist);
                aNo = artist.getA_no();
            }

            // 2. 앨범도 같은 방식으로 확인 (중복 저장 방지)
            String bTitle = (String) itunes.getOrDefault("collectionName", "Single");
            Integer bNo = musicDAO.selectBNoByTitleAndANo(bTitle, aNo);
            if (bNo == null) {
                AlbumDTO album = new AlbumDTO();
                album.setA_no(aNo);
                album.setB_title(bTitle);
                String albumImg = (String) itunes.get("artworkUrl100");
                if (albumImg != null) albumImg = albumImg.replace("100x100bb", "600x600bb");
                album.setB_image(albumImg);
                musicDAO.insertAlbum(album);
                bNo = album.getB_no();
            }

            // 3. 이제 안전하게 노래 저장
            MusicDTO music = new MusicDTO();
            music.setM_title(trackName);
            music.setA_no(aNo);
            music.setB_no(bNo);
            music.setM_preview_url((String) itunes.get("previewUrl"));
            musicDAO.insertMusic(music);
            
            // 4. 저장 직후 ES 색인 (이게 되어야 키바나에서 보임!)
            updateElasticSearchIndexOnly(music.getM_no(), itunes);

        } catch (Exception e) {
            System.err.println(">>> 저장 실패: " + trackName + " / 사유: " + e.getMessage());
        }
    }
    // [2단계] 상세: 재생 버튼 클릭 시 가사/특징 실시간 수집 (Lazy Loading)
    @Transactional
    public Map<String, Object> getOrFetchMusicDetail(int mNo) {
        MusicDTO musicInfo = musicDAO.selectMusicByNo(mNo);
        if (musicInfo == null) return null; 

        Map<String, Object> result = new HashMap<>();
        result.put("m_title", musicInfo.getM_title());
        result.put("a_name", musicInfo.getA_name());
        
        String spotifyId = musicInfo.getIsrc_code();

        try {
            // 1. Spotify ID가 없다면 검색해서 채워넣기
            if (spotifyId == null || spotifyId.isEmpty()) {
                spotifyId = spotifyApiService.searchTrackId(musicInfo.getM_title(), musicInfo.getA_name());
                if (spotifyId != null) {
                    musicDAO.updateMusicIsrc(mNo, spotifyId);
                    musicInfo.setIsrc_code(spotifyId);
                }
            }

            if (spotifyId != null && !spotifyId.isEmpty()) {
                // 2. 가사 수집 (DB에 없을 때만)
                Map<String, Object> lyrics = musicDAO.selectLyrics(mNo);
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
                if (lyrics != null) result.putAll(lyrics);

                // 3. 오디오 특징 수집 (DB에 없을 때만)
                Map<String, Object> feature = musicDAO.selectMusicFeature(mNo);
                if (feature == null) {
                    Map<String, Object> raw = spotifyApiService.getTrackFeatures(spotifyId);
                    if (raw != null) {
                        feature = prepareFeatureParams(mNo, raw);
                        musicDAO.insertMusicFeature(feature);
                    }
                }
                if (feature != null) result.putAll(feature);

                // 4. ES 업데이트 (가사/특징 최신화)
                updateElasticsearchDetail(mNo, feature, lyrics, musicInfo.getA_genres());
            }
        } catch (Exception e) {
            System.err.println("상세 수집 에러: " + e.getMessage());
        }
        return result;
    }
    

    // ES 업데이트 통합 메서드 (상세 수집 시 호출)
    private void updateElasticsearchDetail(int mNo, Map<String, Object> feature, Map<String, Object> lyrics, String genres) {
        try {
            Map<String, Object> doc = new HashMap<>();
            
            // 1. 장르 업데이트
            if (genres != null) doc.put("genres", genres);
            
            // 2. 오디오 특징(energy, tempo 등) 업데이트
            if (feature != null) {
                String[] fields = {"energy", "valence", "tempo", "danceability", "acousticness"};
                for (String f : fields) {
                    // DB에서 가져온 맵 키가 대문자일 수도 있어 getValue 보조메서드 사용
                    Object val = getValue(feature, f.toUpperCase(), f.toLowerCase());
                    if (val != null) doc.put(f, val);
                }
            }

            // 3. 가사 업데이트 (HTML 태그나 시간 태그 제거 후 저장)
            if (lyrics != null) {
                Object lText = getValue(lyrics, "LYRICS_TEXT", "lyrics_text");
                if (lText != null) {
                    String raw = (lText instanceof java.sql.Clob) ? clobToString((java.sql.Clob) lText) : lText.toString();
                    // [00:12.34] 같은 시간 태그 제거
                    doc.put("lyrics_text", raw.replaceAll("\\[\\d{2}:\\d{2}\\.\\d{2,3}\\]", "").trim());
                }
            }

            // 4. 변경사항이 있을 때만 ES 갱신
            if (!doc.isEmpty()) {
                esClient.update(new UpdateRequest("music_index", String.valueOf(mNo))
                        .doc(doc)
                        .docAsUpsert(true), RequestOptions.DEFAULT);
                System.out.println(">>> [ES 상세 업데이트 완료] m_no: " + mNo);
            }
        } catch (Exception e) {
            System.err.println("[ES 상세 UPDATE 에러] " + e.getMessage());
        }
    }
    
    // [중요] ES 검색 로직 개선 (ITZY 검색 안되는 문제 해결)
    public List<Map<String, Object>> esSuggest(String keyword, String searchType, int size) {
        if (keyword == null || keyword.trim().length() < 1) return new ArrayList<>();
        String q = keyword.trim();
        if (searchType == null) searchType = "ALL";

        try {
            SearchRequest request = new SearchRequest("music_index");
            SearchSourceBuilder source = new SearchSourceBuilder();
            source.size(size > 0 ? size : 10);

            BoolQueryBuilder qb = QueryBuilders.boolQuery();

            // [핵심] searchType에 따라 쿼리를 날릴 필드를 결정합니다.
            if (searchType.equals("ARTIST")) {
                qb.should(QueryBuilders.matchPhraseQuery("a_name", q).boost(100.0f));
                qb.should(QueryBuilders.matchQuery("a_name", q).fuzziness(Fuzziness.AUTO).boost(40.0f));
            } else if (searchType.equals("TITLE")) {
                qb.should(QueryBuilders.matchPhraseQuery("m_title", q).boost(100.0f));
                qb.should(QueryBuilders.matchQuery("m_title", q).fuzziness(Fuzziness.AUTO).boost(40.0f));
            } else if (searchType.equals("ALBUM")) {
                qb.should(QueryBuilders.matchPhraseQuery("b_title", q).boost(100.0f));
            } else {
                // ALL (전체 검색) - 기존 로직 유지
                qb.should(QueryBuilders.matchPhraseQuery("a_name", q).boost(100.0f));
                qb.should(QueryBuilders.matchPhraseQuery("m_title", q).boost(80.0f));
                qb.should(QueryBuilders.matchQuery("a_name", q).fuzziness(Fuzziness.AUTO).boost(40.0f));
                qb.should(QueryBuilders.matchQuery("m_title", q).fuzziness(Fuzziness.AUTO).boost(30.0f));
            }

            source.query(qb);
            source.fetchSource(new String[]{"m_no", "m_title", "a_name", "b_title"}, null);
            request.source(source);

            SearchResponse resp = esClient.search(request, RequestOptions.DEFAULT);
            List<Map<String, Object>> out = new ArrayList<>();
            for (SearchHit hit : resp.getHits().getHits()) {
                out.add(hit.getSourceAsMap());
            }
            return out;
        } catch (Exception e) {
            System.err.println("[ES ERROR] " + e.getMessage());
            return new ArrayList<>();
        }
    }

    // --- 기타 보조 메서드들 ---
    
    public List<MusicDTO> getMusicListByES(String keyword, String searchType, int uNo) {
        String normalizedKeyword = getNormalizedKeyword(keyword); 
        
        System.out.println(">>> 검색 시작: " + keyword + " -> 정규화: " + normalizedKeyword);

        // [수정] 원본 키워드(keyword)와 정규화 키워드(normalizedKeyword)를 모두 전달
        List<Integer> itunesMNoList = searchAndSave(keyword, normalizedKeyword, searchType);


        if (itunesMNoList != null && !itunesMNoList.isEmpty()) {
            return musicDAO.selectMusicByMNoList(itunesMNoList, uNo);
        }

        // 2. 결과 없을 시 ES 검색 (인자 3개 전달 필수!)
        List<Map<String, Object>> esResults = esSuggest(keyword, searchType, 30);
        
        if (esResults.isEmpty()) return new ArrayList<>();
        
        List<Integer> mNoList = esResults.stream()
                .map(m -> Integer.parseInt(m.get("m_no").toString()))
                .collect(Collectors.toList());
                
        return musicDAO.selectMusicByMNoList(mNoList, uNo);
    }
    
    private List<Map<String, Object>> fetchItunesList(String original, String normalized, String searchType) {
        try {
            // [수정 전략]
            // 1. 만약 원본이 'newjeans'라면 iTunes를 위해 'New Jeans'로 교정
            // 2. 그 외에는 정규화된 키워드(한글명 등)를 우선 사용하되, 검색어 합치기 방지
            String searchQuery = normalized; 
            
            if (original.toLowerCase().replaceAll("\\s+", "").equals("newjeans")) {
                searchQuery = "New Jeans"; // iTunes API가 가장 잘 인식하는 형태
            } else if (original.length() > normalized.length()) {
                searchQuery = original; // 영문명이 더 정보가 많을 경우
            }

            String encoded = URLEncoder.encode(searchQuery, StandardCharsets.UTF_8.toString());
            String attribute = "";
            if ("ARTIST".equals(searchType)) attribute = "&attribute=artistTerm";
            else if ("TITLE".equals(searchType)) attribute = "&attribute=songTerm";
            else if ("ALBUM".equals(searchType)) attribute = "&attribute=albumTerm";

            String url = "https://itunes.apple.com/search?term=" + encoded 
                    + "&country=KR&media=music&entity=song&limit=30" + attribute; // limit을 30정도로 늘려주는 게 좋습니다.
         
         System.out.println(">>> iTunes API Request: " + url);

            RestTemplate rt = new RestTemplate();
            
            // [중요!] iTunes 특유의 응답 타입을 처리하기 위한 설정
            MappingJackson2HttpMessageConverter converter = new MappingJackson2HttpMessageConverter();
            converter.setSupportedMediaTypes(Arrays.asList(
                MediaType.APPLICATION_JSON, 
                new MediaType("text", "javascript", StandardCharsets.UTF_8)
            ));
            rt.getMessageConverters().add(0, converter);

            Map<String, Object> resp = rt.getForObject(url, Map.class);
            
            // 결과 꺼내기
            List<Map<String, Object>> results = (List<Map<String, Object>>) resp.get("results");
            
            // 여기에 로그를 하나 추가해서 실제로 몇 개 넘어오는지 확인하세요!
            System.out.println(">>> iTunes API Actual Results Count: " + (results != null ? results.size() : 0));
            
            return results != null ? results : new ArrayList<>();
        } catch (Exception e) {
            System.err.println(">>> iTunes API Error: " + e.getMessage());
            return new ArrayList<>();
        }
    }

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

    private Object getValue(Map<String, Object> map, String upper, String lower) {
        return map.containsKey(upper) ? map.get(upper) : map.get(lower);
    }

    private String clobToString(java.sql.Clob clob) throws Exception {
        return clob.getSubString(1, (int) clob.length());
    }

    public List<MusicDTO> getMusicListByTitle(String k, int u) { return musicDAO.selectMusicByTitle(k, u); }
    public List<MusicDTO> getMusicListByArtist(String k, int u) { return musicDAO.selectMusicByArtist(k, u); }
    public List<MusicDTO> getMusicListByAlbum(String k, int u) { return musicDAO.selectMusicByAlbum(k, u); }
    public List<MusicDTO> getMusicListByLyrics(String k, int u) { return musicDAO.selectMusicByLyrics(k, u); }

    public Integer getMNoByTitleAndArtist(String t, String a) {
        return musicDAO.selectMNoByTitleAndArtist(t, a);
    }
    
 // [추가] Elasticsearch를 이용한 키워드 정규화 (동의어 처리)
    public String getNormalizedKeyword(String keyword) {
        try {
            org.elasticsearch.client.indices.AnalyzeRequest request = 
                org.elasticsearch.client.indices.AnalyzeRequest.withIndexAnalyzer("music_index", "ko_search_analyzer", keyword);

            org.elasticsearch.client.indices.AnalyzeResponse response = 
                esClient.indices().analyze(request, RequestOptions.DEFAULT);

            List<org.elasticsearch.client.indices.AnalyzeResponse.AnalyzeToken> tokens = response.getTokens();
            if (tokens == null || tokens.isEmpty()) return keyword;

            // 명시적으로 우리가 등록한 동의어(SYNONYM) 타입만 추출
            List<String> synonyms = tokens.stream()
                    .filter(t -> "SYNONYM".equals(t.getType()))
                    .map(t -> t.getTerm())
                    .collect(Collectors.toList());

            if (!synonyms.isEmpty()) {
                // 가장 긴 단어를 대표 키워드로 선택 (ex: 레벨 -> redvelvet)
                return synonyms.stream().max(Comparator.comparingInt(String::length)).get();
            }

            // 동의어가 아니라면 (예: 인명 '강다니엘'이 'daniel'로 분석된 경우 등)
            // 분석된 토큰을 무시하고 사용자 입력 원본(강다니엘)을 그대로 사용
            return keyword; 

        } catch (Exception e) {
            System.err.println(">>> 키워드 정규화 실패: " + e.getMessage());
            return keyword;
        }
    }
 // [추가] 트렌드 음악 재생 시 로그 기록 (곡이 없으면 자동 저장)
    @Transactional
    public void recordPlayLog(String title, String artist, String imgUrl, int uNo) {
        // 1. 곡 존재 여부 확인 후 없으면 saveNewMusicInfo 호출 (이미 구현된 로직 사용)
        Integer mNo = musicDAO.selectMNoByTitleAndArtist(title, artist);
        if (mNo == null || mNo == 0) {
            Map<String, Object> mockItunes = new HashMap<>();
            mockItunes.put("trackName", title);
            mockItunes.put("artistName", artist);
            mockItunes.put("artworkUrl100", imgUrl);
            mockItunes.put("collectionName", "K-POP TREND");
            saveNewMusicInfo(null, mockItunes, title, artist, null);
            mNo = musicDAO.selectMNoByTitleAndArtist(title, artist);
        }

        // 2. 실시간 차트 반영을 위한 History 저장 (이게 핵심!)
        if (mNo != null && mNo > 0) {
            HistoryDTO history = new HistoryDTO();
            history.setU_no(uNo);
            history.setM_no(mNo);
            // 날씨나 위치 정보는 선택 사항 (기본값 설정 가능)
            musicDAO.insertHistory(history); 
        }
    }
    
    @Transactional
    public void recordPlayLogWithWeather(String title, String artist, String imgUrl, int uNo, int weatherId, String location, Double lat, Double lon) {
        // 1. 기존 곡 조회
        Integer mNo = musicDAO.selectMNoByTitleAndArtist(title, artist);
        
        // 2. 검색 결과가 없으면 (m_no가 null이면)
        if (mNo == null || mNo == 0) {
            System.out.println(">>> DB에 곡이 없어 새로 등록을 시도합니다: " + title);
            
            Map<String, Object> trackData = new HashMap<>();
            trackData.put("trackName", title);
            trackData.put("artistName", artist);
            trackData.put("artworkUrl100", imgUrl);

            // [중요] 이 메서드 내부에서 insertArtist, insertAlbum, insertMusic이 순서대로 실행됩니다.
            // 메서드가 성공적으로 끝나면 다시 검색해서 mNo를 가져옵니다.
            saveNewMusicInfo(null, trackData, title, artist, null);
            
            // 다시 가져오기 (이때도 안 온다면 insert 자체가 실패한 것)
            mNo = musicDAO.selectMNoByTitleAndArtist(title, artist);
        }

        // 3. mNo가 있으면 히스토리 저장
        if (mNo != null && mNo > 0) {
            HistoryDTO dto = new HistoryDTO();
            dto.setU_no(uNo);
            dto.setM_no(mNo);
            dto.setH_weather(weatherId);
            dto.setH_location(location);
            dto.setH_lat(lat != null ? lat : 0.0);
            dto.setH_lon(lon != null ? lon : 0.0);
            
            musicDAO.insertHistory(dto);
            System.out.println(">>> [성공] 히스토리 저장 완료 (M_NO: " + mNo + ")");
        } else {
            // 이 로그가 찍히면 saveNewMusicInfo 내부 로직을 점검해야 합니다.
            System.out.println(">>> [경고] 곡 등록 시도 후에도 mNo를 가져오지 못함.");
        }
    }
}