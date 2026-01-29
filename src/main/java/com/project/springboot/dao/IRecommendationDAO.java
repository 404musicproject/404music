package com.project.springboot.dao;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.project.springboot.dto.MusicDTO;

@Mapper
public interface IRecommendationDAO {
    // 파라미터 타입을 Long으로 수정
    List<String> findUserTopTags(@Param("uNo") Long uNo);
    
    // 이전에 만드신 태그별 검색 메서드도 타입을 맞춰주는 것이 좋습니다.
    List<MusicDTO> findMusicDTOByTagName(
        @Param("tagName") String tagName, 
        @Param("u_no") Long u_no
    );
}