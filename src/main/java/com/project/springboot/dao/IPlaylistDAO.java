package com.project.springboot.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.project.springboot.dto.LibrarySongDTO;
import com.project.springboot.dto.PlaylistDTO;
import com.project.springboot.dto.PlaylistTrackViewDTO;

@Mapper
public interface IPlaylistDAO {

    // =========================
    // Playlist
    // =========================
    List<PlaylistDTO> selectPlaylistsByUser(@Param("uNo") Long uNo);

    PlaylistDTO selectPlaylistById(@Param("tNo") Long tNo);

    int insertPlaylist(PlaylistDTO dto);

    int deletePlaylistTracks(@Param("tNo") Long tNo);
    int deletePlaylist(@Param("tNo") Long tNo);

    // =========================
    // Playlist tracks
    // =========================
    List<PlaylistTrackViewDTO> selectPlaylistTracks(@Param("tNo") Long tNo);

    Integer selectNextOrder(@Param("tNo") Long tNo);

    int insertPlaylistTrack(@Param("tNo") Long tNo,
                            @Param("mNo") Long mNo,
                            @Param("mOrder") Integer mOrder);

    int deletePlaylistTrack(@Param("ptNo") Long ptNo);

    // =========================
    // Library (Likes)
    // =========================
    List<LibrarySongDTO> selectLikedSongs(@Param("uNo") Long uNo);

    int insertLikeSong(@Param("uNo") Long uNo, @Param("mNo") Long mNo);

    int deleteLikeSong(@Param("uNo") Long uNo, @Param("mNo") Long mNo);
}