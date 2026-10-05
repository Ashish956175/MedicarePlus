package com.medicareplus.backend.payload.request;

import lombok.Data;

@Data
public class SignupRequest {
    private String name;
    private String email;
    private String password;
    private String role; // USER, DOCTOR, ADMIN

    // Optional doctor fields
    private String specialization;
    private Integer experience;
    private Double fee;
}
