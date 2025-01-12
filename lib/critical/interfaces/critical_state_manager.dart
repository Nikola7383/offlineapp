import '../../core/interfaces/base_service.dart';
import '../models/diagnosis.dart';

abstract class ICriticalStateManager implements IService {
  Future<Status> checkStatus();
  Future<void> enterCriticalState();
  Future<void> exitCriticalState();
  Future<void> handleStateChange(DiagnosisStatus newStatus);
  Stream<Status> monitorState();
}
