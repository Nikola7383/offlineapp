import 'package:freezed_annotation/freezed_annotation.dart';

part 'biometric_types.freezed.dart';

/// Tipovi biometrijske autentifikacije
enum BiometricType { fingerprint, faceId, iris, voiceprint }

/// Status dostupnosti biometrijske autentifikacije
enum BiometricAvailability {
  available,
  notAvailable,
  notSupported,
  requiresPermission,
  hardwareUnavailable
}

/// Razlozi neuspešne biometrijske verifikacije
enum BiometricFailureReason {
  notRecognized,
  timeout,
  tooManyAttempts,
  hardwareError,
  userCancelled,
  notEnrolled,
  securityError
}

/// Opcije za registraciju biometrijskih podataka
@freezed
class BiometricEnrollOptions with _$BiometricEnrollOptions {
  const factory BiometricEnrollOptions({
    required int timeoutSeconds,
    required bool allowMultipleEnrollments,
    String? localizedReason,
    Map<String, dynamic>? additionalOptions,
  }) = _BiometricEnrollOptions;
}

/// Rezultat registracije biometrijskih podataka
@freezed
class BiometricEnrollResult with _$BiometricEnrollResult {
  const factory BiometricEnrollResult({
    required bool isSuccessful,
    required String enrollmentId,
    BiometricFailureReason? failureReason,
    String? errorMessage,
    DateTime? timestamp,
  }) = _BiometricEnrollResult;
}

/// Opcije za verifikaciju biometrijskih podataka
@freezed
class BiometricVerificationOptions with _$BiometricVerificationOptions {
  const factory BiometricVerificationOptions({
    required int timeoutSeconds,
    required int maxAttempts,
    String? localizedReason,
    Map<String, dynamic>? additionalOptions,
  }) = _BiometricVerificationOptions;
}

/// Rezultat verifikacije biometrijskih podataka
@freezed
class BiometricVerificationResult with _$BiometricVerificationResult {
  const factory BiometricVerificationResult({
    required bool isSuccessful,
    required String verificationId,
    BiometricFailureReason? failureReason,
    String? errorMessage,
    DateTime? timestamp,
  }) = _BiometricVerificationResult;
}

/// Konfiguracija biometrijske autentifikacije
@freezed
class BiometricConfig with _$BiometricConfig {
  const factory BiometricConfig({
    required int defaultTimeoutSeconds,
    required int maxFailedAttempts,
    required bool requireStrongAuthentication,
    Map<String, dynamic>? additionalSettings,
  }) = _BiometricConfig;
}

/// Izveštaj o biometrijskoj autentifikaciji
@freezed
class BiometricReport with _$BiometricReport {
  const factory BiometricReport({
    required String reportId,
    required DateTime generatedAt,
    required int totalVerifications,
    required int successfulVerifications,
    required int failedVerifications,
    required Map<BiometricType, int> verificationsByType,
    required Map<BiometricFailureReason, int> failureReasons,
    Map<String, dynamic>? additionalMetrics,
  }) = _BiometricReport;
}

/// Događaj vezan za biometrijsku autentifikaciju
@freezed
class BiometricEvent with _$BiometricEvent {
  const factory BiometricEvent({
    required String eventId,
    required DateTime timestamp,
    required BiometricType type,
    required String userId,
    required String action,
    required bool isSuccessful,
    BiometricFailureReason? failureReason,
    Map<String, dynamic>? metadata,
  }) = _BiometricEvent;
}

/// Status biometrijske autentifikacije
@freezed
class BiometricStatus with _$BiometricStatus {
  const factory BiometricStatus({
    required BiometricAvailability availability,
    required List<BiometricType> supportedTypes,
    required bool isConfigured,
    required DateTime lastUpdated,
    Map<String, dynamic>? additionalInfo,
  }) = _BiometricStatus;
}
