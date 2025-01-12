import 'base_service.dart';

abstract class IStorageProtector implements IService {
  Future<void> secureCriticalData();
  Future<bool> verifyProtection();
  Future<ProtectionReport> generateReport();
  Stream<ProtectionEvent> get protectionEvents;
}

class ProtectionReport {
  final bool isSecure;
  final List<SecurityIssue> issues;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  ProtectionReport({
    required this.isSecure,
    required this.issues,
    required this.metadata,
  }) : timestamp = DateTime.now();
}

class SecurityIssue {
  final String id;
  final SecuritySeverity severity;
  final String description;
  final String location;
  final DateTime detectedAt;

  SecurityIssue({
    required this.id,
    required this.severity,
    required this.description,
    required this.location,
  }) : detectedAt = DateTime.now();
}

class ProtectionEvent {
  final ProtectionEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  ProtectionEvent({
    required this.type,
    required this.data,
  }) : timestamp = DateTime.now();
}

enum SecuritySeverity {
  critical,
  high,
  medium,
  low,
}

enum ProtectionEventType {
  protectionStarted,
  protectionCompleted,
  issueDetected,
  protectionApplied,
  error,
}
