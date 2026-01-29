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
    List<MusicDTO> selectMusicByKeyword(@Param("keyword") String keyword, @Param("u_no") int u_no);

    // 2-1. 헤더 검색(조건별)
    List<MusicDTO> selectMusicByTitle(@Param("keyword") String keyword, @Param("u_no") int u_no);
    List<MusicDTO> selectMusicByArtist(@Param("keyword") String keyword, @Param("u_no") int u_no);
    List<MusicDTO> selectMusicByAlbum(@Param("keyword") String keyword, @Param("u_no") int u_no);
    List<MusicDTO> selectMusicByLyrics(@Param("keyword") String keyword, @Param("u_no") int u_no);
    
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
    
    // 7. 지역별 순위 차트
    List<Map<String, Object>> selectRegionalMusic(@Param("u_no") int u_no, @Param("city") String city);
    
    // 8. Spotify 음악 특징(Feature) 저장
    int insertMusicFeature(Map<String, Object> featureMap);

    // 9. 태그 저장 (g_no를 반환받기 위해 Map 사용)
    int insertTag(Map<String, Object> tagParams);

    // 10. 음악-태그 매핑 저장
    int insertMusicTagMap(@Param("m_no") int m_no, @Param("g_no") int g_no);
    
    MusicDTO selectMusicByNo(@Param("m_no") int m_no);

    Map<String, Object> selectMusicFeature(@Param("m_no") int m_no);

    //가사 정보 저장 및 수정
    int insertLyrics(Map<String, Object> lyricsParams);

    //특정 곡의 가사 정보 가져오기
    Map<String, Object> selectLyrics(@Param("m_no") int m_no);
    Integer selectMNoByTitleAndArtist(@Param("title") String title, @Param("artist") String artist);
    
    // 특정 유저의 '내 보관함'이라는 이름의 플레이리스트 번호를 가져오거나 생성
    void insertLibraryTrack(@Param("u_no") int uNo, @Param("m_no") int mNo);
	 // 11. 라이브러리(보관함) 조회
	 // 유저 번호를 입력받아 해당 유저가 보관함(MY_LIBRARY)에 담은 곡 리스트를 반환합니다.
	List<MusicDTO> selectMusicByLibrary(@Param("u_no") int u_no);
	 
	void deleteLibraryTrack(@Param("u_no") int uNo, @Param("m_no") int mNo);
	// 12. 상세 페이지용 메서드 추가
	// 특정 아티스트의 모든 곡 조회 (좋아요 여부 포함)
	List<MusicDTO> selectMusicByArtistNo(@Param("a_no") int aNo, @Param("u_no") int uNo);

	// 특정 앨범의 모든 곡 조회 (좋아요 여부 포함)
	List<MusicDTO> selectMusicByAlbumNo(@Param("b_no") int bNo, @Param("u_no") int uNo);

	// 아티스트/앨범 자체의 정보를 가져오는 메서드 (이미 있다면 pass)
	ArtistDTO selectArtistByNo(@Param("a_no") int aNo);
	AlbumDTO selectAlbumByNo(@Param("b_no") int bNo);
	void updateArtistImage(@Param("a_no") int aNo, @Param("a_image") String aImage);
	
   
}