package com.project.springboot.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.project.springboot.dto.UserDTO;

@Mapper
public interface IUserDAO {
    int insertUser(UserDTO userDTO);
    UserDTO findBySocialInfo(@Param("uSocialType") String uSocialType, @Param("uSocialId") String uSocialId);
    UserDTO findById(String uId);
    int updateEmailVerification(String uId);
    int updateUserStep2(UserDTO userDTO);
    int countByNick(@Param("uNick") String uNick); //닉네임 중복확인
    int updatePassword(@Param("uId") String uId, @Param("uPassword") String uPassword);
    int deleteUser(@Param("uId") String uId);
}