import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicare_plus/core/constants/api_constants.dart';
import 'package:medicare_plus/core/services/auth_service.dart';

class PharmacyService {
  Future<Map<String, dynamic>> placeOrder({
    required double totalAmount,
    required List<Map<String, dynamic>> items,
    required String address,
    required String contactNumber,
    String status = 'PENDING',
    String paymentStatus = 'PENDING',
  }) async {
    final token = await AuthService().getToken();
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/pharmacy/order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'totalAmount': totalAmount,
          'items': items,
          'address': address,
          'contactNumber': contactNumber,
          'status': status,
          'paymentStatus': paymentStatus,
        }),
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to place order: ${response.statusCode}');
      }
    } catch (e) {
      print('Error placing order: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getMyOrders() async {
    final token = await AuthService().getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/pharmacy/orders/my'),
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
      print('Error fetching orders: $e');
      return [];
    }
  }

  Future<void> updatePaymentStatus(int orderId, String status) async {
    final token = await AuthService().getToken();
    try {
      await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/pharmacy/orders/$orderId/status?status=PENDING&paymentStatus=$status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print('Error updating payment status: $e');
    }
  }
}
