package com.project.springboot.dao;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.project.springboot.dto.MusicDTO;

@Mapper
public interface IRecommendationDAO {
    // u_no를 추가하여 유저별 히스토리 점수를 계산할 수 있게 합니다.
    List<MusicDTO> findMusicDTOByTagName(
        @Param("tagName") String tagName, 
        @Param("u_no") Integer u_no
    );
    
    List<String> findUserTopTags(@Param("uNo") int uNo);
}