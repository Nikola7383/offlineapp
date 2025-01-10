class DeliveryAttempt {
  final FailedMessage message;
  final dynamic error;
  final DateTime timestamp;
  
  DeliveryAttempt({
    required this.message,
    required this.error,
    required this.timestamp,
  });

  bool get isRecent => 
    DateTime.now().difference(timestamp) < Duration(minutes: 30);

  Map<String, dynamic> toMap() => {
    'messageId': message.id,
    'error': error.toString(),
    'timestamp': timestamp.toIso8601String(),
    'retryCount': message.retryCount,
  };
}

class FixVerificationResult {
  final String messageId;
  final bool isSuccess;
  final String? error;
  
  FixVerificationResult({
    required this.messageId,
    required this.isSuccess,
    this.error,
  });
} 