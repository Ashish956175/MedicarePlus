import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'auth_service.dart';
import '../models/appointment_model.dart';
import '../models/specialization_model.dart';
import '../models/audit_log_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  Future<Map<String, dynamic>> getStats() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load stats');
    }
  }

  Future<Map<String, dynamic>> getRevenueStats() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/revenue-stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load revenue stats');
    }
  }

  Future<List<dynamic>> getPendingDoctors() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/doctors/pending'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load pending doctors');
    }
  }

  Future<bool> approveDoctor(int doctorId) async {
    final token = await AuthService().getToken();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/admin/doctors/$doctorId/approve'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<List<Appointment>> getAllAppointments() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/appointments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load all appointments');
    }
  }

  Future<List<Specialization>> getSpecializations() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/specializations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Specialization.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load specializations');
    }
  }

  Future<bool> addSpecialization(String name, String description, String icon) async {
    final token = await AuthService().getToken();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/admin/specializations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'icon': icon,
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteSpecialization(int id) async {
    final token = await AuthService().getToken();
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/admin/specializations/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  Future<List<AuditLog>> getLogs() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/logs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AuditLog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load logs');
    }
  }

  Future<List<Map<String, dynamic>>> getPendingPayouts() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/payouts/pending'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load pending payouts');
    }
  }

  Future<List<Appointment>> getPendingPayoutDetails(int doctorId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/payouts/pending/$doctorId'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Appointment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching pending payout details: $e');
      return [];
    }
  }

  Future<bool> processPayout(
      int doctorId,
      double amount, {
      String method = 'BANK_TRANSFER',
      String? reference,
      String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/payouts/process'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'doctorId': doctorId,
          'amount': amount,
          'paymentMethod': method,
          'transactionReference': reference ?? 'REF-${DateTime.now().millisecondsSinceEpoch}',
          'notes': notes ?? '',
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error processing payout: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getPayoutHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/payouts/history'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching payout history: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPayoutDetails(int payoutId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/payouts/$payoutId/details'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching payout details: $e');
      return null;
    }
  }
}
