import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/appointment_model.dart';
import 'auth_service.dart';

class DoctorService {
  Future<List<Appointment>> getDoctorAppointments() async {
    final token = await AuthService().getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/appointments/doctor/my'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Appointment.fromJson(json)).toList();
      } else {
        // If endpoint doesn't exist yet or fails, return empty list to prevent crash
        print('Failed to load doctor appointments: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching doctor appointments: $e');
      return [];
    }
  }

  // Calculate stats strictly on client side as requested
  Map<String, int> calculateStats(List<Appointment> appointments) {
    int pending = 0;
    int completed = 0;
    int total = appointments.length;

    for (var app in appointments) {
      if (app.status == 'BOOKED') pending++;
      if (app.status == 'COMPLETED') completed++;
    }

    return {
      'pending': pending,
      'completed': completed,
      'total': total,
    };
  }

  Future<bool> completeAppointment(int id) async {
    final token = await AuthService().getToken();
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/doctor/appointments/$id/complete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error completing appointment: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    final token = await AuthService().getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/doctor/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load stats');
      }
    } catch (e) {
      print('Error fetching doctor stats: $e');
      // Return basic structure to avoid crashes in UI
      return {
        'totalAppointments': 0,
        'completedAppointments': 0,
        'pendingAppointments': 0,
        'totalEarnings': 0.0,
        'rating': 0.0,
        'totalReviews': 0,
      };
    }
  }

  Future<List<dynamic>> getDoctorPatients() async {
    final token = await AuthService().getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/doctor/patients'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching doctor patients: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getPatientHistory(int patientId) async {
    final token = await AuthService().getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/doctor/patients/$patientId/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load patient history');
      }
    } catch (e) {
      print('Error fetching patient history: $e');
      return {'prescriptions': [], 'medicalRecords': []};
    }
  }

  Future<Map<String, dynamic>> getPatientInsights(int patientId) async {
    final token = await AuthService().getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/doctor/patients/$patientId/insights'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load patient insights');
      }
    } catch (e) {
      print('Error fetching patient insights: $e');
      return {};
    }
  }
  Future<Map<String, dynamic>> getDoctorProfile() async {
    final token = await AuthService().getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/doctor/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load doctor profile');
      }
    } catch (e) {
      print('Error fetching doctor profile: $e');
      return {};
    }
  }

  Future<bool> updateFee(double fee) async {
    final token = await AuthService().getToken();
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/doctor/profile/fee'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'fee': fee}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating fee: $e');
      return false;
    }
  }
}
