import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/services/sync_service.dart';
import 'package:secure_event_app/core/services/storage_service.dart';
import '../test_infrastructure.dart';

void main() {
  late TestInfrastructure infra;
  late SyncService syncService;
  late StorageService storageService;

  setUp(() async {
    infra = TestInfrastructure();
    await infra.setUp();
    storageService = StorageService(infra.database);
    syncService = SyncService(infra.mesh, storageService);
    await storageService.initialize();
    await syncService.initialize();
  });

  tearDown(() async {
    await syncService.dispose();
    await storageService.dispose();
    await infra.tearDown();
  });

  group('Offline Sync Integration', () {
    test('should handle complete offline to online flow', () async {
      // 1. Setup offline state
      when(infra.mesh.sendMessage(any))
          .thenAnswer((_) async => Result.failure('Network error'))
          .thenAnswer((_) async => Result.success());

      // 2. Create and queue message while offline
      final message = infra.createTestMessage();
      await syncService.queueMessage(message);

      // 3. Verify message is stored
      var stored = await storageService.getMessages();
      expect(stored.isSuccess, true);
      expect(stored.data!.length, 1);

      // 4. Try sync while offline
      var syncResult = await syncService.sync();
      expect(syncResult.isSuccess, false);

      // 5. Verify message is still queued
      var pending = await syncService.getPendingMessages();
      expect(pending.data!.length, 1);

      // 6. Try sync when online
      syncResult = await syncService.sync();
      expect(syncResult.isSuccess, true);

      // 7. Verify queue is empty
      pending = await syncService.getPendingMessages();
      expect(pending.data!.isEmpty, true);

      // 8. Verify message status is updated
      stored = await storageService.getMessages();
      expect(stored.data!.first.status, MessageStatus.sent);
    });

    test('should handle multiple messages in queue', () async {
      // 1. Queue multiple messages
      final messages = List.generate(3, (_) => infra.createTestMessage());
      for (final msg in messages) {
        await syncService.queueMessage(msg);
      }

      // 2. Verify all are queued
      var pending = await syncService.getPendingMessages();
      expect(pending.data!.length, 3);

      // 3. Sync all
      final syncResult = await syncService.sync();
      expect(syncResult.isSuccess, true);

      // 4. Verify queue is empty
      pending = await syncService.getPendingMessages();
      expect(pending.data!.isEmpty, true);
    });
  });
}
