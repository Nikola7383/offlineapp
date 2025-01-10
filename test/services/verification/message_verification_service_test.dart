import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockSecurityService extends Mock implements SecurityService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late MessageVerificationService verificationService;
  late MockSecurityService mockSecurity;
  late MockDatabaseService mockDb;
  late MockLoggerService mockLogger;

  setUp(() {
    mockSecurity = MockSecurityService();
    mockDb = MockDatabaseService();
    mockLogger = MockLoggerService();

    verificationService = MessageVerificationService(
      security: mockSecurity,
      db: mockDb,
      logger: mockLogger,
    );
  });

  group('Message Verification Tests', () {
    test('should verify valid message successfully', () async {
      // Arrange
      final message = _createValidSecureMessage();
      when(mockSecurity.calculateHash(any))
          .thenAnswer((_) async => 'validHash');
      when(mockSecurity.verifySignature(any, any, any))
          .thenAnswer((_) async => true);
      when(mockDb.getUser(any))
          .thenAnswer((_) async => User(id: '1', isActive: true));

      // Act
      final result = await verificationService.verifyMessage(message);

      // Assert
      expect(result.isValid, true);
      expect(result.failureReason, null);
      verify(mockSecurity.calculateHash(any)).called(1);
      verify(mockSecurity.verifySignature(any, any, any)).called(1);
    });

    test('should fail verification for invalid signature', () async {
      // Arrange
      final message = _createValidSecureMessage();
      when(mockSecurity.verifySignature(any, any, any))
          .thenAnswer((_) async => false);

      // Act
      final result = await verificationService.verifyMessage(message);

      // Assert
      expect(result.isValid, false);
      expect(result.failureReason, contains('Signature verification failed'));
    });

    test('should fail verification for expired timestamp', () async {
      // Arrange
      final message = _createExpiredSecureMessage();

      // Act
      final result = await verificationService.verifyMessage(message);

      // Assert
      expect(result.isValid, false);
      expect(result.failureReason, contains('Timestamp validation failed'));
    });

    test('should use cache for previously verified messages', () async {
      // Arrange
      final message = _createValidSecureMessage();
      when(mockSecurity.calculateHash(any))
          .thenAnswer((_) async => 'validHash');
      when(mockSecurity.verifySignature(any, any, any))
          .thenAnswer((_) async => true);
      when(mockDb.getUser(any))
          .thenAnswer((_) async => User(id: '1', isActive: true));

      // Act
      await verificationService.verifyMessage(message); // First call
      await verificationService.verifyMessage(message); // Second call

      // Assert
      verify(mockSecurity.calculateHash(any)).called(1); // Should use cache
    });

    test('should handle security service errors gracefully', () async {
      // Arrange
      final message = _createValidSecureMessage();
      when(mockSecurity.calculateHash(any))
          .thenThrow(Exception('Security error'));

      // Act
      final result = await verificationService.verifyMessage(message);

      // Assert
      expect(result.isValid, false);
      expect(result.failureReason, contains('Verification error'));
      verify(mockLogger.error(any)).called(1);
    });
  });
}

SecureMessage _createValidSecureMessage() {
  return SecureMessage(
    originalMessage: Message(
        id: '1',
        content: 'Test content',
        senderId: '1',
        timestamp: DateTime.now(),
        signature: 'validHash'),
    encryptedContent: 'encrypted',
    encryptedKey: 'key',
    signature: 'validSignature',
    timestamp: DateTime.now(),
  );
}

SecureMessage _createExpiredSecureMessage() {
  return SecureMessage(
    originalMessage: Message(
        id: '2',
        content: 'Expired content',
        senderId: '1',
        timestamp: DateTime.now().subtract(Duration(minutes: 10)),
        signature: 'validHash'),
    encryptedContent: 'encrypted',
    encryptedKey: 'key',
    signature: 'validSignature',
    timestamp: DateTime.now().subtract(Duration(minutes: 10)),
  );
}
