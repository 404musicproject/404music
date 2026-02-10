package com.project.springboot.dto;

import lombok.Data;

@Data
public class MusicLyricsDTO {
    private int m_no;
    private String lyrics_text;
    private String lyrics_trans;
    private String lyricist;
    private String lyrics_sync; // 스네이크 케이스로 일치시킴
}