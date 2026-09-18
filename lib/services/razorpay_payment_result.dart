class RazorpayPaymentResult {
  final bool success;
  final bool cancelled;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? errorMessage;

  const RazorpayPaymentResult({
    required this.success,
    this.cancelled = false,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorMessage,
  });
}
