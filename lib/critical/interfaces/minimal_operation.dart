import '../../core/interfaces/base_service.dart';

abstract class IMinimalOperation implements IService {
  Future<void> activate();
  Future<void> deactivate();
  Future<bool> isActive();
  Future<void> setMinimalServices(List<String> serviceIds);
  Future<List<String>> getActiveServices();
  Stream<bool> monitorMinimalMode();
}
