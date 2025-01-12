import '../interfaces/logger_service.dart';
import '../interfaces/mesh_service.dart';
import '../interfaces/storage_service.dart';
import 'service_locator.dart';

enum SyncStatus {
  idle,
  syncing,
  error,
}

class SyncService {
  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;

  Future<void> sync() async {
    _status = SyncStatus.syncing;
    await Future.delayed(const Duration(seconds: 2));
    _status = SyncStatus.idle;
  }
}

/// Helper za lakši pristup servisima
class Services {
  static ILoggerService get logger =>
      ServiceLocator.instance.get<ILoggerService>();
  static IMeshService get mesh => ServiceLocator.instance.get<IMeshService>();
  static IStorageService get storage =>
      ServiceLocator.instance.get<IStorageService>();
  static final SyncService sync = SyncService();

  /// Inicijalizuje sve servise
  static Future<void> initialize() => ServiceLocator.instance.initialize();

  /// Dispose svih servisa
  static Future<void> dispose() => ServiceLocator.instance.dispose();
}
