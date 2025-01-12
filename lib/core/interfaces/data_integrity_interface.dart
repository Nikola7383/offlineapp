import 'base_service.dart';

abstract class IDataIntegrityGuard implements IService {
  Future<void> protectData();
  Future<bool> verifyIntegrity();
  Future<IntegrityReport> generateReport();
  Stream<IntegrityEvent> get integrityEvents;
}

class IntegrityReport {
  final bool isValid;
  final List<IntegrityIssue> issues;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  IntegrityReport({
    required this.isValid,
    required this.issues,
    required this.metadata,
  }) : timestamp = DateTime.now();
}

class IntegrityIssue {
  final String id;
  final IssueSeverity severity;
  final String description;
  final String location;
  final DateTime detectedAt;

  IntegrityIssue({
    required this.id,
    required this.severity,
    required this.description,
    required this.location,
  }) : detectedAt = DateTime.now();
}

class IntegrityEvent {
  final IntegrityEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  IntegrityEvent({
    required this.type,
    required this.data,
  }) : timestamp = DateTime.now();
}

enum IssueSeverity {
  critical,
  high,
  medium,
  low,
}

enum IntegrityEventType {
  checkStarted,
  checkCompleted,
  issueDetected,
  protectionApplied,
  error,
}
