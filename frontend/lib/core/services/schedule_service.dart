import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/availability_model.dart';
import 'auth_service.dart';

class ScheduleService {
  Future<List<Availability>> getMyAvailability() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/doctor/my-availability'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Availability.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load availability');
    }
  }

  Future<List<Availability>> getDoctorAvailability(int doctorId) async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/doctor/$doctorId/availability'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Availability.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load doctor availability');
    }
  }

  Future<bool> addAvailability(String date, String timeSlot) async {
    final token = await AuthService().getToken();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/doctor/availability'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'date': date,
        'timeSlot': timeSlot,
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteAvailability(String date, String timeSlot) async {
    final token = await AuthService().getToken();
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/doctor/availability?date=$date&timeSlot=$timeSlot'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }
}
