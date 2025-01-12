import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/interfaces/logger_service_interface.dart';
import 'package:secure_event_app/models/encryption_types.dart';
import 'package:secure_event_app/security/encryption_manager.dart';
import '../mocks/security_mocks.mocks.dart';

void main() {
  group('Encryption Performance Tests', () {
    late MockILoggerService mockLogger;
    late EncryptionManager encryptionManager;

    setUp(() {
      mockLogger = MockILoggerService();
      when(mockLogger.info(any)).thenAnswer((_) async {});
      encryptionManager = EncryptionManager(mockLogger);
    });

    test('Should encrypt and decrypt data within acceptable time limits',
        () async {
      await encryptionManager.initialize();

      final keyPair = await encryptionManager.generateKeyPair();
      final testData = 'Test data for encryption performance test';
      final testBytes = utf8.encode(testData);

      final config = EncryptionConfig(
        type: EncryptionType.aes256,
        level: EncryptionLevel.high,
        keyRotationInterval: const Duration(days: 30),
        requireIntegrityCheck: true,
      );

      final stopwatch = Stopwatch()..start();

      // Perform 100 encryption operations
      for (var i = 0; i < 100; i++) {
        final encryptedData =
            await encryptionManager.encrypt(testBytes, config);
        expect(encryptedData, isNotNull);

        final decryptedData = await encryptionManager.decrypt(encryptedData);
        expect(utf8.decode(decryptedData), equals(testData));
      }

      stopwatch.stop();
      final averageTime = stopwatch.elapsedMilliseconds / 100;

      // Log performance metrics
      await mockLogger
          .info('Average encryption/decryption time: ${averageTime}ms');

      // Verify performance thresholds
      expect(averageTime,
          lessThan(50)); // Each operation should take less than 50ms
    });

    test('Should handle concurrent encryption operations efficiently',
        () async {
      await encryptionManager.initialize();

      final keyPair = await encryptionManager.generateKeyPair();
      final testData = 'Test data for concurrent encryption test';
      final testBytes = utf8.encode(testData);

      final config = EncryptionConfig(
        type: EncryptionType.aes256,
        level: EncryptionLevel.high,
        keyRotationInterval: const Duration(days: 30),
        requireIntegrityCheck: true,
      );

      final stopwatch = Stopwatch()..start();

      // Perform 10 concurrent encryption operations
      final futures = List.generate(10, (index) async {
        final encryptedData =
            await encryptionManager.encrypt(testBytes, config);
        expect(encryptedData, isNotNull);

        final decryptedData = await encryptionManager.decrypt(encryptedData);
        expect(utf8.decode(decryptedData), equals(testData));
      });

      await Future.wait(futures);

      stopwatch.stop();

      // Log performance metrics
      await mockLogger.info(
          'Total time for concurrent operations: ${stopwatch.elapsedMilliseconds}ms');

      // Verify performance thresholds
      expect(stopwatch.elapsedMilliseconds,
          lessThan(1000)); // All operations should complete within 1 second
    });
  });
}
