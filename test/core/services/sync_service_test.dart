import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/models/message.dart';
import 'package:secure_event_app/core/services/sync_service.dart';
import '../../test_infrastructure.dart';

void main() {
  late TestInfrastructure infra;
  late SyncService syncService;

  setUp(() async {
    infra = TestInfrastructure();
    await infra.setUp();
    syncService = SyncService(infra.mesh, infra.storage);
    await syncService.initialize();
  });

  tearDown(() async {
    await syncService.dispose();
    await infra.tearDown();
  });

  group('SyncService', () {
    test('should queue message when offline', () async {
      // Arrange
      final message = infra.createTestMessage();

      // Act
      final result = await syncService.queueMessage(message);

      // Assert
      expect(result.isSuccess, true);
      verify(infra.storage.saveMessage(any)).called(1);
      verifyNever(infra.mesh.sendMessage(any));
    });

    test('should sync queued messages when online', () async {
      // Arrange
      final message = infra.createTestMessage();
      await syncService.queueMessage(message);

      // Act
      final result = await syncService.sync();

      // Assert
      expect(result.isSuccess, true);
      verify(infra.mesh.sendMessage(any)).called(1);
    });

    test('should handle offline to online transition', () async {
      // Arrange
      final message = infra.createTestMessage();
      when(infra.mesh.sendMessage(any))
          .thenAnswer((_) async => Result.failure('Network error'))
          .thenAnswer((_) async => Result.success());

      // Act - First try (offline)
      await syncService.queueMessage(message);
      var result = await syncService.sync();
      expect(result.isSuccess, false);

      // Act - Second try (online)
      result = await syncService.sync();
      expect(result.isSuccess, true);
    });
  });
}
