import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/interfaces/logger_service_interface.dart';
import 'package:secure_event_app/models/biometric_types.dart';
import 'package:secure_event_app/security/biometric_manager.dart';
import '../mocks/security_mocks.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late BiometricManager biometricManager;

  setUp(() {
    mockLogger = MockILoggerService();
    biometricManager = BiometricManager(mockLogger);
  });

  group('BiometricManager Tests', () {
    test('initialize() should set up the manager correctly', () async {
      // Arrange
      when(mockLogger.info(any)).thenAnswer((_) => Future.value());

      // Act
      await biometricManager.initialize();

      // Assert
      expect(biometricManager.isInitialized, true);
      verify(mockLogger.info('Initializing BiometricManager')).called(1);
      verify(mockLogger.info('BiometricManager initialized successfully'))
          .called(1);
    });

    test('initialize() should not initialize if already initialized', () async {
      // Arrange
      when(mockLogger.info(any)).thenAnswer((_) => Future.value());
      when(mockLogger.warning(any)).thenAnswer((_) => Future.value());
      await biometricManager.initialize();

      // Act
      await biometricManager.initialize();

      // Assert
      verify(mockLogger.warning('BiometricManager is already initialized'))
          .called(1);
    });

    test('dispose() should clean up resources', () async {
      // Arrange
      when(mockLogger.info(any)).thenAnswer((_) => Future.value());
      await biometricManager.initialize();

      // Act
      await biometricManager.dispose();

      // Assert
      expect(biometricManager.isInitialized, false);
      verify(mockLogger.info('Disposing BiometricManager')).called(1);
      verify(mockLogger.info('BiometricManager disposed successfully'))
          .called(1);
    });

    test('checkAvailability() should return availability status', () async {
      // Arrange
      when(mockLogger.info(any)).thenAnswer((_) => Future.value());
      await biometricManager.initialize();

      // Act
      final result = await biometricManager.checkAvailability();

      // Assert
      expect(result, BiometricAvailability.available);
      verify(mockLogger.info('Checking biometric availability')).called(1);
    });

    test('getSupportedBiometrics() should return supported types', () async {
      // Arrange
      when(mockLogger.info(any)).thenAnswer((_) => Future.value());
      await biometricManager.initialize();

      // Act
      final result = await biometricManager.getSupportedBiometrics();

      // Assert
      expect(result, [BiometricType.fingerprint, BiometricType.faceId]);
      verify(mockLogger.info('Getting supported biometric types')).called(1);
    });

    test('enrollBiometrics() should enroll biometrics successfully', () async {
      // Arrange
      when(mockLogger.info(any)).thenAnswer((_) => Future.value());
      await biometricManager.initialize();

      // Act
      final result = await biometricManager.enrollBiometrics(
        userId: 'test_user',
        type: BiometricType.fingerprint,
      );

      // Assert
      expect(result.isSuccessful, true);
      expect(result.enrollmentId, isNotEmpty);
      expect(result.timestamp, isNotNull);
      verify(mockLogger.info(any)).called(anyNamed('times'));
    });

    test('verifyBiometrics() should verify biometrics successfully', () async {
      // Arrange
      when(mockLogger.info(any)).thenAnswer((_) => Future.value());
      await biometricManager.initialize();

      // Act
      final result = await biometricManager.verifyBiometrics(
        userId: 'test_user',
        type: BiometricType.fingerprint,
      );

      // Assert
      expect(result.isSuccessful, true);
      expect(result.verificationId, isNotEmpty);
      expect(result.timestamp, isNotNull);
      verify(mockLogger.info(any)).called(anyNamed('times'));
    });

    test('removeBiometrics() should remove biometrics successfully', () async {
      // Arrange
      when(mockLogger.info(any)).thenAnswer((_) => Future.value());
      await biometricManager.initialize();

      // Act
      await biometricManager.removeBiometrics(
        userId: 'test_user',
        type: BiometricType.fingerprint,
      );

      // Assert
      verify(mockLogger.info(any)).called(anyNamed('times'));
    });

    test('generateReport() should generate report successfully', () async {
      // Arrange
      when(mockLogger.info(any)).thenAnswer((_) => Future.value());
      await biometricManager.initialize();

      // Act
      final report = await biometricManager.generateReport();

      // Assert
      expect(report.reportId, isNotEmpty);
      expect(report.generatedAt, isNotNull);
      expect(report.totalVerifications, equals(10));
      expect(report.successfulVerifications, equals(8));
      expect(report.failedVerifications, equals(2));
      expect(report.verificationsByType, isNotEmpty);
      expect(report.failureReasons, isNotEmpty);
      verify(mockLogger.info('Generating biometric report')).called(1);
    });

    test('configure() should update configuration successfully', () async {
      // Arrange
      when(mockLogger.info(any)).thenAnswer((_) => Future.value());
      await biometricManager.initialize();

      final config = BiometricConfig(
        defaultTimeoutSeconds: 60,
        maxFailedAttempts: 5,
        requireStrongAuthentication: true,
      );

      // Act
      await biometricManager.configure(config);

      // Assert
      verify(mockLogger.info('Configuring BiometricManager')).called(1);
    });

    test('biometricEvents stream should emit events', () async {
      // Arrange
      when(mockLogger.info(any)).thenAnswer((_) => Future.value());
      await biometricManager.initialize();

      // Act & Assert
      expectLater(
        biometricManager.biometricEvents,
        emits(predicate<BiometricEvent>((event) =>
            event.userId == 'test_user' &&
            event.type == BiometricType.fingerprint &&
            event.action == 'enroll' &&
            event.isSuccessful == true)),
      );

      await biometricManager.enrollBiometrics(
        userId: 'test_user',
        type: BiometricType.fingerprint,
      );
    });

    test('biometricStatus stream should emit status updates', () async {
      // Arrange
      when(mockLogger.info(any)).thenAnswer((_) => Future.value());

      // Act & Assert
      expectLater(
        biometricManager.biometricStatus,
        emits(predicate<BiometricStatus>((status) =>
            status.availability == BiometricAvailability.available &&
            status.isConfigured == true &&
            status.supportedTypes.contains(BiometricType.fingerprint))),
      );

      await biometricManager.initialize();
    });
  });
}
