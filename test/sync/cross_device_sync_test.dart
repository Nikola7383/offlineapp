import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/mesh/mesh_network.dart';
import 'package:your_app/core/sync/sync_service.dart';

void main() {
  late MeshNetwork meshA;
  late MeshNetwork meshB;
  late SyncService syncService;

  setUp(() {
    meshA = MeshNetwork(deviceId: 'device_A', logger: LoggerService());
    meshB = MeshNetwork(deviceId: 'device_B', logger: LoggerService());
    syncService = SyncService(logger: LoggerService());
  });

  group('Cross-Device Sync Tests', () {
    test('Should sync messages between devices', () async {
      // Kreira poruke na uređaju A
      final messagesA = await _createTestMessages('device_A', 100);
      await meshA.broadcastMessages(messagesA);

      // Sinhronizuje sa uređajem B
      await syncService.syncDevices(meshA, meshB);

      // Verifikuje da su poruke stigle na uređaj B
      final messagesB = await meshB.getAllMessages();
      expect(messagesB.length, equals(messagesA.length));
      expect(
        messagesB.map((m) => m.id).toSet(),
        equals(messagesA.map((m) => m.id).toSet()),
      );
    });

    test('Should handle conflict resolution', () async {
      // Kreira konfliktne poruke na oba uređaja
      final messageA = await _createConflictingMessage('device_A');
      final messageB = await _createConflictingMessage('device_B');

      // Sinhronizuje i proverava rezoluciju
      final resolution =
          await syncService.resolveConflicts([messageA, messageB]);

      expect(resolution.resolved, isTrue);
      expect(resolution.winner, isNotNull);
      expect(resolution.loser, isNotNull);
    });

    test('Should maintain message order', () async {
      // Kreira sekvencijalne poruke
      final sequence = await _createSequentialMessages(50);

      // Sinhronizuje preko više uređaja
      final syncResult = await syncService.syncSequence(sequence);

      expect(syncResult.orderMaintained, isTrue);
      expect(syncResult.causalityViolations, equals(0));
    });
  });
}
