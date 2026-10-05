package com.medicareplus.backend.repository;

import com.medicareplus.backend.entity.PharmacyOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PharmacyOrderRepository extends JpaRepository<PharmacyOrder, Long> {
    List<PharmacyOrder> findByUserIdOrderByOrderDateDesc(Long userId);
}
