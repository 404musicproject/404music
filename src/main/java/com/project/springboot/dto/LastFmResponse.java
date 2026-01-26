package com.project.springboot.dto;

import java.util.List;

import lombok.Data;

@Data
@com.fasterxml.jackson.annotation.JsonIgnoreProperties(ignoreUnknown = true)
public class LastFmResponse {
    private Toptags toptags;

    @Data
    @com.fasterxml.jackson.annotation.JsonIgnoreProperties(ignoreUnknown = true)
    public static class Toptags {
        // Last.fm 응답은 "tag"라는 키 안에 배열이 들어있습니다.
        private List<Tag> tag;
    }

    @Data
    @com.fasterxml.jackson.annotation.JsonIgnoreProperties(ignoreUnknown = true)
    public static class Tag {
        private String name;
        // count는 숫자가 아닌 문자열로 올 때가 많아 String이 안전합니다.
        private String count; 
    }
}