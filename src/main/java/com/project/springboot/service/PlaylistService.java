package com.project.springboot.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.project.springboot.dao.IPlaylistDAO;
import com.project.springboot.dto.LibrarySongDTO;
import com.project.springboot.dto.PlaylistDTO;
import com.project.springboot.dto.PlaylistTrackViewDTO;

@Service
public class PlaylistService {

    @Autowired
    private IPlaylistDAO playlistDAO;

    // ==========================================
    // 1. 플레이리스트 관리 (생성, 조회, 삭제)
    // ==========================================

    // 내 플레이리스트 목록
    public List<PlaylistDTO> getMyPlaylists(Long uNo) {
        return playlistDAO.selectPlaylistsByUser(uNo);
    }

    // 플레이리스트 1개 정보 조회 (상세페이지용)
    public PlaylistDTO getPlaylistInfo(Long tNo) {
        return playlistDAO.selectPlaylistById(tNo);
    }

    // 플레이리스트 생성
    @Transactional
    public void createPlaylist(Long uNo, String title, Long coverMNo) {
        PlaylistDTO dto = new PlaylistDTO();
        dto.setuNo(uNo);
        dto.settTitle(title);
        
        // [필수] DB 컬럼이 NOT NULL이므로 기본값 설정
        dto.settPrivate("N"); // 공개 여부 (N: 공개)
        dto.settSaved("N");   // 저장 여부 (N: 미저장)

        // [주의] 커버 이미지가 없으면 기본값으로 1번 곡을 사용합니다.
        // 만약 DB에 m_no가 1인 곡이 없으면 에러가 나므로, 실제 존재하는 곡 번호로 바꾸세요.
        dto.setmNo(coverMNo != null ? coverMNo : 1L); 
        
        playlistDAO.insertPlaylist(dto);
    }

    // 플레이리스트 삭제 (수록곡 먼저 지우고 본체 삭제)
    @Transactional
    public void deletePlaylist(Long tNo) {
        playlistDAO.deletePlaylistTracks(tNo); // 안에 든 곡들 삭제
        playlistDAO.deletePlaylist(tNo);       // 껍데기 삭제
    }

    // ==========================================
    // 2. 수록곡 관리 (목록, 추가, 삭제)
    // ==========================================

    // 플레이리스트 안의 곡 목록 조회
    public List<PlaylistTrackViewDTO> getPlaylistTracks(Long tNo) {
        return playlistDAO.selectPlaylistTracks(tNo);
    }

    // [중요] 플레이리스트에 곡 담기 (순서 자동 계산)
    @Transactional
    public void addTrackToPlaylist(Long tNo, Long mNo) {
        // 1. 마지막 순서 번호 가져오기 (1, 2, 3...)
        Integer nextOrder = playlistDAO.selectNextOrder(tNo);
        if (nextOrder == null) nextOrder = 1;

        // 2. 곡 추가
        playlistDAO.insertPlaylistTrack(tNo, mNo, nextOrder);
    }

    // 플레이리스트에서 곡 빼기
    @Transactional
    public void removeTrack(Long ptNo) {
        playlistDAO.deletePlaylistTrack(ptNo);
    }

    // ==========================================
    // 3. 좋아요(라이브러리) 관리
    // ==========================================

    // 찜한 노래 목록
    public List<LibrarySongDTO> getLikedSongs(Long uNo) {
        return playlistDAO.selectLikedSongs(uNo);
    }

    // 좋아요 추가/취소 (토글 기능 - 단순)
    @Transactional
    public void likeSong(Long uNo, Long mNo) {
        try {
            playlistDAO.insertLikeSong(uNo, mNo);
        } catch (Exception e) {
            // 이미 좋아요 상태면 무시
        }
    }

    @Transactional
    public void unlikeSong(Long uNo, Long mNo) {
        playlistDAO.deleteLikeSong(uNo, mNo);
    }
    
    // 좋아요 상태 확인 및 토글 (Controller 편의용 - 스마트 토글)
    @Transactional
    public String toggleLike(Long uNo, Long mNo) {
        // 삭제를 먼저 시도해보고(영향받은 행이 1개면 삭제 성공 -> unliked)
        // 삭제된 게 없으면(0개면) 추가(insert -> liked)
        int deleted = playlistDAO.deleteLikeSong(uNo, mNo);
        if (deleted > 0) {
            return "unliked";
        } else {
            playlistDAO.insertLikeSong(uNo, mNo);
            return "liked";
        }
    }
}