package com.medicareplus.backend.controller;

import com.medicareplus.backend.entity.PharmacyOrder;
import com.medicareplus.backend.repository.PharmacyOrderRepository;
import com.medicareplus.backend.entity.User;
import com.medicareplus.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/pharmacy")
public class PharmacyController {

    @Autowired
    private PharmacyOrderRepository pharmacyOrderRepository;

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/order")
    public ResponseEntity<?> placeOrder(@RequestBody PharmacyOrder order) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email).orElseThrow();

        order.setUserId(user.getId());
        order.setOrderDate(LocalDateTime.now());
        if (order.getStatus() == null)
            order.setStatus("PENDING");
        if (order.getPaymentStatus() == null)
            order.setPaymentStatus("PENDING");

        PharmacyOrder savedOrder = pharmacyOrderRepository.save(order);
        return ResponseEntity.ok(savedOrder);
    }

    @GetMapping("/orders/my")
    public ResponseEntity<List<PharmacyOrder>> getMyOrders() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email).orElseThrow();

        return ResponseEntity.ok(pharmacyOrderRepository.findByUserIdOrderByOrderDateDesc(user.getId()));
    }

    @PatchMapping("/orders/{id}/status")
    public ResponseEntity<?> updateOrderStatus(@PathVariable Long id, @RequestParam String status,
            @RequestParam(required = false) String paymentStatus) {
        PharmacyOrder order = pharmacyOrderRepository.findById(id).orElseThrow();
        order.setStatus(status);
        if (paymentStatus != null) {
            order.setPaymentStatus(paymentStatus);
        }
        pharmacyOrderRepository.save(order);
        return ResponseEntity.ok(order);
    }
}
