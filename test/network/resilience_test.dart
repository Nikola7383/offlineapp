import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/mesh/mesh_network.dart';
import 'package:your_app/core/communication/message_service.dart';

void main() {
  late MeshNetwork mesh;
  late MessageService messageService;

  setUp(() {
    mesh = MeshNetwork(logger: LoggerService());
    messageService = MessageService(logger: LoggerService());
  });

  group('Network Resilience Tests', () {
    test('Should maintain connectivity during peer churn', () async {
      // Simulira konstantno povezivanje/odpajanje peer-ova
      final stability = await _testNetworkStability(
        duration: const Duration(minutes: 5),
        churnRate: 0.5, // 50% peer-ova se menja
      );

      expect(stability.messageDeliveryRate, greaterThan(0.95));
      expect(stability.networkPartitions, equals(0));
    });

    test('Should handle network congestion', () async {
      // Simulira zagušenje mreže
      await _simulateNetworkCongestion(
        messageRate: 100, // 100 poruka u sekundi
        duration: const Duration(minutes: 1),
      );

      final stats = await mesh.getNetworkStats();
      expect(stats.droppedMessages, equals(0));
      expect(stats.averageLatency, lessThan(const Duration(seconds: 1)));
    });

    test('Should recover from total network failure', () async {
      // Simulira potpuni pad mreže
      await _simulateNetworkFailure();

      // Čeka oporavak
      final recovery = await mesh.waitForRecovery(
        timeout: const Duration(minutes: 1),
      );

      expect(recovery.fullyRecovered, isTrue);
      expect(recovery.dataSynchronized, isTrue);
    });
  });
}
