import '../../core/interfaces/base_service.dart';

abstract class IPowerManager implements IService {
  Future<double> getPowerUsage();
  Future<void> optimizePowerUsage();
  Future<void> enterLowPowerMode();
  Future<void> exitLowPowerMode();
  Future<bool> isLowPowerMode();
  Stream<double> monitorPowerUsage();
}
