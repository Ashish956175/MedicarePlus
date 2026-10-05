package com.medicareplus.backend.controller;

import com.medicareplus.backend.entity.DoctorProfile;
import com.medicareplus.backend.entity.User;
import com.medicareplus.backend.repository.DoctorProfileRepository;
import com.medicareplus.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    DoctorProfileRepository doctorProfileRepository;

    @Autowired
    UserRepository userRepository;

    @Autowired
    com.medicareplus.backend.repository.PrescriptionRepository prescriptionRepository;

    @Autowired
    com.medicareplus.backend.repository.MedicalRecordRepository medicalRecordRepository;

    @GetMapping("/doctors")
    public List<Map<String, Object>> getAllDoctors() {
        return doctorProfileRepository.findByApprovedTrue().stream().map(profile -> {
            User user = userRepository.findById(profile.getUserId()).orElse(new User());
            Map<String, Object> doctorMap = new HashMap<>();
            doctorMap.put("id", profile.getId());
            doctorMap.put("name", user.getName());
            doctorMap.put("specialization", profile.getSpecialization());
            doctorMap.put("experience", profile.getExperience());
            doctorMap.put("fee", profile.getFee());
            doctorMap.put("about", profile.getAbout() != null ? profile.getAbout() : "");
            doctorMap.put("image", profile.getImage());
            doctorMap.put("profileImage", user.getProfileImage());
            return doctorMap;
        }).collect(Collectors.toList());
    }

    @GetMapping("/doctors/{id}")
    public ResponseEntity<?> getDoctorById(@PathVariable Long id) {
        DoctorProfile profile = doctorProfileRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));

        if (!profile.isApproved()) {
            return ResponseEntity.badRequest().body("Doctor not approved");
        }

        User user = userRepository.findById(profile.getUserId()).orElse(new User());

        return ResponseEntity.ok(Map.of(
                "id", profile.getId(),
                "name", user.getName(),
                "specialization", profile.getSpecialization(),
                "experience", profile.getExperience(),
                "fee", profile.getFee(),
                "about", profile.getAbout() != null ? profile.getAbout() : "",
                "image", profile.getImage(),
                "profileImage", user.getProfileImage() != null ? user.getProfileImage() : ""));
    }

    @GetMapping("/prescriptions/{id}")
    public List<com.medicareplus.backend.entity.Prescription> getPrescriptions(@PathVariable Long id) {
        return prescriptionRepository.findByPatientId(id);
    }

    @PostMapping("/medical-records")
    public ResponseEntity<?> saveMedicalRecord(@RequestBody com.medicareplus.backend.entity.MedicalRecord record) {
        medicalRecordRepository.save(record);
        return ResponseEntity.ok(Map.of("message", "Record saved successfully"));
    }

    @GetMapping("/medical-records/{id}")
    public List<com.medicareplus.backend.entity.MedicalRecord> getMedicalRecords(@PathVariable Long id) {
        return medicalRecordRepository.findByUserId(id);
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(@RequestBody com.medicareplus.backend.dto.UserProfileDTO profileDTO) {
        String currentUserEmail = org.springframework.security.core.context.SecurityContextHolder.getContext()
                .getAuthentication().getName();
        User user = userRepository.findByEmail(currentUserEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (profileDTO.getName() != null) {
            String newName = profileDTO.getName().trim();
            if ("DOCTOR".equalsIgnoreCase(user.getRole())) {
                if (!newName.toLowerCase().startsWith("dr.")) {
                    newName = "Dr. " + newName;
                }
            }
            user.setName(newName);
        }
        if (profileDTO.getPhoneNumber() != null)
            user.setPhoneNumber(profileDTO.getPhoneNumber());
        if (profileDTO.getAddress() != null)
            user.setAddress(profileDTO.getAddress());
        if (profileDTO.getGender() != null)
            user.setGender(profileDTO.getGender());
        if (profileDTO.getDob() != null)
            user.setDob(profileDTO.getDob());

        userRepository.save(user);

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Profile updated successfully");
        response.put("user", user);

        return ResponseEntity.ok(response);
    }
}
