import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    } else {
      return 'http://localhost:8080/api';
    }
  }

  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get doctors => '$baseUrl/user/doctors';
  
  // Profile
  static String get profileUpload => '$baseUrl/profile/upload';
  static String get profileRemove => '$baseUrl/profile/remove';
  static String get profileImage => '$baseUrl/profile/image';
}

