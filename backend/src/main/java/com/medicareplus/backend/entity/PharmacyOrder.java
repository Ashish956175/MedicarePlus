package com.medicareplus.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Entity
@Table(name = "pharmacy_orders")
public class PharmacyOrder {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long userId;
    private Double totalAmount;
    private String status; // PENDING, SHIPPED, DELIVERED, CANCELLED
    private String paymentStatus; // PENDING, PAID, FAILED
    private LocalDateTime orderDate;

    private String address;
    private String contactNumber;

    @OneToMany(cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id")
    private List<PharmacyOrderItem> items;
}
