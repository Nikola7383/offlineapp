import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:your_app/core/security/encryption_service.dart';

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late EncryptionService encryptionService;
  late MockLoggerService mockLogger;

  setUp(() {
    mockLogger = MockLoggerService();
    encryptionService = EncryptionService(logger: mockLogger);
  });

  group('EncryptionService Tests', () {
    test('encrypt should produce different output than input', () async {
      // Arrange
      final message = Message(
        id: '1',
        content: 'Test message',
        senderId: 'sender1',
        timestamp: DateTime.now(),
      );

      // Act
      final encrypted = await encryptionService.encrypt(message);

      // Assert
      expect(encrypted.content, isNot(equals(message.content)));
      expect(encrypted.encryptedKey, isNotNull);
      expect(encrypted.signature, isNotNull);
    });

    test('decrypt should restore original message', () async {
      // Arrange
      final original = Message(
        id: '1',
        content: 'Test message',
        senderId: 'sender1',
        timestamp: DateTime.now(),
      );

      // Act
      final encrypted = await encryptionService.encrypt(original);
      final decrypted = await encryptionService.decrypt(encrypted);

      // Assert
      expect(decrypted.content, equals(original.content));
    });

    test('verifyMessage should validate signature', () async {
      // Arrange
      final message = Message(
        id: '1',
        content: 'Test message',
        senderId: 'sender1',
        timestamp: DateTime.now(),
      );

      // Act
      final encrypted = await encryptionService.encrypt(message);
      final isValid = await encryptionService.verifyMessage(encrypted);

      // Assert
      expect(isValid, true);
    });
  });
}
