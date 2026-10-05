import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../constants/api_constants.dart';

class PrescriptionService {

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> createPrescription({
    required int appointmentId,
    required int patientId,
    required String diagnosis,
    required List<Map<String, String>> medicines,
    required String advice,
  }) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      'appointmentId': appointmentId,
      'patientId': patientId,
      'diagnosis': diagnosis,
      'medicines': jsonEncode(medicines),
      'advice': advice,
    });

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/doctor/prescriptions'),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create prescription: ${response.body}');
    }
  }

  Future<Map<String, dynamic>?> getPrescriptionForAppointment(int appointmentId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/doctor/prescriptions/appointment/$appointmentId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch prescription');
    }
  }

  Future<List<dynamic>> getPatientPrescriptions(int patientId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/user/prescriptions/$patientId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch prescriptions');
    }
  }
}
