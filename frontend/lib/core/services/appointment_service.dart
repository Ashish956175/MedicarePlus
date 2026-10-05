import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/appointment_model.dart';
import 'auth_service.dart';

class AppointmentService {
  Future<List<Appointment>> getUserAppointments() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/appointments/my'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  Future<bool> bookAppointment(int doctorId, String date, String timeSlot) async {
    final token = await AuthService().getToken();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/appointments/book'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'doctorId': doctorId,
        'date': date,
        'timeSlot': timeSlot,
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> cancelAppointment(int appointmentId) async {
    final token = await AuthService().getToken();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/appointments/cancel'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'id': appointmentId}),
    );

    return response.statusCode == 200;
  }
}
