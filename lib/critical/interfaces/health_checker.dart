import '../../core/interfaces/base_service.dart';
import '../models/diagnosis.dart';

abstract class IHealthChecker implements IService {
  Future<DiagnosisStatus> checkSystemHealth();
  Future<void> startHealthMonitoring();
  Future<void> stopHealthMonitoring();
  Future<bool> isHealthMonitoringActive();
  Stream<DiagnosisStatus> monitorHealthStatus();
  Future<List<DiagnosticResult>> getHealthHistory();
}
