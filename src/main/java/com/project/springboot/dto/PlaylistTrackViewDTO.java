package com.project.springboot.dto;

import java.util.Date;

public class PlaylistTrackViewDTO {
    private Long ptNo;
    private Long tNo;
    private Long mNo;
    private Integer mOrder;
    private Date ptAddedAt;

    // View fields
    private String mTitle;
    private String aName;

    public Long getPtNo() { return ptNo; }
    public void setPtNo(Long ptNo) { this.ptNo = ptNo; }
    public Long gettNo() { return tNo; }
    public void settNo(Long tNo) { this.tNo = tNo; }
    public Long getmNo() { return mNo; }
    public void setmNo(Long mNo) { this.mNo = mNo; }
    public Integer getmOrder() { return mOrder; }
    public void setmOrder(Integer mOrder) { this.mOrder = mOrder; }
    public Date getPtAddedAt() { return ptAddedAt; }
    public void setPtAddedAt(Date ptAddedAt) { this.ptAddedAt = ptAddedAt; }
    public String getmTitle() { return mTitle; }
    public void setmTitle(String mTitle) { this.mTitle = mTitle; }
    public String getaName() { return aName; }
    public void setaName(String aName) { this.aName = aName; }
}