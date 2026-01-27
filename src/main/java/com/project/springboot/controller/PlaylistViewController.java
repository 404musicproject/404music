package com.project.springboot.controller;

import java.util.Arrays;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.project.springboot.dto.PlaylistDTO;
import com.project.springboot.service.PlaylistService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/user")
public class PlaylistViewController {

    private final PlaylistService service;

    public PlaylistViewController(PlaylistService service) {
        this.service = service;
    }

    // -------------------------
    // Util: resolve user id
    // -------------------------
    private Long resolveUserNo(HttpSession session, Long uNoParam) {
        if (uNoParam != null) return uNoParam;

        List<String> keys = Arrays.asList("u_no", "uNo", "userNo", "loginUserNo", "login_u_no");
        for (String key : keys) {
            Object v = session.getAttribute(key);
            if (v instanceof Number) return ((Number) v).longValue();
            if (v instanceof String) {
                try { return Long.parseLong((String) v); } catch (NumberFormatException ignore) {}
            }
        }
        return null;
    }

    // =========================
    // Playlist pages
    // =========================
    @GetMapping("/playlists")
    public String playlists(@RequestParam(value = "uNo", required = false) Long uNo,
                            HttpSession session,
                            Model model) {

        Long userNo = resolveUserNo(session, uNo);
        model.addAttribute("uNo", userNo);
        if (userNo != null) {
            model.addAttribute("playlists", service.listPlaylists(userNo));
        }
        return "playlist/PlaylistList";
    }

    @PostMapping("/playlists/create")
    public String createPlaylist(@RequestParam(value = "uNo", required = false) Long uNo,
                                 @RequestParam("title") String title,
                                 @RequestParam(value = "isPrivate", required = false) String isPrivate,
                                 @RequestParam("coverMNo") Long coverMNo,
                                 HttpSession session) {

        Long userNo = resolveUserNo(session, uNo);
        if (userNo == null) {
            throw new IllegalStateException("uNo가 없습니다. /user/playlists?uNo=1 처럼 uNo를 넘기거나, 로그인 세션에 u_no(uNo) 값을 넣어주세요.");
        }

        Long tNo = service.createPlaylist(userNo, title, isPrivate, coverMNo);
        return "redirect:/user/playlists/detail?tNo=" + tNo + "&uNo=" + userNo;
    }

    @GetMapping("/playlists/detail")
    public String playlistDetail(@RequestParam("tNo") Long tNo,
                                 @RequestParam(value = "uNo", required = false) Long uNo,
                                 HttpSession session,
                                 Model model) {

        Long userNo = resolveUserNo(session, uNo);
        model.addAttribute("uNo", userNo);

        PlaylistDTO pl = service.getPlaylist(tNo);
        model.addAttribute("playlist", pl);
        model.addAttribute("tracks", service.listTracks(tNo));
        return "playlist/PlaylistDetail";
    }

    @PostMapping("/playlists/tracks/add")
    public String addTrack(@RequestParam("tNo") Long tNo,
                           @RequestParam("mNo") Long mNo,
                           @RequestParam(value = "uNo", required = false) Long uNo,
                           HttpSession session) {

        Long userNo = resolveUserNo(session, uNo);
        service.addTrack(tNo, mNo);
        String suffix = (userNo != null) ? ("&uNo=" + userNo) : "";
        return "redirect:/user/playlists/detail?tNo=" + tNo + suffix;
    }

    @PostMapping("/playlists/tracks/delete")
    public String deleteTrack(@RequestParam("tNo") Long tNo,
                              @RequestParam("ptNo") Long ptNo,
                              @RequestParam(value = "uNo", required = false) Long uNo,
                              HttpSession session) {

        Long userNo = resolveUserNo(session, uNo);
        service.removeTrack(ptNo);
        String suffix = (userNo != null) ? ("&uNo=" + userNo) : "";
        return "redirect:/user/playlists/detail?tNo=" + tNo + suffix;
    }

    @PostMapping("/playlists/delete")
    public String deletePlaylist(@RequestParam("tNo") Long tNo,
                                 @RequestParam(value = "uNo", required = false) Long uNo,
                                 HttpSession session) {

        Long userNo = resolveUserNo(session, uNo);
        service.deletePlaylistCascade(tNo);
        String suffix = (userNo != null) ? ("?uNo=" + userNo) : "";
        return "redirect:/user/playlists" + suffix;
    }

    // =========================
    // Library (Likes) page
    // =========================
    @GetMapping("/library")
    public String library(@RequestParam(value = "uNo", required = false) Long uNo,
                          HttpSession session,
                          Model model) {

        Long userNo = resolveUserNo(session, uNo);
        model.addAttribute("uNo", userNo);

        if (userNo != null) {
            model.addAttribute("likedSongs", service.listLikedSongs(userNo));
            model.addAttribute("playlists", service.listPlaylists(userNo));
        }
        return "library/Library";
    }

    @PostMapping("/library/like")
    public String like(@RequestParam(value = "uNo", required = false) Long uNo,
                       @RequestParam("mNo") Long mNo,
                       HttpSession session) {

        Long userNo = resolveUserNo(session, uNo);
        if (userNo == null) {
            throw new IllegalStateException("uNo가 없습니다. /user/library?uNo=1 처럼 uNo를 넘기거나, 로그인 세션에 u_no(uNo) 값을 넣어주세요.");
        }
        service.likeSong(userNo, mNo);
        return "redirect:/user/library?uNo=" + userNo;
    }

    @PostMapping("/library/unlike")
    public String unlike(@RequestParam(value = "uNo", required = false) Long uNo,
                         @RequestParam("mNo") Long mNo,
                         HttpSession session) {

        Long userNo = resolveUserNo(session, uNo);
        if (userNo == null) {
            throw new IllegalStateException("uNo가 없습니다. /user/library?uNo=1 처럼 uNo를 넘기거나, 로그인 세션에 u_no(uNo) 값을 넣어주세요.");
        }
        service.unlikeSong(userNo, mNo);
        return "redirect:/user/library?uNo=" + userNo;
    }
}