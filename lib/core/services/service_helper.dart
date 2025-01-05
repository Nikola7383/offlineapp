import '../interfaces/logger_service.dart';
import '../interfaces/mesh_service.dart';
import '../interfaces/storage_service.dart';
import 'service_locator.dart';

/// Helper za lakši pristup servisima
class Services {
  static ILoggerService get logger =>
      ServiceLocator.instance.get<ILoggerService>();
  static IMeshService get mesh => ServiceLocator.instance.get<IMeshService>();
  static IStorageService get storage =>
      ServiceLocator.instance.get<IStorageService>();

  /// Inicijalizuje sve servise
  static Future<void> initialize() => ServiceLocator.instance.initialize();

  /// Dispose svih servisa
  static Future<void> dispose() => ServiceLocator.instance.dispose();
}
