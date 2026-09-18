import 'razorpay_payment_result.dart';

import 'razorpay_service_stub.dart'
    if (dart.library.js_interop) 'razorpay_service_web.dart'
    if (dart.library.io) 'razorpay_service_mobile.dart';

export 'razorpay_payment_result.dart';

Future<RazorpayPaymentResult> openRazorpayCheckout({
  required String keyId,
  required int amountPaise,
  required String orderId,
  required String name,
  required String description,
  String? email,
  String? phone,
}) {
  return openPlatformRazorpayCheckout(
    keyId: keyId,
    amountPaise: amountPaise,
    orderId: orderId,
    name: name,
    description: description,
    email: email,
    phone: phone,
  );
}
