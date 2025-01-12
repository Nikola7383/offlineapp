import 'base_service.dart';

abstract class IDatabaseValidator implements IService {
  Future<bool> validateDatabase();
  Future<ValidationReport> generateReport();
  Stream<ValidationEvent> get validationEvents;
}

class ValidationReport {
  final bool isValid;
  final List<ValidationIssue> issues;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  ValidationReport({
    required this.isValid,
    required this.issues,
    required this.metadata,
  }) : timestamp = DateTime.now();
}

class ValidationIssue {
  final String id;
  final ValidationSeverity severity;
  final String description;
  final String location;
  final DateTime detectedAt;

  ValidationIssue({
    required this.id,
    required this.severity,
    required this.description,
    required this.location,
  }) : detectedAt = DateTime.now();
}

class ValidationEvent {
  final ValidationEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  ValidationEvent({
    required this.type,
    required this.data,
  }) : timestamp = DateTime.now();
}

enum ValidationSeverity {
  critical,
  high,
  medium,
  low,
}

enum ValidationEventType {
  validationStarted,
  validationCompleted,
  issueDetected,
  correctionApplied,
  error,
}
