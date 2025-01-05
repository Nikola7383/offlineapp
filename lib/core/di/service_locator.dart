import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../services/logger_service.dart';
import '../database/database_service.dart';
import '../mesh/mesh_network.dart';
import '../security/encryption_service.dart';
import '../optimizations/cache_manager.dart';
import '../optimizations/batch_processor.dart';
import '../mesh/mesh_optimizer.dart';
import '../mesh/load_balancer.dart';
import '../utils/resource_manager.dart';
import '../services/cleanup_service.dart';

@InjectableInit()
class ServiceLocator {
  static final GetIt instance = GetIt.instance;

  @PostConstruct()
  static Future<void> initialize() async {
    // Core Services
    instance.registerSingleton<LoggerService>(LoggerService());

    // Resource Management
    instance.registerSingleton<ResourceManager>(
      ResourceManager(instance.get<LoggerService>()),
    );

    instance.registerSingleton<CleanupService>(
      CleanupService(
        resourceManager: instance.get<ResourceManager>(),
        logger: instance.get<LoggerService>(),
      ),
    );

    // Initialize cleanup service
    instance.get<CleanupService>().initialize();

    // Wait for logger to be ready before initializing other services
    await instance.isReady<LoggerService>();
    final logger = instance.get<LoggerService>();

    // Database
    instance.registerSingletonAsync<DatabaseService>(() async {
      final service = DatabaseService(logger: logger);
      await service.initialize();
      return service;
    });

    // Cache
    instance.registerSingletonAsync<CacheManager>(() async {
      final cache = CacheManager(logger: logger);
      await cache.initialize();
      return cache;
    });

    // Mesh Network Dependencies
    instance.registerSingleton<MeshOptimizer>(MeshOptimizer());

    instance.registerSingletonAsync<MeshNetwork>(() async {
      final mesh = MeshNetwork(
        logger: logger,
        optimizer: instance.get<MeshOptimizer>(),
        cache: await instance.getAsync<CacheManager>(),
      );
      await mesh.initialize();
      return mesh;
    });

    // Batch Processing
    instance.registerSingletonAsync<BatchProcessor>(() async {
      final db = await instance.getAsync<DatabaseService>();
      return BatchProcessor(
        db: db,
        logger: logger,
      );
    });

    // Load Balancer
    instance.registerSingletonAsync<MeshLoadBalancer>(() async {
      return MeshLoadBalancer(
        optimizer: instance.get<MeshOptimizer>(),
        logger: logger,
      );
    });

    // Security
    instance.registerSingletonAsync<EncryptionService>(() async {
      final service = EncryptionService(logger: logger);
      await service.initialize();
      return service;
    });

    // Wait for all async registrations
    await instance.allReady();
  }

  static Future<void> reset() async {
    await instance.reset();
  }

  static Future<void> dispose() async {
    await instance.get<CleanupService>().dispose();
    await instance.reset();
  }
}
