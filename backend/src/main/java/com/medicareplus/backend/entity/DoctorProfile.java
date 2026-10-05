package com.medicareplus.backend.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "doctor_profiles")
public class DoctorProfile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id")
    private Long userId;

    private String specialization;

    private Double fee;

    private Integer experience;

    private boolean approved = false;

    @Column(columnDefinition = "TEXT")
    private String about;

    private String image;

    // Bank Details for Payouts
    private String bankAccountNumber;
    private String ifscCode;
    private String accountHolderName;
    private String upiId;
}
