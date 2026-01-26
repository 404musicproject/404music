package com.project.springboot.dto;

import lombok.Data;

@Data // Lombok 사용 시, 없으면 Getter/Setter 직접 생성
public class ArtistDTO {
    private int a_no;
    private String a_name;
    private String a_image;
    private String a_genres;
    private String a_debut_date;
    private int a_followers;
    private String a_spotify_id;
}
