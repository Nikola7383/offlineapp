import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:secure_event_app/core/services/service_locator.dart';
import 'test_helper.dart';

Future<void> testSetup() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Reset GetIt pre svakog testa
  final getIt = GetIt.instance;
  if (getIt.isRegistered<LoggerService>()) {
    await getIt.reset();
  }

  // Registruj mock servise
  final mockLogger = MockLoggerService();
  final mockMesh = MockMeshNetwork();
  final mockStorage = MockDatabaseService();

  getIt.registerSingleton<LoggerService>(mockLogger);
  getIt.registerSingleton<MeshNetwork>(mockMesh);
  getIt.registerSingleton<DatabaseService>(mockStorage);
}

Future<void> testTearDown() async {
  await GetIt.instance.reset();
}
