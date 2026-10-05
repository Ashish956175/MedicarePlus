package com.medicareplus.backend.dto;

import lombok.Data;

@Data
public class UserProfileDTO {
    private String name;
    private String email;
    private String phoneNumber;
    private String address;
    private String gender;
    private String dob;
}
