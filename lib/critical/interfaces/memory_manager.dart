import '../../core/interfaces/base_service.dart';

abstract class IMemoryManager implements IService {
  Future<double> getMemoryUsage();
  Future<void> optimizeCriticalMemory();
  Future<void> freeUnusedMemory();
  Future<void> allocateEmergencyMemory();
  Future<Map<String, double>> getMemoryBreakdown();
  Stream<double> monitorMemoryUsage();
}
