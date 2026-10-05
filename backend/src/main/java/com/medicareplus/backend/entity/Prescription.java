package com.medicareplus.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "prescriptions")
public class Prescription {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "appointment_id", nullable = false)
    private Long appointmentId;

    @Column(name = "doctor_id", nullable = false)
    private Long doctorId;

    @Column(name = "patient_id", nullable = false)
    private Long patientId;

    private String diagnosis;

    @Column(columnDefinition = "TEXT")
    private String medicines; // Saved as JSON string [ { name: "...", dosage: "..." }, ... ]

    @Column(columnDefinition = "TEXT")
    private String advice;

    private LocalDateTime createdAt = LocalDateTime.now();
}
