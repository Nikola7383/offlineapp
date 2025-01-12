import 'package:freezed_annotation/freezed_annotation.dart';

part 'bluetooth_security_types.freezed.dart';

/// Tipovi Bluetooth bezbednosnih događaja
enum BluetoothSecurityEventType {
  deviceDetected,
  connectionAttempt,
  connectionEstablished,
  connectionFailed,
  connectionTerminated,
  securityViolation,
  threatDetected,
  policyViolation,
  keyExchange,
  authenticationSuccess,
  authenticationFailure,
}

/// Nivoi bezbednosti Bluetooth veze
enum BluetoothSecurityLevel {
  none,
  low,
  medium,
  high,
  critical,
}

/// Status Bluetooth veze
enum BluetoothConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

/// Tipovi Bluetooth pretnji
enum BluetoothThreatType {
  spoofing,
  manInTheMiddle,
  eavesdropping,
  denialOfService,
  unauthorizedAccess,
  maliciousDevice,
  jamming,
}

/// Bluetooth uređaj
@freezed
class BluetoothDevice with _$BluetoothDevice {
  const factory BluetoothDevice({
    required String id,
    required String name,
    required String address,
    required bool isPaired,
    required bool isConnected,
    required BluetoothSecurityLevel securityLevel,
    String? lastSeen,
    Map<String, dynamic>? metadata,
  }) = _BluetoothDevice;
}

/// Status bezbednosti Bluetooth veze
@freezed
class BluetoothSecurityStatus with _$BluetoothSecurityStatus {
  const factory BluetoothSecurityStatus({
    required String deviceId,
    required BluetoothSecurityLevel securityLevel,
    required bool isEncrypted,
    required bool isAuthenticated,
    required bool isPaired,
    required DateTime lastChecked,
    List<String>? vulnerabilities,
    Map<String, dynamic>? securityFeatures,
  }) = _BluetoothSecurityStatus;
}

/// Bluetooth veza
@freezed
class BluetoothConnection with _$BluetoothConnection {
  const factory BluetoothConnection({
    required String deviceId,
    required BluetoothConnectionState state,
    required BluetoothSecurityLevel securityLevel,
    required DateTime establishedAt,
    required bool isEncrypted,
    String? encryptionType,
    Map<String, dynamic>? connectionParams,
  }) = _BluetoothConnection;
}

/// Bezbednosni izveštaj za Bluetooth
@freezed
class BluetoothSecurityReport with _$BluetoothSecurityReport {
  const factory BluetoothSecurityReport({
    required String reportId,
    required DateTime generatedAt,
    required int scannedDevices,
    required int connectedDevices,
    required int securityIncidents,
    required List<BluetoothThreat> detectedThreats,
    required Map<String, BluetoothSecurityStatus> deviceStatuses,
    List<String>? recommendations,
  }) = _BluetoothSecurityReport;
}

/// Konfiguracija Bluetooth bezbednosti
@freezed
class BluetoothSecurityConfig with _$BluetoothSecurityConfig {
  const factory BluetoothSecurityConfig({
    required BluetoothSecurityLevel minimumSecurityLevel,
    required bool requireEncryption,
    required bool requireAuthentication,
    required Duration scanInterval,
    required Duration connectionTimeout,
    List<String>? allowedDevices,
    List<String>? blockedDevices,
    Map<String, dynamic>? customParams,
  }) = _BluetoothSecurityConfig;
}

/// Bluetooth pretnja
@freezed
class BluetoothThreat with _$BluetoothThreat {
  const factory BluetoothThreat({
    required String id,
    required BluetoothThreatType type,
    required String deviceId,
    required DateTime detectedAt,
    required String description,
    required BluetoothSecurityLevel severity,
    String? recommendation,
    Map<String, dynamic>? details,
  }) = _BluetoothThreat;
}

/// Bluetooth bezbednosna politika
@freezed
class BluetoothSecurityPolicy with _$BluetoothSecurityPolicy {
  const factory BluetoothSecurityPolicy({
    required String id,
    required String name,
    required bool isEnabled,
    required BluetoothSecurityLevel requiredLevel,
    required List<BluetoothThreatType> protectedThreats,
    required Map<String, dynamic> rules,
    String? description,
    DateTime? lastUpdated,
  }) = _BluetoothSecurityPolicy;
}

/// Bluetooth bezbednosni događaj
@freezed
class BluetoothSecurityEvent with _$BluetoothSecurityEvent {
  const factory BluetoothSecurityEvent({
    required String id,
    required BluetoothSecurityEventType type,
    required String deviceId,
    required DateTime timestamp,
    required BluetoothSecurityLevel severity,
    String? description,
    Map<String, dynamic>? metadata,
  }) = _BluetoothSecurityEvent;
}

/// Status Bluetooth veze
@freezed
class BluetoothConnectionStatus with _$BluetoothConnectionStatus {
  const factory BluetoothConnectionStatus({
    required String deviceId,
    required BluetoothConnectionState state,
    required DateTime timestamp,
    String? errorMessage,
    Map<String, dynamic>? details,
  }) = _BluetoothConnectionStatus;
}
