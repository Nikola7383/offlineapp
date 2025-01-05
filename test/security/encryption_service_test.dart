import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/security/encryption_service.dart';
import 'package:secure_event_app/core/mesh/mesh_network.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';

void main() {
  late EncryptionService encryption;

  setUp(() {
    encryption = EncryptionService(logger: LoggerService());
  });

  group('Encryption Service Tests', () {
    test('Should encrypt and decrypt message successfully', () async {
      // Arrange
      final original = Message(
        id: 'test_msg',
        content: 'Test secret message',
        timestamp: DateTime.now(),
      );

      // Act
      final encrypted = await encryption.encrypt(original);
      final decrypted = await encryption.decrypt(encrypted);

      // Assert
      expect(decrypted.id, equals(original.id));
      expect(decrypted.content, equals(original.content));
      expect(decrypted.timestamp, equals(original.timestamp));
    });

    test('Should detect tampered messages', () async {
      // Arrange
      final original = Message(
        id: 'test_msg',
        content: 'Test secret message',
        timestamp: DateTime.now(),
      );
      final encrypted = await encryption.encrypt(original);

      // Act & Assert
      final tamperedMessage = EncryptedMessage(
        id: encrypted.id,
        content: encrypted.content + 'tampered',
        signature: encrypted.signature,
        timestamp: encrypted.timestamp,
      );

      expect(
        () => encryption.decrypt(tamperedMessage),
        throwsA(isA<SecurityException>()),
      );
    });

    test('Should handle empty messages', () async {
      // Arrange
      final original = Message(
        id: 'empty_msg',
        content: '',
        timestamp: DateTime.now(),
      );

      // Act
      final encrypted = await encryption.encrypt(original);
      final decrypted = await encryption.decrypt(encrypted);

      // Assert
      expect(decrypted.content, isEmpty);
    });
  });
}
