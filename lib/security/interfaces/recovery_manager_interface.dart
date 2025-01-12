import 'package:injectable/injectable.dart';
import '../../core/interfaces/base_service.dart';
import '../types/recovery_types.dart';

abstract class IRecoveryManager implements IService {
  Future<bool> canAutoRecover(RecoveryContext context);
  Future<bool> performAutoRecovery(RecoveryContext context);
  Future<Duration> estimateRecoveryTime(RecoveryContext context);
  Future<List<RecoveryStep>> getRecoverySteps(RecoveryContext context);
  Future<bool> executeRecoveryStep(RecoveryStep step, RecoveryContext context);
  Future<void> logRecoveryProgress(String message, RecoveryContext context);
}
