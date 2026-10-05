package com.medicareplus.backend.controller;

import com.medicareplus.backend.entity.Appointment;
import com.medicareplus.backend.entity.AuditLog;
import com.medicareplus.backend.entity.DoctorProfile;
import com.medicareplus.backend.entity.Payout;
import com.medicareplus.backend.entity.User;
import com.medicareplus.backend.payload.response.MessageResponse;
import com.medicareplus.backend.repository.AppointmentRepository;
import com.medicareplus.backend.repository.DoctorProfileRepository;
import com.medicareplus.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    DoctorProfileRepository doctorProfileRepository;

    @Autowired
    UserRepository userRepository;

    @Autowired
    AppointmentRepository appointmentRepository;

    @Autowired
    com.medicareplus.backend.repository.SpecializationRepository specializationRepository;

    @Autowired
    com.medicareplus.backend.repository.AuditLogRepository auditLogRepository;

    private void logAction(String action, String target, String details) {
        com.medicareplus.backend.entity.AuditLog log = new com.medicareplus.backend.entity.AuditLog();
        log.setAction(action);
        log.setTarget(target);
        log.setDetails(details);
        // In a real app, we'd get the admin email from SecurityContextHolder
        log.setPerformedBy("System Admin");
        auditLogRepository.save(log);
    }

    @Autowired
    private com.medicareplus.backend.repository.PayoutRepository payoutRepository;

    @GetMapping("/stats")
    public Map<String, Long> getStats() {
        Map<String, Long> stats = new java.util.HashMap<>();
        stats.put("totalDoctors", doctorProfileRepository.count());
        stats.put("totalPatients", userRepository.countByRole("USER"));
        stats.put("totalAppointments", appointmentRepository.count());
        return stats;
    }

    @GetMapping("/revenue-stats")
    public Map<String, Object> getRevenueStats() {
        List<com.medicareplus.backend.entity.Appointment> appointments = appointmentRepository.findAll();
        double totalRevenue = 0;
        Map<String, Double> monthlyRevenue = new java.util.TreeMap<>(); // Sorted by month
        Map<String, Double> specializationRevenue = new java.util.HashMap<>();

        for (com.medicareplus.backend.entity.Appointment appt : appointments) {
            if ("BOOKED".equals(appt.getStatus()) || "COMPLETED".equals(appt.getStatus())) {
                DoctorProfile doc = doctorProfileRepository.findById(appt.getDoctorId()).orElse(null);
                if (doc != null) {
                    double fee = doc.getFee() != null ? doc.getFee() : 0.0;
                    totalRevenue += fee;

                    // Monthly breakdown (YYYY-MM)
                    String month = appt.getDate().getYear() + "-"
                            + String.format("%02d", appt.getDate().getMonthValue());
                    monthlyRevenue.put(month, monthlyRevenue.getOrDefault(month, 0.0) + fee);

                    // Specialization breakdown
                    String spec = doc.getSpecialization();
                    if (spec != null) {
                        specializationRevenue.put(spec, specializationRevenue.getOrDefault(spec, 0.0) + fee);
                    }
                }
            }
        }

        Map<String, Object> response = new java.util.HashMap<>();
        response.put("totalRevenue", totalRevenue);
        response.put("monthlyRevenue", monthlyRevenue);
        response.put("specializationRevenue", specializationRevenue);
        return response;
    }

    @GetMapping("/doctors/pending")
    public List<Map<String, Object>> getPendingDoctors() {
        return doctorProfileRepository.findByApprovedFalse().stream().map(profile -> {
            User user = userRepository.findById(profile.getUserId()).orElse(new User());
            return Map.<String, Object>of(
                    "id", profile.getId(),
                    "name", user.getName(),
                    "specialization", profile.getSpecialization(),
                    "experience", profile.getExperience(),
                    "profileImage", user.getProfileImage() != null ? user.getProfileImage() : "");
        }).collect(Collectors.toList());
    }

    @PostMapping("/doctors/{id}/approve")
    public ResponseEntity<?> approveDoctor(@PathVariable Long id) {
        DoctorProfile profile = doctorProfileRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Profile not found"));

        profile.setApproved(true);
        doctorProfileRepository.save(profile);

        User user = userRepository.findById(profile.getUserId()).orElse(null);
        logAction("APPROVE_DOCTOR", "Doctor: " + (user != null ? user.getName() : id),
                "Admin approved doctor profile #" + id);

        return ResponseEntity.ok(new MessageResponse("Doctor approved successfully"));
    }

    @GetMapping("/users")
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @GetMapping("/appointments")
    public com.medicareplus.backend.entity.Appointment[] getAllAppointments() {
        return appointmentRepository.findAll().toArray(new com.medicareplus.backend.entity.Appointment[0]);
    }

    // Specialization Management
    @GetMapping("/specializations")
    public List<com.medicareplus.backend.entity.Specialization> getAllSpecializations() {
        return specializationRepository.findAll();
    }

    @PostMapping("/specializations")
    public ResponseEntity<?> addSpecialization(
            @RequestBody com.medicareplus.backend.entity.Specialization specialization) {
        if (specializationRepository.findByName(specialization.getName()).isPresent()) {
            return ResponseEntity.badRequest().body(new MessageResponse("Specialization already exists"));
        }
        specializationRepository.save(specialization);
        logAction("ADD_SPECIALIZATION", "Specialization: " + specialization.getName(), "New specialization added");
        return ResponseEntity.ok(new MessageResponse("Specialization added successfully"));
    }

    @DeleteMapping("/specializations/{id}")
    public ResponseEntity<?> deleteSpecialization(@PathVariable Long id) {
        com.medicareplus.backend.entity.Specialization spec = specializationRepository.findById(id).orElse(null);
        specializationRepository.deleteById(id);
        logAction("DELETE_SPECIALIZATION", "ID: " + id,
                "Specialization deleted: " + (spec != null ? spec.getName() : "Unknown"));
        return ResponseEntity.ok(new MessageResponse("Specialization deleted successfully"));
    }

    @GetMapping("/logs")
    public List<AuditLog> getLogs() {
        return auditLogRepository.findAllByOrderByTimestampDesc();
    }

    // --- Enhanced Payout Management ---

    @GetMapping("/payouts/pending")
    public List<Map<String, Object>> getPendingPayouts() {
        // Find COMPLETED appointments not yet paid
        List<Appointment> pendingAppointments = appointmentRepository.findAll().stream()
                .filter(a -> "COMPLETED".equals(a.getStatus()) && a.getPayoutId() == null)
                .collect(Collectors.toList());

        // Group by doctor
        Map<Long, Double> doctorEarnings = pendingAppointments.stream()
                .collect(Collectors.groupingBy(
                        Appointment::getDoctorId,
                        Collectors.summingDouble(a -> {
                            DoctorProfile p = doctorProfileRepository.findById(a.getDoctorId()).orElse(null);
                            return (p != null && p.getFee() != null) ? p.getFee() : 0.0;
                        })));

        List<Map<String, Object>> pending = new ArrayList<>();
        doctorEarnings.forEach((docId, amount) -> {
            User user = userRepository.findById(docId).orElse(new User());
            DoctorProfile profile = doctorProfileRepository.findById(docId).orElse(null);

            Map<String, Object> entry = new HashMap<>();
            entry.put("doctorId", docId);
            entry.put("doctorName", user.getName());
            entry.put("amount", amount);
            entry.put("status", "PENDING");
            entry.put("appointmentCount",
                    pendingAppointments.stream().filter(a -> a.getDoctorId().equals(docId)).count());

            // Bank Info for UI
            if (profile != null) {
                entry.put("bankAccount", profile.getBankAccountNumber());
                entry.put("ifsc", profile.getIfscCode());
                entry.put("upi", profile.getUpiId());
            }

            pending.add(entry);
        });

        return pending;
    }

    @GetMapping("/payouts/pending/{doctorId}")
    public List<Appointment> getPendingPayoutDetails(@PathVariable Long doctorId) {
        return appointmentRepository.findAll().stream()
                .filter(a -> "COMPLETED".equals(a.getStatus())
                        && a.getPayoutId() == null
                        && a.getDoctorId().equals(doctorId))
                .collect(Collectors.toList());
    }

    @GetMapping("/payouts/history")
    public List<Payout> getPayoutHistory() {
        return payoutRepository.findAll(org.springframework.data.domain.Sort
                .by(org.springframework.data.domain.Sort.Direction.DESC, "processedAt"));
    }

    @GetMapping("/payouts/{payoutId}/details")
    public ResponseEntity<?> getPayoutDetails(@PathVariable Long payoutId) {
        Payout payout = payoutRepository.findById(payoutId).orElse(null);
        if (payout == null)
            return ResponseEntity.notFound().build();

        List<Appointment> appointments = appointmentRepository.findAll().stream()
                .filter(a -> payoutId.equals(a.getPayoutId()))
                .collect(Collectors.toList());

        Map<String, Object> response = new HashMap<>();
        response.put("payout", payout);
        response.put("appointments", appointments);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/payouts/process")
    public ResponseEntity<?> processPayout(@RequestBody Map<String, Object> request) {
        Long doctorId = Long.valueOf(request.get("doctorId").toString());
        Double amount = Double.valueOf(request.get("amount").toString());
        String method = (String) request.getOrDefault("paymentMethod", "BANK_TRANSFER");
        String ref = (String) request.getOrDefault("transactionReference", "REF" + System.currentTimeMillis());
        String notes = (String) request.getOrDefault("notes", "");

        // 1. Create Payout Record
        Payout payout = new Payout();
        payout.setDoctorId(doctorId);
        payout.setAmount(amount);
        payout.setStatus("PAID");
        payout.setProcessedAt(LocalDateTime.now());
        payout.setTransactionId(UUID.randomUUID().toString());
        payout.setPaymentMethod(method);
        payout.setTransactionReference(ref);
        payout.setNotes(notes);

        // Snapshot bank details
        DoctorProfile profile = doctorProfileRepository.findById(doctorId).orElse(null);
        if (profile != null) {
            payout.setBankDetailsSnapshot(profile.getBankAccountNumber() + " | " + profile.getIfscCode());
        }

        Payout savedPayout = payoutRepository.save(payout);

        // 2. Link eligible appointments to this payout
        List<Appointment> doctorPendingAppts = appointmentRepository.findAll().stream()
                .filter(a -> "COMPLETED".equals(a.getStatus())
                        && a.getPayoutId() == null
                        && a.getDoctorId().equals(doctorId))
                .collect(Collectors.toList());

        for (Appointment appt : doctorPendingAppts) {
            appt.setPayoutId(savedPayout.getId());
            appointmentRepository.save(appt);
        }

        logAction("PROCESS_PAYOUT", "Doctor ID: " + doctorId,
                "Processed payout of " + amount + " (TXN: " + savedPayout.getTransactionId() + ")");

        return ResponseEntity.ok(new MessageResponse("Payout processed successfully"));
    }
}
