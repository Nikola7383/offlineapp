import 'base_service.dart';

abstract class IKeyRotationManager implements ISecureService {
  Future<void> rotateKeys();
  Future<void> scheduleRotation(Duration interval);
  Future<void> cancelScheduledRotation();
  Future<DateTime?> getNextRotationTime();
  Future<bool> isRotationDue();
}
