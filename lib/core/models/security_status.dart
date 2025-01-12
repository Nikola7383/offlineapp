import 'package:freezed_annotation/freezed_annotation.dart';

part 'security_status.freezed.dart';
part 'security_status.g.dart';

@freezed
class SecurityManagerStatus with _$SecurityManagerStatus {
  const factory SecurityManagerStatus({
    required QueueStatus eventQueueStatus,
    required StateStatus stateStatus,
    required NetworkStatus networkStatus,
    required SecurityStatus securityStatus,
    required DateTime timestamp,
  }) = _SecurityManagerStatus;

  factory SecurityManagerStatus.fromJson(Map<String, dynamic> json) =>
      _$SecurityManagerStatusFromJson(json);
}

@freezed
class QueueStatus with _$QueueStatus {
  const factory QueueStatus({
    required int size,
    required int processedCount,
    required int errorCount,
    required Duration averageProcessingTime,
  }) = _QueueStatus;

  factory QueueStatus.fromJson(Map<String, dynamic> json) =>
      _$QueueStatusFromJson(json);
}

@freezed
class StateStatus with _$StateStatus {
  const factory StateStatus({
    required bool isValid,
    required bool isSynchronized,
    required DateTime lastSyncTime,
  }) = _StateStatus;

  factory StateStatus.fromJson(Map<String, dynamic> json) =>
      _$StateStatusFromJson(json);
}

@freezed
class NetworkStatus with _$NetworkStatus {
  const factory NetworkStatus({
    required bool isConnected,
    required int activeNodes,
    required int messageQueueSize,
    required DateTime lastActivity,
  }) = _NetworkStatus;

  factory NetworkStatus.fromJson(Map<String, dynamic> json) =>
      _$NetworkStatusFromJson(json);
}

@freezed
class SecurityStatus with _$SecurityStatus {
  const factory SecurityStatus({
    required bool isSecure,
    required int threatLevel,
    required List<String> activeThreats,
    required DateTime lastCheck,
  }) = _SecurityStatus;

  factory SecurityStatus.fromJson(Map<String, dynamic> json) =>
      _$SecurityStatusFromJson(json);
}
