package com.project.springboot.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import com.project.springboot.dao.IMusicDAO;
import com.project.springboot.dto.HistoryDTO;
import com.project.springboot.dto.MusicDTO;
import com.project.springboot.dto.UserDTO;
import com.project.springboot.service.MusicService;
import com.project.springboot.service.YouTubeApiService;

import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/music")
public class MusicController {
    
    @Autowired private MusicService musicService;
    @Autowired private IMusicDAO musicDAO;
    @Autowired private YouTubeApiService youtubeService;

    @Value("${weather.api.key}")
    private String weatherApiKey;

    @Autowired
    private RestTemplate restTemplate;
    // 1. 검색 및 수집
    @GetMapping("/search")
    public ResponseEntity<List<MusicDTO>> searchMusic(
            @RequestParam("keyword") String keyword, 
            @RequestParam(value="searchType", defaultValue="ALL") String searchType,
            HttpSession session) {
        
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        int uNo = (user != null) ? user.getUNo() : 0; 

        // [중요 수정] 서비스의 getMusicListByES 안에서 
        // "백예린"과 "thevolunteers"를 합치도록 설계했으므로, 
        // 여기서는 keyword만 던지면 서비스 내부의 getNormalizedKeyword가 알아서 처리합니다.
        List<MusicDTO> list = musicService.getMusicListByES(keyword, searchType, uNo); 
        
        return ResponseEntity.ok(list);
    }
    
 // 1-1. 수집 전용 버튼용
    @PostMapping("/register")
    public ResponseEntity<String> registerMusic(
            @RequestParam("keyword") String keyword,
            @RequestParam(value="searchType", defaultValue="ALL") String searchType) {
        try {
            if (keyword == null || keyword.trim().isEmpty()) {
                return ResponseEntity.badRequest().body("empty");
            }
            
            // [수정] Service의 searchAndSave가 (original, normalized, type) 3개를 받도록 고쳤다면:
            // 여기서도 두 번 인자를 넣어줍니다. (정규화는 서비스 내부에서 처리하거나 직접 호출)
            // 일단 안전하게 searchAndSave 내부에서 정규화 로직을 타게 하려면 아래처럼 수정하세요.
            musicService.searchAndSave(keyword, keyword, searchType); 
            
            return ResponseEntity.ok("success");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("fail");
        }
    }
    
