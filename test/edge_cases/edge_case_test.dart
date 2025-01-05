import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/mesh/mesh_network.dart';
import 'package:your_app/core/database/database_service.dart';

void main() {
  late MeshNetwork mesh;
  late DatabaseService db;

  setUp(() {
    mesh = MeshNetwork(logger: LoggerService());
    db = DatabaseService(logger: LoggerService());
  });

  group('Edge Case Tests', () {
    test('Should handle extremely large messages', () async {
      // Kreira poruku od 10MB
      final largeMessage = await _createLargeMessage(10 * 1024 * 1024);

      // Pokušava procesiranje
      final result = await mesh.processMessage(largeMessage);

      expect(result.handled, isTrue);
      expect(result.fragmented, isTrue);
      expect(result.allPartsDelivered, isTrue);
    });

    test('Should handle rapid connection changes', () async {
      // Simulira brze promene konekcija
      final connections = List.generate(
          1000,
          (i) => mesh.handleConnectionChange(
                connected: i % 2 == 0,
                peerId: 'peer_$i',
              ));

      await Future.wait(connections);

      expect(mesh.isStable(), isTrue);
      expect(mesh.hasLostMessages(), isFalse);
    });

    test('Should handle database edge cases', () async {
      // Testira ekstremne slučajeve
      await _testDatabaseEdgeCases(db);

      final integrity = await db.checkIntegrity();
      expect(integrity.isValid, isTrue);
      expect(integrity.hasInconsistencies, isFalse);
    });
  });
}
