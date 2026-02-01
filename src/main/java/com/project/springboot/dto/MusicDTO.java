package com.project.springboot.dto;

import lombok.Data;

@Data
public class MusicDTO {
	private int m_no;
    private String m_title;
    private int a_no;
    private int b_no;
    private String isrc_code;
    private String m_youtube_id;
    private String m_preview_url;

    // ★ 이 두 개가 없어서 500 에러가 났을 확률이 매우 높습니다!
    private String a_name;  
    private String b_title;
    private String b_image;
    private String isLiked; // 'Y' 또는 'N'을 담을 변수 추가
    
    
 // [중요] 상세 수집 및 장르 활용을 위해 추가
    private String a_spotify_id; 
    private String a_genres;
    
    public String getIsLiked() { return isLiked; }
    public void setIsLiked(String isLiked) { this.isLiked = isLiked; }
    
}