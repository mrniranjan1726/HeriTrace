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
  return const RazorpayPaymentResult(
    success: false,
    errorMessage: 'Razorpay is not supported on this platform.',
  );
}
