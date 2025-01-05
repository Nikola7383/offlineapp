import 'package:get_it/get_it.dart';
import '../services/logger_service.dart';
import '../database/database_service.dart';
import '../mesh/mesh_network.dart';
import '../security/encryption_service.dart';

class ServiceLocator {
  static final GetIt _i = GetIt.instance;

  static Future<void> initialize() async {
    // Core services
    _i.registerSingleton<LoggerService>(LoggerService());
    await _i.get<LoggerService>().initialize();

    // Database
    _i.registerSingletonAsync<DatabaseService>(() async {
      final db = DatabaseService(logger: _i.get<LoggerService>());
      await db.initialize();
      return db;
    });

    // Mesh Network
    _i.registerSingletonAsync<MeshNetwork>(() async {
      final mesh = MeshNetwork(logger: _i.get<LoggerService>());
      await mesh.initialize();
      return mesh;
    });

    // Encryption
    _i.registerSingletonAsync<EncryptionService>(() async {
      final encryption = EncryptionService(logger: _i.get<LoggerService>());
      await encryption.initialize();
      return encryption;
    });

    // Čekamo da se svi async servisi inicijalizuju
    await _i.allReady();
  }

  static T get<T extends Object>() => _i.get<T>();
}
