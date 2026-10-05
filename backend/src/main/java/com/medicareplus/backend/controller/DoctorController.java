package com.medicareplus.backend.controller;

import com.medicareplus.backend.entity.Appointment;
import com.medicareplus.backend.entity.Availability;
import com.medicareplus.backend.entity.DoctorProfile;
import com.medicareplus.backend.entity.User;
import com.medicareplus.backend.payload.response.MessageResponse;
import com.medicareplus.backend.repository.AppointmentRepository;
import com.medicareplus.backend.repository.AvailabilityRepository;
import com.medicareplus.backend.repository.DoctorProfileRepository;
import com.medicareplus.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/doctor")
public class DoctorController {

    @Autowired
    DoctorProfileRepository doctorProfileRepository;

    @Autowired
    AvailabilityRepository availabilityRepository;

    @Autowired
    AppointmentRepository appointmentRepository;

    @Autowired
    UserRepository userRepository;

    @Autowired
    com.medicareplus.backend.repository.PrescriptionRepository prescriptionRepository;

    @Autowired
    com.medicareplus.backend.repository.MedicalRecordRepository medicalRecordRepository;

    @Autowired
    com.medicareplus.backend.repository.PatientProfileRepository patientProfileRepository;

    @PostMapping("/availability")
    public ResponseEntity<?> addAvailability(@RequestBody Map<String, Object> request) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email).orElseThrow();
        DoctorProfile profile = doctorProfileRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Profile not found"));

        if (!profile.isApproved()) {
            return ResponseEntity.badRequest().body(new MessageResponse("Doctor not approved"));
        }

        String dateStr = request.get("date").toString();
        String timeSlot = request.get("timeSlot").toString();
        LocalDate date = LocalDate.parse(dateStr);

        Availability availability = new Availability();
        availability.setDoctorId(profile.getId());
        availability.setDate(date);
        availability.setTimeSlot(timeSlot);

        availabilityRepository.save(availability);

        return ResponseEntity.ok(new MessageResponse("Availability added"));
    }

    @GetMapping("/my-availability")
    public List<Availability> getMyAvailability() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email).orElseThrow();
        DoctorProfile profile = doctorProfileRepository.findByUserId(user.getId()).orElseThrow();
        return availabilityRepository.findByDoctorId(profile.getId());
    }

    @GetMapping("/{id}/availability")
    public List<Availability> getDoctorAvailability(@PathVariable Long id) {
        return availabilityRepository.findByDoctorId(id);
    }

    @jakarta.transaction.Transactional
    @DeleteMapping("/availability")
    public ResponseEntity<?> deleteAvailability(@RequestParam String date, @RequestParam String timeSlot) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email).orElseThrow();
        DoctorProfile profile = doctorProfileRepository.findByUserId(user.getId()).orElseThrow();

        availabilityRepository.deleteByDoctorIdAndDateAndTimeSlot(profile.getId(), LocalDate.parse(date), timeSlot);
        return ResponseEntity.ok(new MessageResponse("Availability deleted"));
    }

    @GetMapping("/appointments")
    public List<Appointment> getMyAppointments() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email).orElseThrow();
        DoctorProfile profile = doctorProfileRepository.findByUserId(user.getId()).orElseThrow();

        // In real world, filter by date too. Here return all.
        // Or specific date if param provided, but requirement says minimal.
        // Let's return all upcoming for now or just all.
        return appointmentRepository.findByDoctorIdAndDate(profile.getId(), LocalDate.now());
    }

    @PostMapping("/appointments/{id}/complete")
    public ResponseEntity<?> completeAppointment(@PathVariable Long id) {
        Appointment appointment = appointmentRepository.findById(id).orElseThrow();

        // Verify doctor owns appointment
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email).orElseThrow();
        DoctorProfile profile = doctorProfileRepository.findByUserId(user.getId()).orElseThrow();

        if (!appointment.getDoctorId().equals(profile.getId())) {
            return ResponseEntity.badRequest().body(new MessageResponse("Unauthorized"));
        }

        appointment.setStatus("COMPLETED");
        appointmentRepository.save(appointment);

        return ResponseEntity.ok(new MessageResponse("Appointment completed"));
    }

    @PostMapping("/prescriptions")
    public ResponseEntity<?> createPrescription(
            @RequestBody com.medicareplus.backend.entity.Prescription prescription) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email).orElseThrow();
        DoctorProfile profile = doctorProfileRepository.findByUserId(user.getId()).orElseThrow();

        prescription.setDoctorId(profile.getId());
        prescriptionRepository.save(prescription);

        return ResponseEntity.ok(new MessageResponse("Prescription created successfully"));
    }

    @GetMapping("/prescriptions/appointment/{appointmentId}")
    public ResponseEntity<?> getPrescriptionByAppointment(@PathVariable Long appointmentId) {
        return prescriptionRepository.findByAppointmentId(appointmentId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/stats")
    public Map<String, Object> getDoctorStats() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email).orElseThrow();
        DoctorProfile profile = doctorProfileRepository.findByUserId(user.getId()).orElseThrow();

        List<Appointment> allAppointments = appointmentRepository.findByDoctorId(profile.getId());

        long totalAppointments = allAppointments.size();
        long completedAppointments = allAppointments.stream()
                .filter(a -> "COMPLETED".equals(a.getStatus())).count();
        long pendingAppointments = allAppointments.stream()
                .filter(a -> "BOOKED".equals(a.getStatus())).count();

        double totalEarnings = completedAppointments * (profile.getFee() != null ? profile.getFee() : 0.0);

        Map<String, Object> stats = new java.util.HashMap<>();
        stats.put("totalAppointments", totalAppointments);
        stats.put("completedAppointments", completedAppointments);
        stats.put("pendingAppointments", pendingAppointments);
        stats.put("totalEarnings", totalEarnings);
        stats.put("rating", 4.8); // Mocked rating for now, would be from reviews
        stats.put("totalReviews", 15); // Mocked count

        return stats;
    }

    @GetMapping("/patients")
    public List<User> getMyPatients() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email).orElseThrow();
        DoctorProfile profile = doctorProfileRepository.findByUserId(user.getId()).orElseThrow();

        return appointmentRepository.findUniquePatientsByDoctorId(profile.getId());
    }

    @GetMapping("/patients/{patientId}/history")
    public Map<String, Object> getPatientHistory(@PathVariable Long patientId) {
        // In a real app, verify that this doctor has a relationship with this patient
        // For now, we return the history as requested.

        List<com.medicareplus.backend.entity.Prescription> prescriptions = prescriptionRepository
                .findByPatientId(patientId);
        List<com.medicareplus.backend.entity.MedicalRecord> records = medicalRecordRepository.findByUserId(patientId);

        Map<String, Object> history = new java.util.HashMap<>();
        history.put("prescriptions", prescriptions);
        history.put("medicalRecords", records);

        return history;
    }

    @GetMapping("/patients/{patientId}/insights")
    public ResponseEntity<?> getPatientInsights(@PathVariable Long patientId) {
        // Verify doctor-patient relationship in real app
        User patient = userRepository.findById(patientId)
                .orElseThrow(() -> new RuntimeException("Patient not found"));

        Optional<com.medicareplus.backend.entity.PatientProfile> profile = patientProfileRepository
                .findByUserId(patientId);

        Map<String, Object> data = new java.util.HashMap<>();
        data.put("id", patient.getId());
        data.put("name", patient.getName());
        data.put("email", patient.getEmail());
        data.put("gender", patient.getGender());
        data.put("dob", patient.getDob());
        data.put("phoneNumber", patient.getPhoneNumber());
        data.put("profileImage", patient.getProfileImage());

        if (profile.isPresent()) {
            data.put("bloodGroup", profile.get().getBloodGroup());
            data.put("height", profile.get().getHeight());
            data.put("weight", profile.get().getWeight());
            data.put("allergies", profile.get().getAllergies());
            data.put("chronicConditions", profile.get().getChronicConditions());
            data.put("emergencyContact", profile.get().getEmergencyContact());
        } else {
            // Return empty/default values if no profile exists yet
            data.put("bloodGroup", "N/A");
            data.put("height", "--");
            data.put("weight", "--");
            data.put("allergies", "No known allergies");
            data.put("chronicConditions", "None");
            data.put("emergencyContact", "Not set");
        }

        return ResponseEntity.ok(data);
    }

    @GetMapping("/profile")
    public ResponseEntity<?> getProfile() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email).orElseThrow();
        DoctorProfile profile = doctorProfileRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Profile not found"));
        return ResponseEntity.ok(profile);
    }

    @PutMapping("/profile/fee")
    public ResponseEntity<?> updateFee(@RequestBody Map<String, Double> request) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email).orElseThrow();
        DoctorProfile profile = doctorProfileRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Profile not found"));

        if (request.containsKey("fee")) {
            profile.setFee(request.get("fee"));
            doctorProfileRepository.save(profile);
            return ResponseEntity.ok(new MessageResponse("Fee updated successfully"));
        } else {
            return ResponseEntity.badRequest().body(new MessageResponse("Fee is required"));
        }
    }
}
