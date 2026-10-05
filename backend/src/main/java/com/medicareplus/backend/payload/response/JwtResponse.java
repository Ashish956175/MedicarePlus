package com.medicareplus.backend.payload.response;

import lombok.Data;

@Data
public class JwtResponse {
    private String token;
    private Long id;
    private String name;
    private String email;
    private String role;
    private String profileImage;

    public JwtResponse(String token, Long id, String name, String email, String role, String profileImage) {
        this.token = token;
        this.id = id;
        this.name = name;
        this.email = email;
        this.role = role;
        this.profileImage = profileImage;
    }

    public JwtResponse(String token, Long id, String name, String email, String role) {
        this.token = token;
        this.id = id;
        this.name = name;
        this.email = email;
        this.role = role;
    }
}
