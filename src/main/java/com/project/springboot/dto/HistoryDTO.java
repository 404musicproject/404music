package com.project.springboot.dto;
import lombok.Data;
import java.util.Date;

@Data
public class HistoryDTO {
    private int h_no;
    private int u_no;
    private int m_no;
    private int h_location; // 지역 코드
    private int h_weather;  // 날씨 코드
    private Date h_played_at;
}