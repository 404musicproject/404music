package com.project.springboot.service;

import java.util.List;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.project.springboot.dao.IPlaylistDAO;
import com.project.springboot.dto.LibrarySongDTO;
import com.project.springboot.dto.PlaylistDTO;
import com.project.springboot.dto.PlaylistTrackViewDTO;

@Service
public class PlaylistService {

    private final IPlaylistDAO dao;

    public PlaylistService(IPlaylistDAO dao) {
        this.dao = dao;
    }

    public List<PlaylistDTO> listPlaylists(Long uNo) {
        return dao.selectPlaylistsByUser(uNo);
    }

    public PlaylistDTO getPlaylist(Long tNo) {
        return dao.selectPlaylistById(tNo);
    }

    public List<PlaylistTrackViewDTO> listTracks(Long tNo) {
        return dao.selectPlaylistTracks(tNo);
    }

    @Transactional
    public Long createPlaylist(Long uNo, String title, String isPrivate, Long coverMNo) {
        PlaylistDTO dto = new PlaylistDTO();
        dto.setuNo(uNo);
        dto.settTitle(title);
        dto.settPrivate(isPrivate != null && isPrivate.equalsIgnoreCase("Y") ? "Y" : "N");
        dto.setmNo(coverMNo);
        dto.settSaved("0"); // NOT NULL 대응용 기본값

        // insertPlaylist는 t_no를 selectKey로 채워줌
        dao.insertPlaylist(dto);

        // 생성 시 cover 곡을 트랙 1로도 같이 넣어두면 화면이 자연스러움
        Integer nextOrder = dao.selectNextOrder(dto.gettNo());
        if (nextOrder == null) nextOrder = 1;
        dao.insertPlaylistTrack(dto.gettNo(), coverMNo, nextOrder);

        return dto.gettNo();
    }

    public void addTrack(Long tNo, Long mNo) {
        Integer nextOrder = dao.selectNextOrder(tNo);
        if (nextOrder == null) nextOrder = 1;
        dao.insertPlaylistTrack(tNo, mNo, nextOrder);
    }

    public void removeTrack(Long ptNo) {
        dao.deletePlaylistTrack(ptNo);
    }

    @Transactional
    public void deletePlaylistCascade(Long tNo) {
        dao.deletePlaylistTracks(tNo);
        dao.deletePlaylist(tNo);
    }

    public List<LibrarySongDTO> listLikedSongs(Long uNo) {
        return dao.selectLikedSongs(uNo);
    }

    public void likeSong(Long uNo, Long mNo) {
        try {
            dao.insertLikeSong(uNo, mNo);
        } catch (DuplicateKeyException ignore) {
            // uk_user_like_target 때문에 중복이면 그냥 무시
        }
    }

    public void unlikeSong(Long uNo, Long mNo) {
        dao.deleteLikeSong(uNo, mNo);
    }
}