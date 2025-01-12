import '../../core/interfaces/base_service.dart';
import '../models/diagnosis.dart';

abstract class IAlertSystem implements IService {
  Future<void> raiseAlert(String message, DiagnosticSeverity severity);
  Future<void> clearAlert(String alertId);
  Future<void> clearAllAlerts();
  Future<List<String>> getActiveAlerts();
  Stream<String> monitorAlerts();
  Future<void> acknowledgeAlert(String alertId);
}
