import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;
  String? _role;
  int? _userId;

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('AuthService: login success. Data: $data');
        _token = data['token'];
        _role = data['role'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token ?? '');
        await prefs.setString('role', _role ?? 'USER');
        await prefs.setString('email', email);
        await prefs.setString('name', data['name'] ?? '');
        
        final dynamic idValue = data['id'];
        if (idValue is int) {
          await prefs.setInt('userId', idValue);
          _userId = idValue;
        } else if (idValue is String) {
          final parsedId = int.tryParse(idValue);
          if (parsedId != null) {
            await prefs.setInt('userId', parsedId);
            _userId = parsedId;
          }
        }
        
        if (data['profileImage'] != null) {
          await prefs.setString('profileImage', data['profileImage']);
        }
        return true;
      } else {
        debugPrint('Login failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Login exception: $e');
      throw Exception('Login error: $e');
    }
  }

  Future<bool> register(String name, String email, String password, String role) async {
    try {
      debugPrint('AuthService: Registering user $email with role $role at ${ApiConstants.register}');
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role
        }),
      );

      debugPrint('AuthService: Register response status: ${response.statusCode}');
      debugPrint('AuthService: Register response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _token = null;
    _role = null;
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token;
  }

  Future<String?> getRole() async {
    if (_role != null) return _role;
    final prefs = await SharedPreferences.getInstance();
    _role = prefs.getString('role');
    return _role;
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  Future<int?> getUserId() async {
    if (_userId != null) return _userId;
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
    return _userId;
  }

  Future<String?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profileImage');
  }

  Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phoneNumber');
  }

  Future<String?> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('address');
  }

  Future<String?> getGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gender');
  }

  Future<String?> getDob() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('dob');
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/user/profile'), // Adjust base URL if needed, usually ApiConstants.baseUrl + '/user/profile'
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final user = responseData['user'];
        final prefs = await SharedPreferences.getInstance();
        
        if (user['name'] != null) await prefs.setString('name', user['name']);
        if (user['phoneNumber'] != null) await prefs.setString('phoneNumber', user['phoneNumber']);
        if (user['address'] != null) await prefs.setString('address', user['address']);
        if (user['gender'] != null) await prefs.setString('gender', user['gender']);
        if (user['dob'] != null) await prefs.setString('dob', user['dob']);
        
        return true;
      } else {
        debugPrint('Update profile failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      return false;
    }
  }
}
