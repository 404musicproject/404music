package com.project.springboot.service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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
    public List<MusicDTO> getRecommendationsByTag(String tagName, Long u_no) {
        // 1. 파라미터 방어 코드
        if (tagName == null || tagName.isEmpty()) {
            return new ArrayList<>(); 
        }
        
        // 2. u_no가 null인 경우 0L(비로그인)으로 안전하게 처리
        Long safeUserNo = (u_no != null) ? u_no : 0L;

        // 3. DAO 호출 (MyBatis 매퍼의 u_no 파라미터 타입도 Long이어야 함)
        return recommendationDAO.findMusicDTOByTagName(tagName, safeUserNo);
    }
    public List<String> getUserTopTags(Long uNo) {
        // uNo가 null이거나 0L(비로그인)인 경우 기본값 반환
        if (uNo == null || uNo == 0L) {
            return Arrays.asList("행복한 기분", "카페/작업", "운동", "새벽 감성", "휴식");
        }
        return recommendationDAO.findUserTopTags(uNo);
    }
    /**
     * 유저의 TOP 5 태그를 분석해서 각 태그별 추천 리스트를 통째로 반환
     */
    public Map<String, List<MusicDTO>> getFullPersonalizedMap(Long uNo) {
        Map<String, List<MusicDTO>> finalResult = new LinkedHashMap<>();
        
        // 1. 유저의 선호 태그 리스트를 가져옴 (uNo가 Long이므로 에러 없음)
        List<String> topTags = getUserTopTags(uNo);
        
        // 2. 만약 히스토리가 없다면? (Cold Start 방지)
        if (topTags == null || topTags.isEmpty()) {
            topTags = Arrays.asList("휴식", "카페/작업", "행복한 기분", "새벽 감성", "운동");
        }
        
        // 3. 각 태그별로 노래들을 채워 넣음
        for (String tag : topTags) {
            // getRecommendationsByTag도 Long을 받으므로 그대로 uNo 전달
            List<MusicDTO> musicList = getRecommendationsByTag(tag, uNo);
            if (musicList != null && !musicList.isEmpty()) {
                finalResult.put(tag, musicList);
            }
        }
        
        return finalResult;
    }
}