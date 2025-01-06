class PerformanceMetrics {
  final int memoryUsage;
  final int messageQueueSize;
  final int responseTimeMs;
  final DateTime timestamp;

  PerformanceMetrics({
    required this.memoryUsage,
    required this.messageQueueSize,
    required this.responseTimeMs,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class SecurityMetrics {
  final bool encryptionActive;
  final int activeNodes;
  final int securityIncidents;
  final DateTime lastAudit;

  SecurityMetrics({
    required this.encryptionActive,
    required this.activeNodes,
    required this.securityIncidents,
    required this.lastAudit,
  });
}

class AuditResult {
  final bool passed;
  final String message;
  final DateTime timestamp;

  AuditResult({
    required this.passed,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
