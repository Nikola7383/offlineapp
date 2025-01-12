import '../../core/interfaces/base_service.dart';
import '../models/recovery_plan.dart';
import '../models/recovery_result.dart';

abstract class IEmergencyRecovery implements IService {
  Future<RecoveryResult> executeRecovery(RecoveryPlan plan);
  Future<void> abortRecovery();
  Future<RecoveryPlan> generateRecoveryPlan();
  Future<bool> validateRecoveryPlan(RecoveryPlan plan);
  Stream<RecoveryResult> monitorRecovery();
}
