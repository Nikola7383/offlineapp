import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/services/service_registry.dart';
import 'package:secure_event_app/core/interfaces/logger.dart';
import 'package:secure_event_app/core/interfaces/message_handler.dart';
import '../test_setup.dart';

void main() {
  late ServiceRegistry registry;

  setUp(() {
    registry = ServiceRegistry.instance;
  });

  tearDown(() async {
    await registry.dispose();
  });

  group('ServiceRegistry Tests', () {
    test('should initialize services correctly', () async {
      // Act
      await registry.initialize();

      // Assert
      expect(registry.get<Logger>(), isNotNull);
      expect(registry.get<MessageHandler>(), isNotNull);
    });

    test('should not initialize services twice', () async {
      // Arrange
      await registry.initialize();

      // Act & Assert
      expect(
        () => registry.initialize(),
        returnsNormally,
      );
    });

    test('should dispose services correctly', () async {
      // Arrange
      await registry.initialize();

      // Act
      await registry.dispose();

      // Assert
      expect(
        () => registry.get<Logger>(),
        throwsStateError,
      );
    });

    test('should get service instances', () async {
      // Arrange
      await registry.initialize();

      // Act & Assert
      expect(registry.get<Logger>(), isA<Logger>());
      expect(registry.get<MessageHandler>(), isA<MessageHandler>());
    });

    test('should throw when getting unregistered service', () async {
      // Arrange
      await registry.initialize();

      // Act & Assert
      expect(
        () => registry.get<UnregisteredService>(),
        throwsStateError,
      );
    });
  });
}

// Helper class for testing unregistered service
abstract class UnregisteredService {}
