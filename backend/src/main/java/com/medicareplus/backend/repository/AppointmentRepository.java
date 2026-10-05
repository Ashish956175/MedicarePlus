package com.medicareplus.backend.repository;

import com.medicareplus.backend.entity.Appointment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.time.LocalDate;

@Repository
public interface AppointmentRepository extends JpaRepository<Appointment, Long> {
    List<Appointment> findByUserId(Long userId);

    List<Appointment> findByDoctorIdAndDate(Long doctorId, LocalDate date);

    List<Appointment> findByDoctorId(Long doctorId);

    @org.springframework.data.jpa.repository.Query("SELECT DISTINCT u FROM User u JOIN Appointment a ON u.id = a.userId WHERE a.doctorId = :doctorId")
    List<com.medicareplus.backend.entity.User> findUniquePatientsByDoctorId(Long doctorId);
}
