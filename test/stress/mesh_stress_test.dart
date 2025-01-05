import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/mesh/mesh_network.dart';

void main() {
  late MeshNetwork mesh;

  setUp(() {
    mesh = MeshNetwork(logger: LoggerService());
  });

  group('Mesh Network Stress Tests', () {
    test('Should handle rapid peer connections/disconnections', () async {
      for (var i = 0; i < 100; i++) {
        // Brzo povezivanje i prekidanje veze
        await mesh.handleNewPeer('stress_peer_$i');
        await mesh.handlePeerDisconnection('stress_peer_$i');
      }

      expect(mesh.connectedPeers.length, equals(0));
      expect(mesh.isStable(), isTrue);
    });

    test('Should handle message flood', () async {
      // Povezivanje sa 10 peer-ova
      for (var i = 0; i < 10; i++) {
        await mesh.handleNewPeer('flood_peer_$i');
      }

      // Slanje 1000 poruka istovremeno
      final futures = List.generate(
          1000,
          (i) => mesh.broadcast(Message(
                id: 'flood_$i',
                content: 'Stress test message $i',
                timestamp: DateTime.now(),
              )));

      await expectLater(Future.wait(futures), completes);
      expect(mesh.messageQueue.length, equals(0));
    });

    test('Should recover from network partition', () async {
      // Simulira podelu mreže
      await _simulateNetworkPartition(mesh);

      // Provera da li se mreža oporavila
      expect(mesh.isFullyConnected(), isTrue);
      expect(mesh.messageConsistency(), isTrue);
    });
  });
}
