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
    
}