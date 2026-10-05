import 'dart:js' as js;
import 'dart:js_util' as js_util;

import 'payment_service.dart';

void openWebCheckout(Map<String, dynamic> options, Function(MediCarePaymentSuccess)? onSuccess, Function(MediCarePaymentFailure)? onFailure) {
  js.context.callMethod('openRazorpayCheckout', [
    js.JsObject.jsify(options),
    js_util.allowInterop((String paymentId, String? orderId, String? signature) {
      onSuccess?.call(MediCarePaymentSuccess(paymentId, orderId, signature));
    }),
    js_util.allowInterop((String errorMessage) {
      onFailure?.call(MediCarePaymentFailure(0, errorMessage));
    }),
  ]);
}
