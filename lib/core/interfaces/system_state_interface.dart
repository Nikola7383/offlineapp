import 'base_service.dart';

abstract class ISystemStateManager implements IService {
  Future<SystemState> getCurrentState();
  Future<void> updateState(SystemState newState);
  Stream<SystemStateChange> get stateChanges;
  Future<StateReport> generateReport();
}

class SystemState {
  final bool isOperational;
  final SystemMode mode;
  final Map<String, dynamic> configuration;
  final DateTime lastUpdate;
  final List<String> activeProcesses;

  SystemState({
    required this.isOperational,
    required this.mode,
    required this.configuration,
    required this.activeProcesses,
  }) : lastUpdate = DateTime.now();
}

class SystemStateChange {
  final SystemMode previousMode;
  final SystemMode newMode;
  final String reason;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  SystemStateChange({
    required this.previousMode,
    required this.newMode,
    required this.reason,
    required this.metadata,
  }) : timestamp = DateTime.now();
}

class StateReport {
  final bool isHealthy;
  final List<StateIssue> issues;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  StateReport({
    required this.isHealthy,
    required this.issues,
    required this.metadata,
  }) : timestamp = DateTime.now();
}

class StateIssue {
  final String id;
  final StateSeverity severity;
  final String description;
  final String component;
  final DateTime detectedAt;

  StateIssue({
    required this.id,
    required this.severity,
    required this.description,
    required this.component,
  }) : detectedAt = DateTime.now();
}

enum SystemMode {
  normal,
  emergency,
  maintenance,
  recovery,
  diagnostic,
}

enum StateSeverity {
  critical,
  high,
  medium,
  low,
}
