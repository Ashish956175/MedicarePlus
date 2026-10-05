package com.medicareplus.backend.controller;

import com.medicareplus.backend.entity.DoctorProfile;
import com.medicareplus.backend.repository.DoctorProfileRepository;
import com.medicareplus.backend.entity.User;
import com.medicareplus.backend.payload.request.LoginRequest;
import com.medicareplus.backend.payload.request.SignupRequest;
import com.medicareplus.backend.payload.response.JwtResponse;
import com.medicareplus.backend.payload.response.MessageResponse;
import com.medicareplus.backend.repository.UserRepository;
import com.medicareplus.backend.security.jwt.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.userdetails.UserDetails;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    @Autowired
    AuthenticationManager authenticationManager;

    @Autowired
    UserRepository userRepository;

    @Autowired
    DoctorProfileRepository doctorProfileRepository;

    @Autowired
    PasswordEncoder encoder;

    @Autowired
    JwtUtils jwtUtils;

    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@RequestBody LoginRequest loginRequest) {

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.getEmail(), loginRequest.getPassword()));

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtUtils.generateJwtToken(authentication);

        UserDetails userDetails = (UserDetails) authentication.getPrincipal(); // This cast might need care if using
                                                                               // UserDetailsImpl
        // Ideally should cast to custom implementation if accessing more fields, but
        // UserDetails has username/authorities

        // Let's get the user entity to get the ID and Name
        User user = userRepository.findByEmail(userDetails.getUsername()).orElseThrow();

        return ResponseEntity.ok(new JwtResponse(jwt,
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getRole(),
                user.getProfileImage()));
    }

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody SignupRequest signUpRequest) {
        if (userRepository.findByEmail(signUpRequest.getEmail()).isPresent()) {
            return ResponseEntity
                    .badRequest()
                    .body(new MessageResponse("Error: Email is already in use!"));
        }

        // Create new user's account
        User user = new User();
        user.setName(signUpRequest.getName());
        user.setEmail(signUpRequest.getEmail());
        user.setPassword(encoder.encode(signUpRequest.getPassword()));
        user.setRole(signUpRequest.getRole());
        user.setActive(true);

        User savedUser = userRepository.save(user);

        // If DOCTOR, create profile
        if ("DOCTOR".equals(signUpRequest.getRole())) {
            DoctorProfile profile = new DoctorProfile();
            profile.setUserId(savedUser.getId());
            profile.setSpecialization(
                    signUpRequest.getSpecialization() != null ? signUpRequest.getSpecialization() : "General");
            profile.setExperience(signUpRequest.getExperience() != null ? signUpRequest.getExperience() : 0);
            profile.setFee(signUpRequest.getFee() != null ? signUpRequest.getFee() : 0.0);
            profile.setApproved(true); // Auto-approve for demo/flow support as requested
            profile.setAbout("Passionate medical professional.");
            profile.setImage("https://i.pravatar.cc/150");
            doctorProfileRepository.save(profile);
        }

        return ResponseEntity.ok(new MessageResponse("User registered successfully!"));
    }
}
