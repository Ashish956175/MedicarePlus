package com.medicareplus.backend.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "patient_profiles")
public class PatientProfile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false, unique = true)
    private Long userId;

    private String bloodGroup;
    private String height;
    private String weight;

    @Column(columnDefinition = "TEXT")
    private String allergies; // Comma separated or JSON

    @Column(columnDefinition = "TEXT")
    private String chronicConditions; // Comma separated or JSON

    private String emergencyContact;
}
