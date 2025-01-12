import '../../core/interfaces/base_service.dart';
import '../models/diagnosis.dart';

abstract class ISystemFailsafe implements IService {
  Future<SystemStatus> checkStatus();
  Future<void> activateFailsafe();
  Future<void> deactivateFailsafe();
  Future<void> performEmergencyShutdown();
  Future<void> restoreFromFailsafe();
  Stream<SystemStatus> monitorFailsafe();
}
