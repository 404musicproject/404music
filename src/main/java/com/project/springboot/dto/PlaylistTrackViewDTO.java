package com.project.springboot.dto;

import lombok.Data;

@Data
public class PlaylistTrackViewDTO {
    private Long ptNo;      // 트랙 고유 번호
    private Long tNo;       // 플레이리스트 번호
    private Long mNo;       // 노래 번호
    private Integer mOrder; // 순서
    
    private String mTitle;  // 노래 제목
    private String aName;   // 가수 이름
    private String bImage;  // 앨범 이미지 URL
    private String mPreviewUrl; // 미리듣기 URL
}