    // 2. 노래 상세 조회 (중요: 여기서 가사, 수치, ES 업데이트가 처리됨)
    @GetMapping("/detail")
    public ResponseEntity<Map<String, Object>> getMusicDetail(@RequestParam("m_no") int m_no) {
    	System.out.println("상세조회 요청 m_no: " + m_no); // 로그 추가
    	
        // [로직] DB에 데이터가 없으면 Spotify에서 즉시 수집하여 채워주는 지연 로딩 로직
        Map<String, Object> detail = musicService.getOrFetchMusicDetail(m_no);
        
        if (detail == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(detail);
    }

    
    // 3. 유튜브 ID 업데이트 (클릭 시 실행)
    @GetMapping("/update-youtube")
    public ResponseEntity<String> updateYoutube(
        @RequestParam("m_no") int m_no, 
        @RequestParam("title") String title
    ) {
        String videoId = youtubeService.searchYouTube(title);
        if (videoId != null) {
            musicDAO.updateYoutubeId(m_no, videoId); 
            return ResponseEntity.ok(videoId);
        }
        return ResponseEntity.ok("fail");
    }

    // 4. 실시간 TOP 100 조회 (신규 추가)
    @GetMapping("/top100")
    public ResponseEntity<List<Map<String, Object>>> getTop100(@RequestParam(value="u_no", defaultValue="0") int u_no) {
        List<Map<String, Object>> top100 = musicDAO.selectTop100Music(u_no);
        
        // DB 데이터가 부족하면 Apple RSS 데이터를 가져와서 합쳐줌
        if (top100 == null || top100.isEmpty()) {
            return getRssMostPlayed("kr", 100); 
        }
        
        return ResponseEntity.ok(top100);
    }
    
    @GetMapping("/weekly")
    public ResponseEntity<List<Map<String, Object>>> getWeekly(@RequestParam(value="u_no", defaultValue="0") int u_no) {
        // DAO에 selectWeeklyMusic 메서드가 있어야 합니다.
        return ResponseEntity.ok(musicDAO.selectWeeklyMusic(u_no));
    }

    // 2. 월간 데이터 통로
    @GetMapping("/monthly")
    public ResponseEntity<List<Map<String, Object>>> getMonthly(@RequestParam(value="u_no", defaultValue="0") int u_no) {
        // DAO에 selectMonthlyMusic 메서드가 있어야 합니다.
        return ResponseEntity.ok(musicDAO.selectMonthlyMusic(u_no));
    }

    // 3. 연간 데이터 통로
    @GetMapping("/yearly")
    public ResponseEntity<List<Map<String, Object>>> getYearly(@RequestParam(value="u_no", defaultValue="0") int u_no) {
        // DAO에 selectYearlyMusic 메서드가 있어야 합니다.
        return ResponseEntity.ok(musicDAO.selectYearlyMusic(u_no));
    }
    
    
    //5.지역별 순위
    @GetMapping("/regional")
    public ResponseEntity<List<Map<String, Object>>> getRegionalChart(
            @RequestParam(value="u_no", defaultValue="0") int u_no,
            @RequestParam(value="city", required=false) String city) {
        
        // DAO에 city를 파라미터로 넘겨 해당 지역의 1~100위까지 가져오는 메서드 필요
        List<Map<String, Object>> list = musicDAO.selectRegionalMusic(u_no, city);
        return ResponseEntity.ok(list);
    }
    
    // 6. 재생 로그 저장 (기존 @RequestBody 방식에서 일반 폼 전송 방식으로도 가능하게 보강)


    @PostMapping("/history")
    public ResponseEntity<String> saveHistory(HistoryDTO history) {
        try {
            // 1. 좌표가 있을 때만 날씨 정보를 숫자로 가져옴
            if (history.getH_lat() != 0 && history.getH_lon() != 0) {
                try {
                    String url = "https://api.openweathermap.org/data/2.5/weather?lat=" + history.getH_lat() 
                               + "&lon=" + history.getH_lon() + "&appid=" + weatherApiKey + "&units=metric";
                    
                    Map<String, Object> response = restTemplate.getForObject(url, Map.class);
                    
                    if (response != null) {
                        // API 응답에서 'id' (예: 800) 값을 꺼냅니다.
                        List<Map<String, Object>> weatherList = (List<Map<String, Object>>) response.get("weather");
                        
                        // 핵심: 받아온 값을 int로 변환해서 set 합니다.
                        // 이렇게 하면 DTO를 바꿀 필요가 전혀 없습니다!
                        Object idObj = weatherList.get(0).get("id");
                        int weatherId = Integer.parseInt(String.valueOf(idObj)); 

                        history.setH_weather(weatherId); // 기존 int 필드 그대로 사용
                        history.setH_location(String.valueOf(response.get("name")));
                    }
                } catch (Exception e) {
                    // 에러 나면 기존에 쓰시던 기본값(800) 세팅
                    history.setH_weather(800);
                }
            }

            // 2. 로그 확인 (정상적으로 숫자가 찍힐 겁니다)
            System.out.println("[차트 반영] 곡:" + history.getM_no() + " | 날씨ID:" + history.getH_weather());

            musicDAO.insertHistory(history);
            return ResponseEntity.ok("success");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("fail");
        }
    }
   
    @PostMapping("/toggle-like")
    @ResponseBody
    public Map<String, Object> toggleLike(
            @RequestParam("m_no") int m_no, 
            @RequestParam("u_no") int u_no) {
        
        Map<String, Object> result = new HashMap<>();
        try {
            // 1. 유저 존재 여부 및 유효성 체크
            if (u_no <= 0) {
                result.put("status", "error");
                return result;
            }

            // 2. 좋아요 여부 확인 (l_target_type='MUSIC', l_target_no=m_no)
            int count = musicDAO.checkLike(u_no, m_no);
            
            if (count > 0) {
                musicDAO.deleteLike(u_no, m_no);
                result.put("status", "unliked");
            } else {
                musicDAO.insertLike(u_no, m_no);
                result.put("status", "liked");
            }
        } catch (Exception e) {
            e.printStackTrace(); // ★ 서버 콘솔에 빨간 글씨로 에러 원인이 찍힙니다. 꼭 확인하세요!
            result.put("status", "error");
        }
        return result;
    }
    
    
    @GetMapping("/rss/most-played")
    public ResponseEntity<List<Map<String, Object>>> getRssMostPlayed(
            @RequestParam(value="storefront", defaultValue="kr") String storefront,
            @RequestParam(value="limit", defaultValue="10") int limit
    ) {
        try {
            String url =
                "https://rss.applemarketingtools.com/api/v2/"
                + storefront.toLowerCase()
                + "/music/most-played/"
                + limit
                + "/songs.json";

            RestTemplate rt = new RestTemplate();
            Map<String, Object> root = rt.getForObject(url, Map.class);

            if (root == null || root.get("feed") == null) {
                return ResponseEntity.ok(List.of());
            }

            Map<String, Object> feed = (Map<String, Object>) root.get("feed");
            List<Map<String, Object>> results = (List<Map<String, Object>>) feed.get("results");

            if (results == null) return ResponseEntity.ok(List.of());

            // home.jsp가 바로 쓰기 쉽도록 기존 키 형태(TITLE/ARTIST/ALBUM_IMG)로 변환
            List<Map<String, Object>> out = results.stream().map(r -> {
                Map<String, Object> m = new HashMap<>();
                m.put("MNO", 0); // 클릭 시 title로 검색 이동만 할 거라 의미없음
                m.put("TITLE", r.get("name"));
                m.put("ARTIST", r.get("artistName"));
                m.put("ALBUM_IMG", r.get("artworkUrl100"));
                m.put("URL", r.get("url"));
                return m;
            }).toList();

            return ResponseEntity.ok(out);

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Apple API 호출 실패(무시하고 진행): " + e.getMessage());
            return ResponseEntity.ok(java.util.Collections.emptyList());
        }
    }
    
    @GetMapping("/youtube-search")
    public ResponseEntity<Map<String, Object>> youtubeSearch(
            @RequestParam("q") String q,
            @RequestParam(value="title", required=false) String title, // JS에서 보내주는 제목
            @RequestParam(value="artist", required=false) String artist // JS에서 보내주는 아티스트
    ) {
        Map<String, Object> result = new HashMap<>();

        // 1. 유튜브 비디오 ID 검색
        String videoId = youtubeService.searchYouTube(q);
        result.put("videoId", videoId != null ? videoId : "fail");

        // 2. 방금 확인한 XML 쿼리를 호출하여 m_no 획득
        // title과 artist 파라미터가 있어야 DAO가 작동하므로 @RequestParam에 포함시켰습니다.
        Integer mNo = musicDAO.selectMNoByTitleAndArtist(title, artist);
        result.put("mNo", (mNo != null) ? mNo : 0);

        return ResponseEntity.ok(result);
    }
   
    @PostMapping("/add-library")
    public ResponseEntity<String> addLibrary(@RequestParam("m_no") int mNo, @RequestParam("u_no") int uNo) {
        try {
            // 이미 보관함에 있는지 체크하는 로직을 넣으면 더 좋습니다.
            musicDAO.insertLibraryTrack(uNo, mNo);
            return ResponseEntity.ok("success");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("fail");
        }
    }

    
    @PostMapping("/remove-library")
    public ResponseEntity<String> removeLibrary(@RequestParam("m_no") int mNo, @RequestParam("u_no") int uNo) {
        try {
            musicDAO.deleteLibraryTrack(uNo, mNo);
            return ResponseEntity.ok("success");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("fail");
        }
    }



/**
 * 헤더 검색창 자동완성(2글자 이상) - Elasticsearch 기반
 * 호출 예: /api/music/es-suggest?q=아이유
 */
    @GetMapping("/es-suggest")
    public ResponseEntity<List<Map<String, Object>>> getEsSuggest(
            @RequestParam("q") String q,
            @RequestParam(value = "searchType", defaultValue = "ALL") String searchType, // ← 파라미터 추가!
            @RequestParam(value = "size", defaultValue = "10") int size) {
        
        // Service 호출 시 searchType도 같이 넘겨줍니다.
        return ResponseEntity.ok(musicService.esSuggest(q, searchType, size));
    }
    
    @PostMapping("/logHistoryAuto")
    @ResponseBody
    public String logHistoryAuto(@RequestParam String title, @RequestParam String artist, HttpSession session) {
        // 1. 먼저 DB에 있는지 확인
        Integer mNo = musicService.getMNoByTitleAndArtist(title, artist);

        if (mNo == null || mNo == 0) {
            System.out.println(">>> DB에 없는 곡 발견, 자동 수집 시작: " + title);
            
            // 검색어 생성 (예: "Square 백예린")
            String query = title + " " + artist;
            
            // [핵심 수정] 3개 인자 체계에 맞게 호출
            // 상세 검색 시에는 original과 normalized를 굳이 나눌 필요 없이 
            // 합쳐진 쿼리를 두 곳에 모두 넣어주어 iTunes가 정확한 결과를 찾게 합니다.
            musicService.searchAndSave(query, query, "ALL"); 
            
            // 재조회
            mNo = musicService.getMNoByTitleAndArtist(title, artist); 
        }

        if (mNo != null && mNo > 0) {
            // [추가 작업] 세션에서 uNo 가져와서 history insert 로직 진행
            UserDTO user = (UserDTO) session.getAttribute("loginUser");
            if (user != null) {
                HistoryDTO dto = new HistoryDTO();
                dto.setU_no(user.getUNo());
                dto.setM_no(mNo);
                // ... 나머지 필드 세팅 및 musicDAO.insertHistory(dto) 호출 ...
            }
            return "SUCCESS";
        }
        return "NOT_FOUND_AFTER_RETRY";
    }
    
 // MusicController.java 내부에 추가
    @GetMapping("/weather")
    public ResponseEntity<?> getWeather(@RequestParam("lat") String lat, @RequestParam("lon") String lon) {
        try {
            // 클라이언트에서 넘겨준 좌표로 OpenWeatherMap 호출
            String url = "https://api.openweathermap.org/data/2.5/weather?lat=" + lat 
                       + "&lon=" + lon + "&appid=" + weatherApiKey + "&units=metric";
            
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);
            
            if (response == null) {
                return ResponseEntity.badRequest().body("날씨 정보를 가져올 수 없습니다.");
            }
            
            // 브라우저로 날씨 데이터 반환
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("날씨 API 호출 실패");
        }
    }
    
