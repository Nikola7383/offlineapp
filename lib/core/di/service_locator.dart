import 'package:get_it/get_it.dart';
import 'package:secure_event_app/core/core.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core services
  getIt.registerSingleton<LoggerService>(LoggerService());
  getIt.registerSingleton<SecureStorage>(SecureStorage());

  // Security services
  getIt.registerSingleton<EncryptionService>(
    EncryptionService(
      storage: getIt(),
      logger: getIt(),
    ),
  );

  // Network services
  getIt.registerSingleton<MeshNetwork>(
    MeshNetwork(
      storage: getIt(),
      logger: getIt(),
    ),
  );

  // Emergency services
  getIt.registerSingleton<EmergencyService>(
    EmergencyService(
      storage: getIt(),
      mesh: getIt(),
      sound: getIt(),
      logger: getIt(),
      security: getIt(),
    ),
  );
}
