import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/security/encryption_service.dart';
import 'package:your_app/core/mesh/mesh_network.dart';

void main() {
  late EncryptionService encryption;
  late MeshNetwork mesh;

  setUp(() {
    encryption = EncryptionService(logger: LoggerService());
    mesh = MeshNetwork(logger: LoggerService());
  });

  group('Security Attack Simulations', () {
    test('Should resist replay attacks', () async {
      // Snimanje legitimne poruke
      final original = await encryption.encrypt(Message(
        id: 'original',
        content: 'Test message',
        timestamp: DateTime.now(),
      ));

      // Pokušaj ponovnog slanja iste poruke
      final replayAttempt = await mesh.handleIncomingMessage(original);
      expect(replayAttempt.accepted, isFalse);
    });

    test('Should detect message tampering', () async {
      final message = await encryption.encrypt(Message(
        id: 'tamper_test',
        content: 'Original content',
        timestamp: DateTime.now(),
      ));

      // Pokušaj izmene enkriptovane poruke
      final tampered = message.copyWith(
        content: base64Encode(
          base64Decode(message.content)...[10] ^= 0xFF
        )
      );

      expect(
        () => encryption.decrypt(tampered),
        throwsA(isA<SecurityException>()),
      );
    });

    test('Should prevent man-in-the-middle attacks', () async {
      // Simulacija MITM napada
      await _simulateMITMAttack(mesh, encryption);
      
      // Provera da li su sve poruke legitimne
      final messages = await mesh.getRecentMessages();
      for (final msg in messages) {
        expect(await encryption.verifyMessage(msg), isTrue);
      }
    });
  });
} 