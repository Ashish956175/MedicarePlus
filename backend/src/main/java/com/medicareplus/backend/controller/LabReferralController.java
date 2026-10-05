package com.medicareplus.backend.controller;

import com.medicareplus.backend.entity.LabReferral;
import com.medicareplus.backend.repository.LabReferralRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/lab-referrals")
public class LabReferralController {

    @Autowired
    private LabReferralRepository labReferralRepository;

    @PostMapping
    public ResponseEntity<LabReferral> createReferral(@RequestBody LabReferral referral) {
        return ResponseEntity.ok(labReferralRepository.save(referral));
    }

    @GetMapping("/patient/{patientId}")
    public ResponseEntity<List<LabReferral>> getPatientReferrals(@PathVariable Long patientId) {
        return ResponseEntity.ok(labReferralRepository.findByPatientId(patientId));
    }

    @GetMapping("/doctor/{doctorId}")
    public ResponseEntity<List<LabReferral>> getDoctorReferrals(@PathVariable Long doctorId) {
        return ResponseEntity.ok(labReferralRepository.findByDoctorId(doctorId));
    }
}
