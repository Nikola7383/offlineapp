import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/di/dependency_injection.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';
import 'package:secure_event_app/core/security/encryption_service.dart';
import 'package:secure_event_app/core/mesh/mesh_network.dart';

void main() {
  group('DependencyInjection Tests', () {
    setUp(() async {
      await setupDependencies();
    });

    test('core services are registered', () {
      expect(getIt<LoggerService>(), isNotNull);
      expect(getIt<PerformanceMonitor>(), isNotNull);
    });

    test('async services are initialized correctly', () async {
      final encryptionService = await getIt.getAsync<EncryptionService>();
      expect(encryptionService, isNotNull);

      final meshNetwork = await getIt.getAsync<MeshNetwork>();
      expect(meshNetwork, isNotNull);
    });

    test('blocs are created as new instances', () {
      final firstBloc = getIt<AppBloc>();
      final secondBloc = getIt<AppBloc>();
      expect(identical(firstBloc, secondBloc), isFalse);
    });
  });
}
