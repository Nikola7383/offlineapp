import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/mesh/mesh_network.dart';

void main() {
  late MeshNetwork mesh;

  setUp(() {
    mesh = MeshNetwork(logger: LoggerService());
  });

  group('Mesh Network Performance Tests', () {
    test('Should handle multiple peer connections efficiently', () async {
      final stopwatch = Stopwatch()..start();

      // Simulira 50 peer konekcija
      for (var i = 0; i < 50; i++) {
        await mesh.handleNewPeer('peer_$i');
      }

      stopwatch.stop();

      // Ne bi trebalo da traje duže od 1 sekunde
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('Should broadcast messages quickly to all peers', () async {
      // Priprema test peer-ova
      await _preparePeers(mesh);

      final stopwatch = Stopwatch()..start();

      // Broadcast test poruke
      await mesh.broadcast(Message(
        id: 'broadcast_test',
        content: 'Performance test message',
        senderId: 'sender1',
        timestamp: DateTime.now(),
      ));

      stopwatch.stop();

      // Broadcast bi trebao biti ispod 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('Should handle message relay chain efficiently', () async {
      final stopwatch = Stopwatch()..start();

      // Simulira relay kroz 10 peer-ova
      await _simulateRelayChain(mesh, 10);

      stopwatch.stop();

      // Relay chain ne bi trebao trajati duže od 2 sekunde
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
  });
}
