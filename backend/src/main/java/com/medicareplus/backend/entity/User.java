package com.medicareplus.backend.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(unique = true)
    private String email;

    private String password;

    private String role; // USER, DOCTOR, ADMIN

    private String profileImage;

    private boolean active = true;

    private String phoneNumber;
    private String address;
    private String gender;
    private String dob;
}
