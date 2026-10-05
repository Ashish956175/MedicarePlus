import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/foundation.dart';
import 'payment_service_stub.dart' if (dart.library.js) 'payment_service_web.dart';
// Custom Response Wrappers to avoid non-public constructor errors
class MediCarePaymentSuccess {
  final String? paymentId;
  final String? orderId;
  final String? signature;
  MediCarePaymentSuccess(this.paymentId, this.orderId, this.signature);
}

class MediCarePaymentFailure {
  final int? code;
  final String? message;
  MediCarePaymentFailure(this.code, this.message);
}

class PaymentService {
  late Razorpay _razorpay;
  final String _apiKey = 'rzp_test_RweHOv67FmmvZE';

  // Callbacks use our custom wrappers
  Function(MediCarePaymentSuccess)? onSuccess;
  Function(MediCarePaymentFailure)? onFailure;

  PaymentService() {
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _mobileHandlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _mobileHandlePaymentError);
    }
  }

  void openCheckout({
    required double amount,
    required String name,
    required String description,
    required String email,
    required String contact,
  }) {
    var options = {
      'key': _apiKey,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'MediCarePlus',
      'description': description,
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': contact, 'email': email},
      'theme': {'color': '#6366F1'} // App Primary Color (Indigo)
    };

    if (kIsWeb) {
      _openWebCheckout(options);
    } else {
      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint('Error opening Razorpay: $e');
      }
    }
  }

  void _openWebCheckout(Map<String, dynamic> options) {
    openWebCheckout(options, onSuccess, onFailure);
  }

  // Mobile handlers that map to our custom wrappers
  void _mobileHandlePaymentSuccess(PaymentSuccessResponse response) {
    onSuccess?.call(MediCarePaymentSuccess(response.paymentId, response.orderId, response.signature));
  }

  void _mobileHandlePaymentError(PaymentFailureResponse response) {
    onFailure?.call(MediCarePaymentFailure(response.code, response.message));
  }

  void dispose() {
    if (!kIsWeb) {
      _razorpay.clear();
    }
  }
}
