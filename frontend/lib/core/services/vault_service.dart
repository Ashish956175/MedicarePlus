import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../constants/api_constants.dart';

class VaultService {

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> saveRecord({
    required int userId,
    required String title,
    required String description,
    required String recordType,
    String? fileUrl,
  }) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      'userId': userId,
      'title': title,
      'description': description,
      'recordType': recordType,
      'fileUrl': fileUrl,
    });

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/user/medical-records'),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save medical record');
    }
  }

  Future<List<dynamic>> getMyRecords() async {
    final userId = await AuthService().getUserId();
    if (userId == null) throw Exception('User not logged in');
    return getUserRecords(userId);
  }

  Future<List<dynamic>> getUserRecords(int userId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/user/medical-records/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch medical records');
    }
  }
}
