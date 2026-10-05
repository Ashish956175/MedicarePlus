package com.medicareplus.backend.repository;

import com.medicareplus.backend.entity.DoctorProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface DoctorProfileRepository extends JpaRepository<DoctorProfile, Long> {
    List<DoctorProfile> findByApprovedTrue();

    List<DoctorProfile> findByApprovedFalse();

    Optional<DoctorProfile> findByUserId(Long userId);
}
