import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:secure_event_app/core/interfaces/base_service.dart';
import 'package:secure_event_app/core/interfaces/biometric_interface.dart';
import 'package:secure_event_app/core/interfaces/logger_service_interface.dart';
import 'package:secure_event_app/models/biometric_types.dart';

@singleton
class BiometricManager implements IBiometricManager {
  final ILoggerService _logger;
  bool _isInitialized = false;
  BiometricConfig? _config;

  final _biometricEventController =
      StreamController<BiometricEvent>.broadcast();
  final _biometricStatusController =
      StreamController<BiometricStatus>.broadcast();

  BiometricManager(this._logger);

  @override
  bool get isInitialized => _isInitialized;

  @override
  Stream<BiometricEvent> get biometricEvents =>
      _biometricEventController.stream;

  @override
  Stream<BiometricStatus> get biometricStatus =>
      _biometricStatusController.stream;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      await _logger.warning('BiometricManager is already initialized');
      return;
    }

    await _logger.info('Initializing BiometricManager');

    // Podrazumevana konfiguracija
    _config = const BiometricConfig(
      defaultTimeoutSeconds: 30,
      maxFailedAttempts: 3,
      requireStrongAuthentication: true,
    );

    _isInitialized = true;
    await _logger.info('BiometricManager initialized successfully');

    // Emituj inicijalni status
    _biometricStatusController.add(
      BiometricStatus(
        availability: BiometricAvailability.available,
        supportedTypes: [BiometricType.fingerprint, BiometricType.faceId],
        isConfigured: true,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) {
      await _logger.warning('BiometricManager is not initialized');
      return;
    }

    await _logger.info('Disposing BiometricManager');

    await _biometricEventController.close();
    await _biometricStatusController.close();

    _isInitialized = false;
    await _logger.info('BiometricManager disposed successfully');
  }

  @override
  Future<BiometricAvailability> checkAvailability() async {
    if (!_isInitialized) {
      throw StateError('BiometricManager is not initialized');
    }

    await _logger.info('Checking biometric availability');
    return BiometricAvailability.available;
  }

  @override
  Future<List<BiometricType>> getSupportedBiometrics() async {
    if (!_isInitialized) {
      throw StateError('BiometricManager is not initialized');
    }

    await _logger.info('Getting supported biometric types');
    return [BiometricType.fingerprint, BiometricType.faceId];
  }

  @override
  Future<BiometricEnrollResult> enrollBiometrics({
    required String userId,
    required BiometricType type,
    BiometricEnrollOptions? options,
  }) async {
    if (!_isInitialized) {
      throw StateError('BiometricManager is not initialized');
    }

    await _logger.info('Enrolling biometrics for user: $userId, type: $type');

    final result = BiometricEnrollResult(
      isSuccessful: true,
      enrollmentId: 'enroll_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
    );

    _biometricEventController.add(
      BiometricEvent(
        eventId: 'event_${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        type: type,
        userId: userId,
        action: 'enroll',
        isSuccessful: result.isSuccessful,
      ),
    );

    return result;
  }

  @override
  Future<BiometricVerificationResult> verifyBiometrics({
    required String userId,
    required BiometricType type,
    BiometricVerificationOptions? options,
  }) async {
    if (!_isInitialized) {
      throw StateError('BiometricManager is not initialized');
    }

    await _logger.info('Verifying biometrics for user: $userId, type: $type');

    final result = BiometricVerificationResult(
      isSuccessful: true,
      verificationId: 'verify_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
    );

    _biometricEventController.add(
      BiometricEvent(
        eventId: 'event_${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        type: type,
        userId: userId,
        action: 'verify',
        isSuccessful: result.isSuccessful,
      ),
    );

    return result;
  }

  @override
  Future<void> removeBiometrics({
    required String userId,
    BiometricType? type,
  }) async {
    if (!_isInitialized) {
      throw StateError('BiometricManager is not initialized');
    }

    await _logger.info('Removing biometrics for user: $userId, type: $type');

    _biometricEventController.add(
      BiometricEvent(
        eventId: 'event_${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        type: type ?? BiometricType.fingerprint,
        userId: userId,
        action: 'remove',
        isSuccessful: true,
      ),
    );
  }

  @override
  Future<BiometricReport> generateReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized) {
      throw StateError('BiometricManager is not initialized');
    }

    await _logger.info('Generating biometric report');

    return BiometricReport(
      reportId: 'report_${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      totalVerifications: 10,
      successfulVerifications: 8,
      failedVerifications: 2,
      verificationsByType: {
        BiometricType.fingerprint: 6,
        BiometricType.faceId: 4,
      },
      failureReasons: {
        BiometricFailureReason.timeout: 1,
        BiometricFailureReason.notRecognized: 1,
      },
    );
  }

  @override
  Future<void> configure(BiometricConfig config) async {
    if (!_isInitialized) {
      throw StateError('BiometricManager is not initialized');
    }

    await _logger.info('Configuring BiometricManager');
    _config = config;

    _biometricStatusController.add(
      BiometricStatus(
        availability: BiometricAvailability.available,
        supportedTypes: [BiometricType.fingerprint, BiometricType.faceId],
        isConfigured: true,
        lastUpdated: DateTime.now(),
      ),
    );
  }
}
