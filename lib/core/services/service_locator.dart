import 'package:get_it/get_it.dart';

import '../interfaces/logger_service.dart';
import '../interfaces/mesh_service.dart';
import '../interfaces/storage_service.dart';
import 'logger_service.dart';
import 'mesh_service.dart';
import 'storage_service.dart';
import '../interfaces/database_service.dart';
import '../models/database_models.dart';
import '../interfaces/connection_service.dart';
import '../models/connection_models.dart';
import '../interfaces/sync_service.dart';
import '../models/sync_models.dart';

/// Singleton za dependency injection
class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._();
  final GetIt _getIt = GetIt.instance;
  bool _isInitialized = false;

  ServiceLocator._();

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Register services
    _getIt.registerSingleton<ILoggerService>(LoggerService());
    _getIt.registerSingleton<IDatabaseService>(
      DatabaseService(get<ILoggerService>()),
    );
    _getIt.registerSingleton<IMeshService>(
      MeshService(get<ILoggerService>()),
    );
    _getIt.registerSingleton<IStorageService>(
      StorageService(get<IDatabaseService>()),
    );
    _getIt.registerSingleton<ISyncService>(
      SyncService(get<IMeshService>(), get<IStorageService>()),
    );

    // Initialize all services
    await get<IDatabaseService>().initialize();
    await get<IMeshService>().initialize();
    
    _isInitialized = true;
  }

  T get<T extends Object>() {
    if (!_isInitialized) {
      throw StateError('ServiceLocator not initialized');
    }
    return _getIt<T>();
  }

  Future<void> dispose() async {
    if (!_isInitialized) return;

    await get<ISyncService>().dispose();
    await get<IStorageService>().dispose();
    await get<IDatabaseService>().dispose();
    await get<IMeshService>().dispose();
    
    _getIt.reset();
    _isInitialized = false;
  }
}

    try {
      // Registrujemo Logger prvi jer ga ostali servisi koriste
      _getIt.registerSingleton<ILoggerService>(
        LoggerService(prefix: 'SecureEventApp'),
      );

      // Inicijalizujemo logger
      await _getIt<ILoggerService>().initialize();

      // Registrujemo ostale servise
      _getIt.registerSingleton<IMeshService>(
        MeshService(_getIt<ILoggerService>()),
      );

      _getIt.registerSingleton<IStorageService>(
        StorageService(_getIt<ILoggerService>()),
      );

      _getIt.registerSingleton<IDatabaseService>(
        DatabaseService(
          _getIt<ILoggerService>(),
          const DatabaseConfig(
            name: 'secure_event_app',
            path: 'db',
            encryptionEnabled: true,
            encryptionKey: String.fromEnvironment('DB_KEY'),
          ),
        ),
      );

      _getIt.registerSingleton<IConnectionService>(
        ConnectionService(
          _getIt<ILoggerService>(),
          const ConnectionConfig(),
        ),
      );

      _getIt.registerSingleton<ISyncService>(
        SyncService(
          _getIt<ILoggerService>(),
          _getIt<IMeshService>(),
          _getIt<IStorageService>(),
          _getIt<IConnectionService>(),
          const SyncConfig(),
        ),
      );

      // Inicijalizujemo ostale servise
      await Future.wait([
        _getIt<IMeshService>().initialize(),
        _getIt<IStorageService>().initialize(),
        _getIt<IDatabaseService>().initialize(),
        _getIt<IConnectionService>().initialize(),
        _getIt<ISyncService>().initialize(),
      ]);

      _isInitialized = true;

      await _getIt<ILoggerService>()
          .info('ServiceLocator initialized successfully');
    } catch (e, stackTrace) {
      await _getIt<ILoggerService>().error(
        'Failed to initialize ServiceLocator',
        e,
        stackTrace,
      );
      await dispose();
      rethrow;
    }
  }

  /// Cleanup svih servisa
  Future<void> dispose() async {
    if (!_isInitialized) {
      return;
    }

    try {
      // Dispose servisa obrnutim redosledom
      await Future.wait([
        _getIt<IStorageService>().dispose(),
        _getIt<IMeshService>().dispose(),
        _getIt<IDatabaseService>().dispose(),
        _getIt<IConnectionService>().dispose(),
        _getIt<ISyncService>().dispose(),
      ]);

      // Logger poslednji dispose
      await _getIt<ILoggerService>().dispose();

      await _getIt.reset();
      _isInitialized = false;
    } catch (e) {
      print('Error during ServiceLocator dispose: $e');
      rethrow;
    }
  }

  /// Vraća instancu servisa
  T get<T extends Object>() => _getIt<T>();

  /// Proverava da li je servis registrovan
  bool isRegistered<T extends Object>() => _getIt.isRegistered<T>();
}
