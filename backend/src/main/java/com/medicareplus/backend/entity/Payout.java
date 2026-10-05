package com.medicareplus.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "payouts")
@Data
public class Payout {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long doctorId;
    private Double amount;
    private String status; // PENDING, PAID
    private LocalDateTime processedAt;
    private String transactionId; // System generated unique ID

    private String paymentMethod; // BANK_TRANSFER, UPI, CASH, CHEQUE
    private String transactionReference; // External bank ref / UTR

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(columnDefinition = "TEXT")
    private String bankDetailsSnapshot; // Snapshot of where money was sent

    @Column(updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
