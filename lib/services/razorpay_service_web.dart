import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'razorpay_payment_result.dart';

Future<RazorpayPaymentResult> openPlatformRazorpayCheckout({
  required String keyId,
  required int amountPaise,
  required String orderId,
  required String name,
  required String description,
  String? email,
  String? phone,
}) async {
  final completer = Completer<RazorpayPaymentResult>();

  try {
    // Get Razorpay constructor from Checkout.js
    final razorpayValue = globalContext['Razorpay'];

    if (razorpayValue == null || razorpayValue.isUndefinedOrNull) {
      return const RazorpayPaymentResult(
        success: false,
        errorMessage:
            'Razorpay Checkout.js is not loaded. '
            'Please check web/index.html.',
      );
    }

    final razorpayConstructor = razorpayValue as JSFunction;

    // Build Razorpay options
    final options = <String, Object?>{
      'key': keyId,
      'amount': amountPaise,
      'currency': 'INR',
      'name': name,
      'description': description,
      'order_id': orderId,

      'prefill': {
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'contact': phone,
      },

      'theme': {'color': '#176B5B'},

      'modal': {
        'ondismiss': () {
          if (!completer.isCompleted) {
            completer.complete(
              const RazorpayPaymentResult(
                success: false,
                cancelled: true,
                errorMessage: 'Payment window closed.',
              ),
            );
          }
        }.toJS,
      },

      'handler': (JSAny? response) {
        try {
          final responseData = response?.dartify();

          if (responseData is! Map) {
            if (!completer.isCompleted) {
              completer.complete(
                const RazorpayPaymentResult(
                  success: false,
                  errorMessage: 'Invalid Razorpay payment response.',
                ),
              );
            }
            return;
          }

          final paymentId = responseData['razorpay_payment_id']?.toString();

          final returnedOrderId = responseData['razorpay_order_id']?.toString();

          final signature = responseData['razorpay_signature']?.toString();

          if (!completer.isCompleted) {
            completer.complete(
              RazorpayPaymentResult(
                success: true,
                paymentId: paymentId,
                orderId: returnedOrderId,
                signature: signature,
              ),
            );
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.complete(
              RazorpayPaymentResult(
                success: false,
                errorMessage: 'Unable to read Razorpay payment response: $e',
              ),
            );
          }
        }
      }.toJS,
    };

    // Convert Dart options map to JavaScript object.
    final jsOptions = options.jsify();

    if (jsOptions == null) {
      return const RazorpayPaymentResult(
        success: false,
        errorMessage: 'Unable to create Razorpay checkout options.',
      );
    }

    // Create Razorpay instance.
    final razorpayObject = razorpayConstructor.callAsConstructor<JSObject>(
      jsOptions,
    );

    // Open Razorpay Checkout.
    razorpayObject.callMethod('open'.toJS);

    // Wait for the payment callback.
    return await completer.future;
  } catch (e) {
    return RazorpayPaymentResult(
      success: false,
      errorMessage: 'Unable to open Razorpay Checkout: $e',
    );
  }
}
