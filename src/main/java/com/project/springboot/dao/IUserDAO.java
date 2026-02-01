package com.project.springboot.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.project.springboot.dto.UserDTO;

@Mapper
public interface IUserDAO {
    UserDTO findById(@Param("uId") String uId);
    int insertUser(UserDTO userDTO);
    int updateUserStep2(UserDTO userDTO);
    int updateEmailVerification(@Param("uId") String uId);
    int countByNick(@Param("uNick") String uNick);
    int updatePassword(@Param("uId") String uId, @Param("uPassword") String uPassword);
    int deleteUser(@Param("uId") String uId);
    int updateProfileImage(@Param("uId") String uId, @Param("uProfileImg") String uProfileImg);
    UserDTO findBySocialInfo(@Param("uSocialType") String uSocialType, @Param("uSocialId") String uSocialId);
}