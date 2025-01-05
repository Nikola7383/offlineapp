import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';
import 'package:secure_event_app/core/mesh/mesh_network.dart';
import 'package:secure_event_app/core/storage/database_service.dart';
import 'test_helper.dart';
import 'test_config.dart';

Future<void> bootstrapTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Reset GetIt pre svakog testa
  final getIt = GetIt.instance;
  await getIt.reset();

  // Postavi test environment
  await configureTestEnvironment();

  // Kreiraj i registruj mock servise koristeći helper funkcije
  final mockLogger = getMockLogger();
  final mockMesh = getMockMeshNetwork();
  final mockStorage = getMockDatabaseService();

  getIt.registerSingleton<LoggerService>(mockLogger);
  getIt.registerSingleton<MeshNetwork>(mockMesh);
  getIt.registerSingleton<DatabaseService>(mockStorage);
}

Future<void> tearDownTests() async {
  await GetIt.instance.reset();
}
