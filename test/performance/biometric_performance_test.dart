import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/interfaces/logger_service_interface.dart';
import 'package:secure_event_app/models/biometric_types.dart';
import 'package:secure_event_app/security/biometric_manager.dart';
import '../mocks/security_mocks.mocks.dart';

void main() {
  group('Biometric Performance Tests', () {
    late MockILoggerService mockLogger;
    late BiometricManager biometricManager;

    setUp(() {
      mockLogger = MockILoggerService();
      when(mockLogger.info(any)).thenAnswer((_) async {});
      biometricManager = BiometricManager(mockLogger);
    });

    test('Should verify biometrics within acceptable time limits', () async {
      await biometricManager.initialize();

      final stopwatch = Stopwatch()..start();

      // Perform 100 verification attempts
      for (var i = 0; i < 100; i++) {
        final result = await biometricManager.verifyBiometrics(
          userId: 'test_user',
          type: BiometricType.fingerprint,
        );
        expect(result.isSuccessful, isTrue);
      }

      stopwatch.stop();
      final averageTime = stopwatch.elapsedMilliseconds / 100;

      // Log performance metrics
      await mockLogger
          .info('Average biometric verification time: ${averageTime}ms');

      // Verify performance thresholds
      expect(averageTime,
          lessThan(100)); // Each verification should take less than 100ms
    });

    test('Should handle concurrent biometric verifications efficiently',
        () async {
      await biometricManager.initialize();

      final stopwatch = Stopwatch()..start();

      // Perform 10 concurrent verification attempts
      final futures = List.generate(10, (index) async {
        final result = await biometricManager.verifyBiometrics(
          userId: 'test_user_$index',
          type: BiometricType.fingerprint,
        );
        expect(result.isSuccessful, isTrue);
      });

      await Future.wait(futures);

      stopwatch.stop();

      // Log performance metrics
      await mockLogger.info(
          'Total time for concurrent verifications: ${stopwatch.elapsedMilliseconds}ms');

      // Verify performance thresholds
      expect(stopwatch.elapsedMilliseconds,
          lessThan(1000)); // All verifications should complete within 1 second
    });
  });
}
