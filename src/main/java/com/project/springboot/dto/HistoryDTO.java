package com.project.springboot.dto;
import lombok.Data;
import java.util.Date;

@Data
public class HistoryDTO {
	private int h_no;
    private int u_no;
    private int m_no;
    private String h_location; // 이제 String입니다!
    private int h_weather;
    private double h_lat;      // 추가
    private double h_lon;      // 추가
    private Date h_played_at;
}