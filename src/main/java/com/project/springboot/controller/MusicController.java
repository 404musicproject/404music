package com.project.springboot.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
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

    // 1. 검색 및 수집
    @GetMapping("/search")
    public ResponseEntity<List<MusicDTO>> searchMusic(@RequestParam("keyword") String keyword) {
        // iTunes에서 수집 및 저장
        musicService.searchAndSave(keyword);
        // DB에서 조회된 결과 반환
        List<MusicDTO> list = musicService.getMusicListByKeyword(keyword);
        return ResponseEntity.ok(list);
    }

    // 2. 유튜브 ID 업데이트 (클릭 시 실행)
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

    // 3. 실시간 TOP 100 조회 (신규 추가)
    @GetMapping("/top100")
    public ResponseEntity<List<Map<String, Object>>> getTop100(@RequestParam(value="u_no", defaultValue="0") int u_no) {
        // JSP에서 던져준 u_no를 DAO의 selectTop100Music(u_no)에 전달합니다.
        List<Map<String, Object>> top100 = musicDAO.selectTop100Music(u_no);
        return ResponseEntity.ok(top100);
    }

    // 4. 재생 로그 저장 (기존 @RequestBody 방식에서 일반 폼 전송 방식으로도 가능하게 보강)
    @PostMapping("/history")
    public ResponseEntity<String> saveHistory(HistoryDTO history) {
        try {
            // u_no가 없거나 null이면 비회원(0번)으로 강제 설정
            if (history.getU_no() == 0) {
                history.setU_no(0); 
            }
            
            musicDAO.insertHistory(history);
            System.out.println("[차트 반영] 곡 번호 " + history.getM_no() + " 재생 기록됨");
            return ResponseEntity.ok("success");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("fail: " + e.getMessage());
        }
    }
    // [신규 추가] 5. iTunes 추가 정보 업데이트 (미리듣기, 앨범아트, 장르)
    @PostMapping("/update-extra")
    public ResponseEntity<String> updateExtraInfo(@RequestParam Map<String, Object> params) {
        try {
            // JavaScript에서 m_no를 보낼 때 String으로 올 수 있으므로 처리
            int m_no = Integer.parseInt(String.valueOf(params.get("m_no")));
            
            // 서비스 호출하여 여러 테이블(music, album, artists) 동시 업데이트
            musicService.updateMusicExtraInfo(params);
            
            System.out.println("[데이터 보정] 곡 번호 " + m_no + " iTunes 정보 업데이트 완료");
            return ResponseEntity.ok("success");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("fail: " + e.getMessage());
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
}
