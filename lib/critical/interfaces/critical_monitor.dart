import '../../core/interfaces/base_service.dart';
import '../models/diagnosis.dart';

abstract class ICriticalMonitor implements IService {
  Future<void> startMonitoring();
  Future<void> stopMonitoring();
  Future<bool> isMonitoring();
  Future<DiagnosisStatus> getCurrentStatus();
  Stream<DiagnosticResult> monitorCriticalEvents();
  Future<List<DiagnosticResult>> getRecentEvents();
}
