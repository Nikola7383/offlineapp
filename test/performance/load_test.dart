import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/communication/message_service.dart';
import 'package:your_app/core/mesh/mesh_network.dart';

void main() {
  group('Load Tests', () {
    test('Should handle high message volume', () async {
      final messageService = MessageService();
      final stopwatch = Stopwatch()..start();

      // Simulira 10,000 poruka u kratkom periodu
      final futures = List.generate(
          10000,
          (i) => messageService.sendMessage(
                'Load test message $i',
                'sender1',
              ));

      await Future.wait(futures);
      stopwatch.stop();

      // Ne bi trebalo da padne i trebalo bi da završi u razumnom vremenu
      expect(stopwatch.elapsedMilliseconds, lessThan(30000)); // 30 sekundi
    });

    test('Should handle multiple peer connections under load', () async {
      final mesh = MeshNetwork();
      final connections = <Future>[];

      // Simulira 100 simultanih peer konekcija
      for (var i = 0; i < 100; i++) {
        connections.add(mesh.handleNewPeer('peer_$i'));
      }

      // Ne bi trebalo da padne
      await expectLater(Future.wait(connections), completes);
    });
  });
}
