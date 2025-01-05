import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/security/encryption_service.dart';

void main() {
  late EncryptionService encryption;

  setUp(() {
    encryption = EncryptionService(logger: LoggerService());
  });

  group('Encryption Stress Tests', () {
    test('Should handle concurrent encryption requests', () async {
      final messages = List.generate(
          100,
          (i) => Message(
                id: 'concurrent_$i',
                content: 'Large content ' * 1000, // 12KB poruka
                timestamp: DateTime.now(),
              ));

      final futures = messages.map((m) => encryption.encrypt(m));
      final encrypted = await Future.wait(futures);

      for (var e in encrypted) {
        expect(e.encryptedKey, isNotNull);
        expect(e.signature, isNotNull);
      }
    });

    test('Should maintain key security under load', () async {
      final originalMessage = 'Sensitive data';
      var lastEncrypted = '';

      // Pokušaj pronalaženja obrazaca u enkripciji
      for (var i = 0; i < 1000; i++) {
        final message = Message(
          id: 'security_$i',
          content: originalMessage,
          timestamp: DateTime.now(),
        );

        final encrypted = await encryption.encrypt(message);
        expect(encrypted.content, isNot(equals(lastEncrypted)));
        lastEncrypted = encrypted.content;
      }
    });
  });
}
