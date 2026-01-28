package com.project.springboot.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.project.springboot.dao.IRecommendationDAO; // 변경된 DAO 임포트
import com.project.springboot.dto.MusicDTO;

@Service
public class RecommendationService {

    private final IRecommendationDAO recommendationDAO;

    public RecommendationService(IRecommendationDAO recommendationDAO) { 
        this.recommendationDAO = recommendationDAO;
    }

    /**
     * 어떤 태그(tagName)든 로그인한 유저(u_no)의 취향에 맞춰 추천
     */
    public List<MusicDTO> getRecommendationsByTag(String tagName, Integer u_no) {
        // null 체크 로직 등을 여기서 추가할 수 있습니다.
        return recommendationDAO.findMusicDTOByTagName(tagName, u_no);
    }
    
    public List<String> getUserTopTags(int uNo) {
        // DAO를 호출하여 유저 취향 태그 리스트 반환
        return recommendationDAO.findUserTopTags(uNo);
    }
}