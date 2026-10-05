import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/doctor_model.dart';
import 'auth_service.dart';

class UserService {
  Future<List<Doctor>> getAllDoctors() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse(ApiConstants.doctors),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Doctor.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  Future<List<Doctor>> getTopDoctors() async {
    // For now, return all doctors as top doctors
    return getAllDoctors();
  }
}
