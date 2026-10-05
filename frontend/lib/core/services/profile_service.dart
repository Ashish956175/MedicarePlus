import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../constants/api_constants.dart';
import 'auth_service.dart';

class ProfileService {
  final AuthService _authService = AuthService();

  Future<String?> uploadProfileImage(XFile imageFile) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.profileUpload));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['fileName'];
      }
      return null;
    } catch (e) {
      print('Profile upload error: $e');
      return null;
    }
  }

  Future<bool> removeProfileImage() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse(ApiConstants.profileRemove),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Profile remove error: $e');
      return false;
    }
  }
}
