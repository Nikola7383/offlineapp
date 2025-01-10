class VerificationResult {
  final bool isSuccess;
  final Map<String, dynamic>? messageMetrics;
  final Map<String, dynamic>? dbMetrics;
  final Map<String, dynamic>? memoryMetrics;
  final String? error;

  VerificationResult({
    required this.isSuccess,
    this.messageMetrics,
    this.dbMetrics,
    this.memoryMetrics,
    this.error,
  });

  bool get hasErrors => error != null;

  Map<String, dynamic> toJson() => {
        'success': isSuccess,
        'message_metrics': messageMetrics,
        'db_metrics': dbMetrics,
        'memory_metrics': memoryMetrics,
        'error': error,
      };
}

class ComponentResult {
  final bool isSuccess;
  final Map<String, dynamic> metrics;

  ComponentResult({
    required this.isSuccess,
    required this.metrics,
  });
}
