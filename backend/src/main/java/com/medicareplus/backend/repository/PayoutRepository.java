package com.medicareplus.backend.repository;

import com.medicareplus.backend.entity.Payout;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PayoutRepository extends JpaRepository<Payout, Long> {
    List<Payout> findByDoctorId(Long doctorId);

    List<Payout> findByStatus(String status);
}
