import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/messaging/verification/message_verification_service.dart';
import '../../test_helper.dart';
import '../../test_helper.mocks.dart';

void main() {
  group('MessageVerificationService', () {
    late MessageVerificationService service;
    late MockSecureStorage mockStorage;
    late MockILoggerService mockLogger;

    setUp(() {
      mockStorage = MockSecureStorage();
      mockLogger = MockILoggerService();
      service = MessageVerificationService(mockLogger, mockStorage);
    });

    test('should initialize service', () async {
      // Arrange
      when(mockStorage.read(any)).thenAnswer((_) => Future.value(null));

      // Act
      await service.initialize();

      // Assert
      verify(mockLogger.info(any)).called(1);
      verify(mockStorage.read(any)).called(1);
    });

    test('should verify message integrity with cached hash', () async {
      // Arrange
      const messageId = 'test_message';
      const hash = 'test_hash';
      final cacheData = {
        messageId: {
          'hash': hash,
          'timestamp': DateTime.now().toIso8601String(),
        },
      };
      when(mockStorage.read(any))
          .thenAnswer((_) => Future.value(jsonEncode(cacheData)));

      // Act
      final isValid = await service.verifyMessageIntegrity(messageId, hash);

      // Assert
      expect(isValid, isTrue);
      verify(mockLogger.info(any)).called(1);
      verify(mockStorage.read(any)).called(1);
    });

    test('should not verify message integrity with expired cached hash',
        () async {
      // Arrange
      const messageId = 'test_message';
      const hash = 'test_hash';
      final cacheData = {
        messageId: {
          'hash': hash,
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
        },
      };
      when(mockStorage.read(any))
          .thenAnswer((_) => Future.value(jsonEncode(cacheData)));
      when(mockStorage.write(any, any)).thenAnswer((_) => Future.value());

      // Act
      final isValid = await service.verifyMessageIntegrity(messageId, hash);

      // Assert
      expect(isValid, isTrue);
      verify(mockLogger.info(any)).called(1);
      verify(mockStorage.read(any)).called(1);
      verify(mockStorage.write(any, any)).called(1);
    });

    test('should verify message signature', () async {
      // Arrange
      const messageId = 'test_message';
      const signature = 'test_signature';

      // Act
      final isValid =
          await service.verifyMessageSignature(messageId, signature);

      // Assert
      expect(isValid, isTrue);
      verify(mockLogger.info(any)).called(1);
    });

    test('should verify valid message timestamp', () async {
      // Arrange
      const messageId = 'test_message';
      final timestamp = DateTime.now().subtract(const Duration(hours: 1));

      // Act
      final isValid =
          await service.verifyMessageTimestamp(messageId, timestamp);

      // Assert
      expect(isValid, isTrue);
      verify(mockLogger.info(any)).called(1);
    });

    test('should not verify future message timestamp', () async {
      // Arrange
      const messageId = 'test_message';
      final timestamp = DateTime.now().add(const Duration(hours: 1));

      // Act
      final isValid =
          await service.verifyMessageTimestamp(messageId, timestamp);

      // Assert
      expect(isValid, isFalse);
      verify(mockLogger.info(any)).called(1);
      verify(mockLogger.warning(any)).called(1);
    });

    test('should not verify old message timestamp', () async {
      // Arrange
      const messageId = 'test_message';
      final timestamp = DateTime.now().subtract(const Duration(days: 2));

      // Act
      final isValid =
          await service.verifyMessageTimestamp(messageId, timestamp);

      // Assert
      expect(isValid, isFalse);
      verify(mockLogger.info(any)).called(1);
      verify(mockLogger.warning(any)).called(1);
    });

    test('should verify message origin', () async {
      // Arrange
      const messageId = 'test_message';
      const senderId = 'test_sender';

      // Act
      final isValid = await service.verifyMessageOrigin(messageId, senderId);

      // Assert
      expect(isValid, isTrue);
      verify(mockLogger.info(any)).called(1);
    });

    test('should handle cache cleanup on initialization', () async {
      // Arrange
      final cacheData = {
        'old_message': {
          'hash': 'old_hash',
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
        },
        'new_message': {
          'hash': 'new_hash',
          'timestamp': DateTime.now().toIso8601String(),
        },
      };
      when(mockStorage.read(any))
          .thenAnswer((_) => Future.value(jsonEncode(cacheData)));
      when(mockStorage.write(any, any)).thenAnswer((_) => Future.value());

      // Act
      await service.initialize();

      // Assert
      verify(mockLogger.info(any)).called(1);
      verify(mockStorage.read(any)).called(1);
      verify(mockStorage.write(any, any)).called(1);
    });

    test('should handle errors during verification', () async {
      // Arrange
      const messageId = 'test_message';
      const hash = 'test_hash';
      when(mockStorage.read(any)).thenThrow(Exception('Test error'));

      // Act
      final isValid = await service.verifyMessageIntegrity(messageId, hash);

      // Assert
      expect(isValid, isFalse);
      verify(mockLogger.info(any)).called(1);
      verify(mockLogger.error(any, any)).called(1);
    });
  });
}
