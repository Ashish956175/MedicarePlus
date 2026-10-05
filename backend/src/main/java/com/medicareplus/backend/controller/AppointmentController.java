package com.medicareplus.backend.controller;

import com.medicareplus.backend.entity.Appointment;
import com.medicareplus.backend.entity.User;
import com.medicareplus.backend.payload.response.MessageResponse;
import com.medicareplus.backend.repository.AppointmentRepository;
import com.medicareplus.backend.repository.DoctorProfileRepository;
import com.medicareplus.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/appointments")
public class AppointmentController {

    @Autowired
    AppointmentRepository appointmentRepository;

    @Autowired
    UserRepository userRepository;

    @Autowired
    DoctorProfileRepository doctorProfileRepository;

    @PostMapping("/book")
    public ResponseEntity<?> bookAppointment(@RequestBody Map<String, Object> request) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email).orElseThrow();

        Long doctorProfileId = Long.parseLong(request.get("doctorId").toString());
        String dateStr = request.get("date").toString();
        String timeSlot = request.get("timeSlot").toString();

        LocalDate date = LocalDate.parse(dateStr);

        // Verify doctor exists
        doctorProfileRepository.findById(doctorProfileId)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));

        // Check double booking
        List<Appointment> existing = appointmentRepository.findByDoctorIdAndDate(doctorProfileId, date);
        boolean isTaken = existing.stream()
                .anyMatch(a -> a.getTimeSlot().equals(timeSlot) && !a.getStatus().equals("CANCELLED"));

        if (isTaken) {
            return ResponseEntity.badRequest().body(new MessageResponse("Slot already taken"));
        }

        Appointment appointment = new Appointment();
        appointment.setUserId(user.getId());
        appointment.setDoctorId(doctorProfileId);
        appointment.setDate(date);
        appointment.setTimeSlot(timeSlot);
        appointment.setStatus("BOOKED");

        appointmentRepository.save(appointment);

        return ResponseEntity.ok(new MessageResponse("Appointment booked successfully"));
    }

    @PostMapping("/cancel")
    public ResponseEntity<?> cancelAppointment(@RequestBody Map<String, Long> request) {
        Long appointmentId = request.get("id");
        Appointment appointment = appointmentRepository.findById(appointmentId).orElseThrow();

        // Verify user owns appointment
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email).orElseThrow();

        if (!appointment.getUserId().equals(user.getId())) {
            return ResponseEntity.badRequest().body(new MessageResponse("Unauthorized"));
        }

        appointment.setStatus("CANCELLED");
        appointmentRepository.save(appointment);

        return ResponseEntity.ok(new MessageResponse("Appointment cancelled"));
    }

    @GetMapping("/my")
    public List<Appointment> getMyAppointments() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email).orElseThrow();
        return appointmentRepository.findByUserId(user.getId());
    }

    @GetMapping("/doctor/my")
    public List<Appointment> getDoctorAppointments() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email).orElseThrow();
        com.medicareplus.backend.entity.DoctorProfile profile = doctorProfileRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Doctor profile or unauthorized access"));
        return appointmentRepository.findByDoctorId(profile.getId());
    }
}
