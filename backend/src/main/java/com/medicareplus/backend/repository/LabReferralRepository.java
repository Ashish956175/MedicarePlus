package com.medicareplus.backend.repository;

import com.medicareplus.backend.entity.LabReferral;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface LabReferralRepository extends JpaRepository<LabReferral, Long> {
    List<LabReferral> findByPatientId(Long patientId);

    List<LabReferral> findByDoctorId(Long doctorId);
}
