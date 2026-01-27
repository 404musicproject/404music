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

import com.project.springboot.dao.IMusicDAO;
import com.project.springboot.dto.HistoryDTO;
import com.project.springboot.dto.MusicDTO;
import com.project.springboot.service.MusicService;
import com.project.springboot.service.YouTubeApiService;

@RestController
@RequestMapping("/api/music")
public class MusicController {
    
    @Autowired private MusicService musicService;
    @Autowired private IMusicDAO musicDAO;
    @Autowired private YouTubeApiService youtubeService;

    // 1. 검색 및 수집 (Spotify 기반으로 변경됨)
    @GetMapping("/search")
    public ResponseEntity<List<MusicDTO>> searchMusic(@RequestParam("keyword") String keyword) {
        // [수정] 이제 내부에서 Spotify 검색 -> 중복체크 -> iTunes 보완 -> DB/ES 저장이 일어납니다.
        musicService.searchAndSave(keyword);
        
        // 검색된 키워드로 DB에서 최신 목록 반환
        List<MusicDTO> list = musicService.getMusicListByKeyword(keyword);
        return ResponseEntity.ok(list);
    }

    // 2. 노래 상세 조회 (중요: 여기서 가사, 수치, ES 업데이트가 처리됨)
    @GetMapping("/detail")
    public ResponseEntity<Map<String, Object>> getMusicDetail(@RequestParam("m_no") int m_no) {
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

    // 4. 실시간 TOP 100 조회
    @GetMapping("/top100")
    public ResponseEntity<List<Map<String, Object>>> getTop100(@RequestParam(value="u_no", defaultValue="0") int u_no) {
        List<Map<String, Object>> top100 = musicDAO.selectTop100Music(u_no);
        return ResponseEntity.ok(top100);
    }

    // 5. 재생 로그 저장
    @PostMapping("/history")
    public ResponseEntity<String> saveHistory(HistoryDTO history) {
        try {
            if (history.getU_no() == 0) history.setU_no(0); 
            musicDAO.insertHistory(history);
            return ResponseEntity.ok("success");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("fail");
        }
    }

    // 6. 좋아요 토글
    @PostMapping("/toggle-like")
    @ResponseBody
    public Map<String, Object> toggleLike(
            @RequestParam("m_no") int m_no, 
            @RequestParam("u_no") int u_no) {
        
        Map<String, Object> result = new HashMap<>();
        try {
            if (u_no <= 0) {
                result.put("status", "error");
                return result;
            }

            int count = musicDAO.checkLike(u_no, m_no);
            if (count > 0) {
                musicDAO.deleteLike(u_no, m_no);
                result.put("status", "unliked");
            } else {
                musicDAO.insertLike(u_no, m_no);
                result.put("status", "liked");
            }
        } catch (Exception e) {
            result.put("status", "error");
        }
        return result;
    }

    /* [삭제 제안] /update-extra 
       이유: 이제 searchAndSave 단계에서 iTunes 정보를 함께 수집하므로 
       프론트엔드에서 별도로 이 API를 호출할 필요가 없어졌습니다. 
    */
}
