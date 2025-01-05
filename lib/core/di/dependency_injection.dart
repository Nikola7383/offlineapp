import 'package:get_it/get_it.dart';
import '../auth/guest_auth_service.dart';
import '../mesh/mesh_network.dart';
import '../security/encryption_service.dart';
import '../storage/database_service.dart';
import '../logging/logger_service.dart';
import '../performance/performance_monitor.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core Services
  getIt.registerSingleton<LoggerService>(
    LoggerService(),
  );

  getIt.registerSingleton<PerformanceMonitor>(
    PerformanceMonitor(
      logger: getIt<LoggerService>(),
    ),
  );

  getIt.registerSingletonAsync<EncryptionService>(() async {
    final service = EncryptionService(
      logger: getIt<LoggerService>(),
    );
    await service.initialize();
    return service;
  });

  getIt.registerSingletonAsync<DatabaseService>(() async {
    final service = DatabaseService(
      logger: getIt<LoggerService>(),
    );
    await service.initialize();
    return service;
  });

  // Feature Services
  getIt.registerSingletonAsync<GuestAuthService>(() async {
    final prefs = await SharedPreferences.getInstance();
    return GuestAuthService(
      logger: getIt<LoggerService>(),
      prefs: prefs,
    );
  });

  getIt.registerSingletonAsync<MeshNetwork>(() async {
    final service = MeshNetwork(
      logger: getIt<LoggerService>(),
      encryption: await getIt.getAsync<EncryptionService>(),
    );
    await service.initialize();
    return service;
  });

  // Blocs
  getIt.registerFactory(() => AppBloc(
        appService: getIt(),
        logger: getIt(),
      ));

  getIt.registerFactory(() => AuthBloc(
        authService: getIt(),
        appService: getIt(),
        logger: getIt(),
      ));
}
