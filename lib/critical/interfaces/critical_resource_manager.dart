import '../../core/interfaces/base_service.dart';
import '../models/diagnosis.dart';

abstract class ICriticalResourceManager implements IService {
  Future<ResourceStatus> checkStatus();
  Future<void> optimizeResources();
  Future<void> allocateEmergencyResources();
  Future<void> releaseResources();
  Future<Map<String, double>> getResourceUsage();
  Stream<ResourceStatus> monitorResources();
}
