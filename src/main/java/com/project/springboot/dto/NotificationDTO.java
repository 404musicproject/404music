package com.project.springboot.dto;

import java.util.Date;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class NotificationDTO {
    private int noticeNo;           // n_no -> nNo
    private int userNo;           // u_no -> uNo
    @JsonProperty("nTitle")
    private String nTitle;     // n_title -> nTitle
    @JsonProperty("nContent")
    private String nContent;   // n_content -> nContent
    private String nIsRead;    // n_is_read -> nIsRead (기본값 'N')
    private String nType;      // n_type -> nType
    private int nRefNo;        // n_ref_no -> nRefNo
    private Date nDate;        // n_date -> nDate
    private String nEndDate; 
}