import '../../core/interfaces/base_service.dart';

abstract class ICriticalBackup implements IService {
  Future<void> createSecureBackup(Map<String, dynamic> data);
  Future<Map<String, dynamic>> restoreFromBackup();
  Future<bool> verifyBackup();
  Future<void> cleanupOldBackups();
  Future<List<String>> listBackups();
  Future<DateTime?> getLastBackupTime();
}
