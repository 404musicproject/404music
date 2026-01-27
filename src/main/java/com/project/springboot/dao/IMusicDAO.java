package com.project.springboot.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.project.springboot.dto.AlbumDTO;
import com.project.springboot.dto.ArtistDTO;
import com.project.springboot.dto.HistoryDTO;
import com.project.springboot.dto.MusicDTO;

@Mapper
public interface IMusicDAO {
    // 1. 데이터 저장 (iTunes 수집용)
    int insertArtist(ArtistDTO artistDTO);
    int insertAlbum(AlbumDTO albumDTO);
    int insertMusic(MusicDTO musicDTO);
    
    // 2. 검색 및 업데이트
    int updateYoutubeId(@Param("m_no") int m_no, @Param("m_youtube_id") String m_youtube_id);
    List<MusicDTO> selectMusicByKeyword(String keyword);
    
    // 3. 히스토리(재생기록) 저장
    int insertHistory(HistoryDTO historyDTO);
    
    // 4. TOP 100 차트 조회 (로그인한 유저의 좋아요 여부 포함)
    List<Map<String, Object>> selectTop100Music(@Param("u_no") int u_no);
    List<Map<String, Object>> selectWeeklyMusic(int u_no);  // 주간
    List<Map<String, Object>> selectMonthlyMusic(int u_no); // 월간
    List<Map<String, Object>> selectYearlyMusic(int u_no);  // 연간
    // 5. 좋아요(Likes) 기능
    int checkLike(@Param("u_no") int u_no, @Param("m_no") int m_no);
    void insertLike(@Param("u_no") int u_no, @Param("m_no") int m_no);
    void deleteLike(@Param("u_no") int u_no, @Param("m_no") int m_no);

    // 6. iTunes 추가 정보 실시간 업데이트
    void updateMusicPreview(Map<String, Object> params);
    void updateAlbumImage(Map<String, Object> params);
    void updateArtistGenre(Map<String, Object> params);
    
    List<Map<String, Object>> selectRegionalMusic(@Param("u_no") int u_no, @Param("city") String city);
}