package com.project.springboot.dto;

import java.util.Date;
import lombok.Data;

@Data
public class InquiryDTO {
    private int iNo;             // i_no
    private int userNo;         
    private String iTitle;       // i_title
    private String iContent;     // i_content
    private Date iDate;          // i_date
    private String iAnswer;      // i_answer
    private Date iAnsweredAt;    // i_answered_at
    private String iStatus;      // i_status
    private String iIsSecret;    // i_is_secret
}