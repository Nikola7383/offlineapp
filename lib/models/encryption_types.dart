import 'package:freezed_annotation/freezed_annotation.dart';

part 'encryption_types.freezed.dart';

/// Tipovi enkripcije
enum EncryptionType {
  aes256,
  rsa2048,
  rsa4096,
  chacha20,
  none,
}

/// Nivoi enkripcije
enum EncryptionLevel {
  none,
  low,
  medium,
  high,
  critical,
}

/// Operacije nad ključevima
enum KeyOperationType {
  generate,
  rotate,
  revoke,
  backup,
  restore,
}

/// Status ključa
enum KeyState {
  active,
  inactive,
  compromised,
  expired,
  revoked,
}

/// Enkriptovani podaci
@freezed
class EncryptedData with _$EncryptedData {
  const factory EncryptedData({
    required String id,
    required List<int> data,
    required String algorithm,
    required DateTime timestamp,
    required String keyId,
    String? iv,
    Map<String, dynamic>? metadata,
  }) = _EncryptedData;
}

/// Par ključeva
@freezed
class KeyPair with _$KeyPair {
  const factory KeyPair({
    required String id,
    required String publicKey,
    required String privateKey,
    required DateTime createdAt,
    required DateTime expiresAt,
    required KeyState state,
    Map<String, dynamic>? metadata,
  }) = _KeyPair;
}

/// Konfiguracija enkripcije
@freezed
class EncryptionConfig with _$EncryptionConfig {
  const factory EncryptionConfig({
    required EncryptionType type,
    required EncryptionLevel level,
    required Duration keyRotationInterval,
    required bool requireIntegrityCheck,
    Map<String, dynamic>? parameters,
  }) = _EncryptionConfig;
}

/// Operacija nad ključem
@freezed
class KeyOperation with _$KeyOperation {
  const factory KeyOperation({
    required String id,
    required KeyOperationType type,
    required String keyId,
    required DateTime timestamp,
    String? reason,
    Map<String, dynamic>? parameters,
  }) = _KeyOperation;
}

/// Izveštaj o enkripciji
@freezed
class EncryptionReport with _$EncryptionReport {
  const factory EncryptionReport({
    required String id,
    required DateTime generatedAt,
    required int totalOperations,
    required int activeKeys,
    required Map<String, int> operationStats,
    required List<String> warnings,
    required List<String> recommendations,
  }) = _EncryptionReport;
}

/// Status enkripcije
@freezed
class EncryptionStatus with _$EncryptionStatus {
  const factory EncryptionStatus({
    required bool isInitialized,
    required EncryptionType currentType,
    required EncryptionLevel currentLevel,
    required int activeKeys,
    required DateTime lastKeyRotation,
    List<String>? warnings,
  }) = _EncryptionStatus;
}

/// Događaj enkripcije
@freezed
class EncryptionEvent with _$EncryptionEvent {
  const factory EncryptionEvent({
    required String id,
    required String description,
    required DateTime timestamp,
    required EncryptionLevel severity,
    String? relatedKeyId,
    Map<String, dynamic>? metadata,
  }) = _EncryptionEvent;
}

/// Status ključa
@freezed
class KeyStatus with _$KeyStatus {
  const factory KeyStatus({
    required String keyId,
    required KeyState state,
    required DateTime lastUsed,
    required int usageCount,
    required bool isCompromised,
    String? compromiseReason,
  }) = _KeyStatus;
}
