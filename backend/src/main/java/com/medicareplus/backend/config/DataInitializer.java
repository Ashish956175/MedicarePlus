package com.medicareplus.backend.config;

import com.medicareplus.backend.entity.User;
import com.medicareplus.backend.entity.DoctorProfile;
import com.medicareplus.backend.repository.UserRepository;
import com.medicareplus.backend.repository.DoctorProfileRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class DataInitializer {

    @Bean
    CommandLineRunner init(UserRepository userRepository, DoctorProfileRepository doctorProfileRepository,
            com.medicareplus.backend.repository.SpecializationRepository specializationRepository,
            PasswordEncoder passwordEncoder) {
        return args -> {
            // Admin
            if (userRepository.findByEmail("admin@admin.com").isEmpty()) {
                User admin = new User();
                admin.setName("Admin User");
                admin.setEmail("admin@admin.com");
                admin.setPassword(passwordEncoder.encode("admin123"));
                admin.setRole("ADMIN");
                admin.setActive(true);
                userRepository.save(admin);
                System.out.println("Admin user created");
            }

            // New Test Admin
            if (userRepository.findByEmail("test-admin@medicare.com").isEmpty()) {
                User testAdmin = new User();
                testAdmin.setName("Test Admin");
                testAdmin.setEmail("test-admin@medicare.com");
                testAdmin.setPassword(passwordEncoder.encode("admin12345"));
                testAdmin.setRole("ADMIN");
                testAdmin.setActive(true);
                userRepository.save(testAdmin);
                System.out.println("Test admin user created");
            }

            // User
            if (userRepository.findByEmail("user@test.com").isEmpty()) {
                User user = new User();
                user.setName("Test User");
                user.setEmail("user@test.com");
                user.setPassword(passwordEncoder.encode("user123"));
                user.setRole("USER");
                user.setActive(true);
                userRepository.save(user);
                System.out.println("Test user created");
            }

            // Sample Doctors
            seedDoctor(userRepository, doctorProfileRepository, passwordEncoder,
                    "Dr. Sarah Smith", "sarah@doc.com", "Cardiologist", 150.0, 12,
                    "Expert in heart rhythm disorders and pacemaker implantation.", "doc1.png");

            seedDoctor(userRepository, doctorProfileRepository, passwordEncoder,
                    "Dr. James Wilson", "james@doc.com", "Dermatologist", 120.0, 8,
                    "Specializes in cosmetic dermatology and skin cancer screening.", "doc2.png");

            seedDoctor(userRepository, doctorProfileRepository, passwordEncoder,
                    "Dr. Emily Chen", "emily@doc.com", "Pediatrician", 100.0, 15,
                    "Caring specialist for children from newborns to adolescents.", "doc3.png");

            seedDoctor(userRepository, doctorProfileRepository, passwordEncoder,
                    "Dr. Michael Brown", "michael@doc.com", "Neurologist", 200.0, 20,
                    "Renowned implementation of neurological care.", "doc4.png");

            seedDoctor(userRepository, doctorProfileRepository, passwordEncoder,
                    "Dr. Lisa Ray", "lisa@doc.com", "Dentist", 80.0, 5,
                    "General dentistry and cosmetic procedures.", "doc5.png");

            // Seed Specializations
            seedSpecialization(specializationRepository, "Cardiologist", "Expert in heart health", "favorite");
            seedSpecialization(specializationRepository, "Dermatologist", "Skin and hair care", "face");
            seedSpecialization(specializationRepository, "Pediatrician", "Children healthcare", "child_care");
            seedSpecialization(specializationRepository, "Neurologist", "Brain and nervous system", "psychology");
            seedSpecialization(specializationRepository, "Dentist", "Oral health", "tooth");
            seedSpecialization(specializationRepository, "General Physician", "Primary healthcare", "medical_services");
        };
    }

    private void seedSpecialization(com.medicareplus.backend.repository.SpecializationRepository repo, String name,
            String desc, String icon) {
        if (repo.findByName(name).isEmpty()) {
            com.medicareplus.backend.entity.Specialization spec = new com.medicareplus.backend.entity.Specialization();
            spec.setName(name);
            spec.setDescription(desc);
            spec.setIcon(icon);
            repo.save(spec);
        }
    }

    private void seedDoctor(UserRepository userRepo, DoctorProfileRepository docRepo, PasswordEncoder encoder,
            String name, String email, String specialization, Double fee, Integer experience, String about,
            String image) {
        if (userRepo.findByEmail(email).isEmpty()) {
            User user = new User();
            user.setName(name);
            user.setEmail(email);
            user.setPassword(encoder.encode("doc123"));
            user.setRole("DOCTOR");
            user.setActive(true);
            user = userRepo.save(user);

            DoctorProfile profile = new DoctorProfile();
            profile.setUserId(user.getId());
            profile.setSpecialization(specialization);
            profile.setFee(fee);
            profile.setExperience(experience);
            profile.setAbout(about);
            profile.setApproved(true);
            profile.setImage(image); // Set Image
            docRepo.save(profile);
            System.out.println("Seeded doctor: " + name);
        }
    }
}
