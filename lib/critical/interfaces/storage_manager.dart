import '../../core/interfaces/base_service.dart';

abstract class IStorageManager implements IService {
  Future<double> getStorageUsage();
  Future<void> optimizeCriticalStorage();
  Future<void> cleanupTemporaryFiles();
  Future<void> compressOldData();
  Future<Map<String, double>> getStorageBreakdown();
  Stream<double> monitorStorageUsage();
}
