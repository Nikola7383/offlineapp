import 'package:test/test.dart';
import '../../../lib/mesh/secure_mesh_network.dart';
import '../../../lib/mesh/mesh_network.dart';
import '../../../lib/mesh/security/security_manager.dart';
import '../../../lib/mesh/security/anti_tampering.dart';
import '../../../lib/mesh/models/node.dart';

class MockMeshNetwork extends MeshNetwork {
  final List<List<int>> sentMessages = [];
  final List<String> targetNodes = [];

  @override
  Future<bool> sendTo(String nodeId, List<int> data) async {
    targetNodes.add(nodeId);
    sentMessages.add(data);
    return true;
  }

  @override
  Future<void> broadcast(List<int> data) async {
    sentMessages.add(data);
  }
}

void main() {
  late SecureMeshNetwork secureMesh;
  late MockMeshNetwork mockNetwork;
  late SecurityManager security;
  late AntiTampering antiTampering;

  setUp(() {
    mockNetwork = MockMeshNetwork();
    security = SecurityManager();
    antiTampering = AntiTampering();

    secureMesh = SecureMeshNetwork(
      network: mockNetwork,
      security: security,
      antiTampering: antiTampering,
    );
  });

  tearDown(() async {
    await secureMesh.dispose();
  });

  group('Network Operations', () {
    test('Should start network securely', () async {
      await secureMesh.start();
      expect(secureMesh.isCompromised, isFalse);
    });

    test('Should encrypt broadcast messages', () async {
      await secureMesh.start();

      final message = [1, 2, 3, 4, 5];
      await secureMesh.broadcast(message);

      expect(mockNetwork.sentMessages, hasLength(1));
      expect(mockNetwork.sentMessages.first, isNot(equals(message)));
    });

    test('Should encrypt direct messages', () async {
      await secureMesh.start();

      final message = [1, 2, 3, 4, 5];
      await secureMesh.sendTo('testNode', message);

      expect(mockNetwork.targetNodes, contains('testNode'));
      expect(mockNetwork.sentMessages.first, isNot(equals(message)));
    });
  });

  group('Security Features', () {
    test('Should enforce rate limiting', () async {
      await secureMesh.start();

      await secureMesh.sendTo('node1', [1, 2, 3]);

      expect(
        () => secureMesh.sendTo('node1', [1, 2, 3]),
        throwsA(isA<SecurityException>()),
      );
    });

    test('Should enforce message size limits', () async {
      await secureMesh.start();

      final largeMessage = List<int>.filled(2 * 1024 * 1024, 0); // 2MB

      expect(
        () => secureMesh.broadcast(largeMessage),
        throwsA(isA<SecurityException>()),
      );
    });

    test('Should handle security events', () async {
      await secureMesh.start();

      // Simuliraj bezbednosni događaj
      security._eventController.add(SecurityEvent.attackDetected);

      await Future.delayed(Duration(milliseconds: 100));

      expect(secureMesh.isCompromised, isTrue);

      expect(
        () => secureMesh.broadcast([1, 2, 3]),
        throwsA(isA<SecurityException>()),
      );
    });
  });

  group('Data Processing', () {
    test('Should decrypt incoming messages', () async {
      await secureMesh.start();

      final originalMessage = [1, 2, 3, 4, 5];
      final encrypted = await security.encrypt(originalMessage);

      // Simuliraj primanje poruke
      mockNetwork._dataController.add(encrypted.data.toList());

      expect(
        secureMesh.secureDataStream,
        emits(originalMessage),
      );
    });

    test('Should reject tampered messages', () async {
      await secureMesh.start();

      final originalMessage = [1, 2, 3, 4, 5];
      final encrypted = await security.encrypt(originalMessage);

      // Modifikuj enkriptovane podatke
      encrypted.data[0] = encrypted.data[0] + 1;

      // Simuliraj primanje modifikovane poruke
      mockNetwork._dataController.add(encrypted.data.toList());

      // Ne bi trebalo da primimo dekriptovanu poruku
      expect(
        secureMesh.secureDataStream,
        neverEmits(originalMessage),
      );
    });
  });

  group('Recovery Mechanisms', () {
    test('Should recover after Phoenix regeneration', () async {
      await secureMesh.start();

      // Izazovi kompromitovanje
      security._eventController.add(SecurityEvent.attackDetected);
      await Future.delayed(Duration(milliseconds: 100));
      expect(secureMesh.isCompromised, isTrue);

      // Aktiviraj Phoenix regeneraciju
      security._eventController.add(SecurityEvent.phoenixRegeneration);
      await Future.delayed(Duration(milliseconds: 100));

      expect(secureMesh.isCompromised, isFalse);

      // Trebalo bi da možemo ponovo da šaljemo poruke
      await expectLater(
        secureMesh.broadcast([1, 2, 3]),
        completes,
      );
    });
  });
}
