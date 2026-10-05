package com.medicareplus.backend.repository;

import com.medicareplus.backend.entity.Availability;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.time.LocalDate;

@Repository
public interface AvailabilityRepository extends JpaRepository<Availability, Long> {
    List<Availability> findByDoctorIdAndDate(Long doctorId, LocalDate date);

    List<Availability> findByDoctorId(Long doctorId);

    void deleteByDoctorIdAndDateAndTimeSlot(Long doctorId, LocalDate date, String timeSlot);
}
