import 'base_service.dart';
import '../../models/emergency_options.dart';

abstract class IEmergencyModeManager implements IService {
  Future<void> activate({required EmergencyOptions options});
  Future<void> deactivate();
  Future<bool> isActive();
  Future<EmergencyModeReport> generateReport();
  Stream<EmergencyModeEvent> get modeEvents;
}

class EmergencyModeReport {
  final bool isActive;
  final DateTime activatedAt;
  final EmergencyOptions currentOptions;
  final List<String> activeRestrictions;
  final Map<String, dynamic> metadata;

  EmergencyModeReport({
    required this.isActive,
    required this.activatedAt,
    required this.currentOptions,
    required this.activeRestrictions,
    required this.metadata,
  });
}

class EmergencyModeEvent {
  final EmergencyEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  EmergencyModeEvent({
    required this.type,
    required this.data,
  }) : timestamp = DateTime.now();
}

enum EmergencyEventType {
  activated,
  deactivated,
  optionsChanged,
  restrictionAdded,
  restrictionRemoved,
  error,
}
