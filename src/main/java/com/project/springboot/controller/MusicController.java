package com.project.springboot.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
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
import org.springframework.beans.factory.annotation.Value;

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
    public ResponseEntity<List<MusicDTO>> searchMusic(@RequestParam("keyword") String keyword, HttpSession session) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        int uNo = (user != null) ? user.getUNo() : 0; 

        musicService.searchAndSave(keyword); // 수집 로직
        List<MusicDTO> list = musicService.getMusicListByKeyword(keyword, uNo); // uNo 전달!
        return ResponseEntity.ok(list);
    }

    // 1-1. (SearchResult.jsp의 AUTO REGISTER 버튼용) 키워드 기반 수집만 수행
    @PostMapping("/register")
    public ResponseEntity<String> registerMusic(@RequestParam("keyword") String keyword) {
        try {
            if (keyword == null || keyword.trim().isEmpty()) {
                return ResponseEntity.badRequest().body("empty");
            }
            musicService.searchAndSave(keyword);
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
        // JSP에서 던져준 u_no를 DAO의 selectTop100Music(u_no)에 전달합니다.
        List<Map<String, Object>> top100 = musicDAO.selectTop100Music(u_no);
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
    
    
 // MusicController.java의 해당 메서드 부분을 잠시 이렇게 바꿔보세요.
    @GetMapping("/rss/new-releases")
    public ResponseEntity<List<Map<String, Object>>> getRssNewReleases() {
        try {
            // [수정] limit을 변수로 처리하여 주소를 유연하게 만듭니다.
            int limit = 8;
            String url = "https://rss.applemarketingtools.com/api/v2/kr/music/most-played/" + limit + "/songs.json";

            RestTemplate rt = new RestTemplate();
            // Apple 서버가 500 에러를 낼 경우를 대비해 예외 처리를 감쌉니다.
            Map<String, Object> root = rt.getForObject(url, Map.class);
            
            if (root == null || !root.containsKey("feed")) return ResponseEntity.ok(List.of());

            Map<String, Object> feed = (Map<String, Object>) root.get("feed");
            List<Map<String, Object>> results = (List<Map<String, Object>>) feed.get("results");

            if (results == null) return ResponseEntity.ok(List.of());

            // 정확히 8개만 잘라서 반환
            List<Map<String, Object>> out = results.stream()
                .limit(limit)
                .map(r -> {
                    Map<String, Object> m = new HashMap<>();
                    m.put("TITLE", r.get("name"));
                    m.put("ARTIST", r.get("artistName"));
                    m.put("ALBUM_IMG", r.get("artworkUrl100"));
                    return m;
                }).toList();

            return ResponseEntity.ok(out);
        } catch (Exception e) {
            // Apple 서버가 500 에러를 내면 여기로 들어옵니다.
            System.err.println("Apple 서버 응답 오류(500 등): " + e.getMessage());
            return ResponseEntity.ok(List.of()); // 에러 시 빈 리스트 반환
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
    @GetMapping("/music/myLibrary")
    public String myLibrary(HttpSession session, Model model) {
        UserDTO user = (UserDTO) session.getAttribute("loginUser");
        if (user == null) return "redirect:/login";

        List<MusicDTO> libraryList = musicDAO.selectMusicByLibrary(user.getUNo());
        model.addAttribute("libraryList", libraryList);
        
        // guest/가 아니라 user/ 폴더 안에 만드셨으므로 경로 수정!
        return "user/MyLibrary"; 
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

}