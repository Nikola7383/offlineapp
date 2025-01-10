class VerificationResult {
  final bool isValid;
  final SecureMessage message;
  final DateTime verifiedAt;
  final String? failureReason;

  const VerificationResult({
    required this.isValid,
    required this.message,
    required this.verifiedAt,
    this.failureReason,
  });

  bool get hasError => !isValid && failureReason != null;

  Map<String, dynamic> toMap() {
    return {
      'isValid': isValid,
      'messageId': message.originalMessage.id,
      'verifiedAt': verifiedAt.millisecondsSinceEpoch,
      'failureReason': failureReason,
    };
  }
}
