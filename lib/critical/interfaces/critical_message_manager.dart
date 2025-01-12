import '../../core/interfaces/base_service.dart';
import '../models/diagnosis.dart';

abstract class ICriticalMessageManager implements IService {
  Future<void> sendCriticalMessage(String message, DiagnosticSeverity severity);
  Future<void> broadcastAlert(String alert, {bool isEmergency = false});
  Future<void> notifyStateChange(DiagnosisStatus newStatus);
  Stream<String> listenForCriticalMessages();
  Future<List<String>> getPendingMessages();
}
