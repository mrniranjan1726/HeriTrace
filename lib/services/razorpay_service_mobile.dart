import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

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

  final razorpay = Razorpay();

  void complete(RazorpayPaymentResult result) {
    if (!completer.isCompleted) {
      completer.complete(result);
    }

    try {
      razorpay.clear();
    } catch (_) {}
  }

  // ─────────────────────────────────────────────
  // PAYMENT SUCCESS
  // ─────────────────────────────────────────────
  razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
    PaymentSuccessResponse response,
  ) {
    complete(
      RazorpayPaymentResult(
        success: true,
        paymentId: response.paymentId,
        orderId: response.orderId,
        signature: response.signature,
      ),
    );
  });

  // ─────────────────────────────────────────────
  // PAYMENT ERROR
  // ─────────────────────────────────────────────
  razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
    complete(
      RazorpayPaymentResult(
        success: false,
        errorMessage:
            'Payment failed: '
            '${response.code} '
            '${response.message ?? ''}',
      ),
    );
  });

  // ─────────────────────────────────────────────
  // EXTERNAL WALLET
  // ─────────────────────────────────────────────
  razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (
    ExternalWalletResponse response,
  ) {
    complete(
      RazorpayPaymentResult(
        success: false,
        errorMessage:
            'External wallet selected: '
            '${response.walletName ?? 'Unknown wallet'}',
      ),
    );
  });

  // ─────────────────────────────────────────────
  // RAZORPAY CHECKOUT OPTIONS
  // ─────────────────────────────────────────────
  final options = {
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
  };

  // ─────────────────────────────────────────────
  // OPEN CHECKOUT
  // ─────────────────────────────────────────────
  try {
    razorpay.open(options);
  } catch (e) {
    complete(
      RazorpayPaymentResult(
        success: false,
        errorMessage: 'Unable to open Razorpay: $e',
      ),
    );
  }

  return completer.future;
}
