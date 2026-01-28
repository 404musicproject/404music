package com.project.springboot.dto;

public class PlaylistDTO {
    private Long tNo;
    private Long uNo;
    private Long mNo; // cover/대표곡 (playlists.m_no NOT NULL)
    private String tTitle;
    private String tPrivate; // 'Y'/'N'
    private String tSaved;   // 기존 스키마 상 NOT NULL. 여기서는 "0" 같은 기본값 사용.

    // View fields
    private String coverTitle;
    private String coverArtist;

    public Long gettNo() { return tNo; }
    public void settNo(Long tNo) { this.tNo = tNo; }
    public Long getuNo() { return uNo; }
    public void setuNo(Long uNo) { this.uNo = uNo; }
    public Long getmNo() { return mNo; }
    public void setmNo(Long mNo) { this.mNo = mNo; }
    public String gettTitle() { return tTitle; }
    public void settTitle(String tTitle) { this.tTitle = tTitle; }
    public String gettPrivate() { return tPrivate; }
    public void settPrivate(String tPrivate) { this.tPrivate = tPrivate; }
    public String gettSaved() { return tSaved; }
    public void settSaved(String tSaved) { this.tSaved = tSaved; }
    public String getCoverTitle() { return coverTitle; }
    public void setCoverTitle(String coverTitle) { this.coverTitle = coverTitle; }
    public String getCoverArtist() { return coverArtist; }
    public void setCoverArtist(String coverArtist) { this.coverArtist = coverArtist; }
}