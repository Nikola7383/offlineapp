import '../../core/interfaces/base_service.dart';

abstract class ICriticalDataManager implements IService {
  Future<Map<String, dynamic>> identifyCriticalData();
  Future<void> backupCriticalData(Map<String, dynamic> data);
  Future<void> restoreCriticalData();
  Future<bool> verifyCriticalData();
  Future<void> cleanupCriticalData();
}