 // 기존의 @PostMapping("/log")가 붙은 다른 메서드는 반드시 지우세요!

    @PostMapping("/log")
    @ResponseBody
    public String logMusicPlay(
            @RequestParam String title, 
            @RequestParam String artist, 
            @RequestParam String albumImg,
            @RequestParam(value="h_lat", required=false) Double lat,
            @RequestParam(value="h_lon", required=false) Double lon,
            HttpSession session) {
        
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        if (user == null) return "LOGIN_REQUIRED";

        int weatherId = 800; 
        String locationName = "Unknown";

        // [1] 날씨 가져오기 (기존 로직 유지)
        if (lat != null && lon != null && lat != 0) {
            // ... OpenWeather API 호출 ...
        }

        // [2] 서비스 호출 시 "곡이 없으면 등록까지 해라"라고 명령
        // 파라미터에 lat, lon도 꼭 포함해서 넘겨주세요.
        musicService.recordPlayLogWithWeather(title, artist, albumImg, user.getUNo(), weatherId, locationName, lat, lon);
        
        return "SUCCESS";
    }
 // MusicController.java에 추가하면 좋은 메서드
    @GetMapping("/check-like-status")
    public ResponseEntity<Boolean> checkLikeStatus(@RequestParam("m_no") int mNo, HttpSession session) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        if (user == null) return ResponseEntity.ok(false);
        
        int count = musicDAO.checkLike(user.getUNo(), mNo);
        return ResponseEntity.ok(count > 0);
    }
    
}
