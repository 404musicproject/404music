package com.project.springboot.dto;

import lombok.Data;

@Data
public class AlbumDTO {
    private int b_no;             // PRIMARY KEY
    private int a_no;             // FOREIGN KEY (Artist)
    private String b_title;       // 앨범 제목
    private String b_date;        // 출시일 (DB: DATE)
    private String b_image;       // 앨범 커버 URL
    private String b_type;        // 앨범 타입 (정규, 싱글 등)
    private String b_description; // 앨범 설명
}