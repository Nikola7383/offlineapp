import '../../core/interfaces/base_service.dart';
import '../models/diagnosis.dart';

abstract class ICriticalSecurityManager implements IService {
  Future<SecurityStatus> checkStatus();
  Future<void> lockdownSystem();
  Future<void> unlockSystem(String authToken);
  Future<List<String>> getSecurityThreats();
  Future<void> mitigateThreat(String threatId);
  Stream<SecurityStatus> monitorSecurity();
}
