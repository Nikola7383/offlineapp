import '../../core/interfaces/base_service.dart';
import '../models/diagnosis.dart';

abstract class IDiagnosticSystem implements IService {
  Future<Diagnosis> performDiagnosis();
  Future<void> startDiagnosticScan();
  Future<void> stopDiagnosticScan();
  Future<bool> isDiagnosticRunning();
  Stream<DiagnosticResult> monitorDiagnostics();
  Future<List<DiagnosticResult>> getLastDiagnosticResults();
}
