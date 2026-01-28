package com.project.springboot.dto;

public class LibrarySongDTO {
    private Long lNo;
    private Long uNo;
    private String lTargetType; // 'MUSIC'
    private Long lTargetNo;     // m_no

    // View fields
    private String mTitle;
    private String aName;

    public Long getlNo() { return lNo; }
    public void setlNo(Long lNo) { this.lNo = lNo; }
    public Long getuNo() { return uNo; }
    public void setuNo(Long uNo) { this.uNo = uNo; }
    public String getlTargetType() { return lTargetType; }
    public void setlTargetType(String lTargetType) { this.lTargetType = lTargetType; }
    public Long getlTargetNo() { return lTargetNo; }
    public void setlTargetNo(Long lTargetNo) { this.lTargetNo = lTargetNo; }
    public String getmTitle() { return mTitle; }
    public void setmTitle(String mTitle) { this.mTitle = mTitle; }
    public String getaName() { return aName; }
    public void setaName(String aName) { this.aName = aName; }
}