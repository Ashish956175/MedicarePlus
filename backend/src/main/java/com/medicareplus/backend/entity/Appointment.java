package com.medicareplus.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;

@Entity
@Data
@Table(name = "appointments")
public class Appointment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "doctor_id")
    private Long doctorId;

    private LocalDate date;

    private String timeSlot;

    private String status; // BOOKED, CANCELLED, COMPLETED

    private Long payoutId;

    @Column(columnDefinition = "TEXT")
    private String privateNotes;
}
