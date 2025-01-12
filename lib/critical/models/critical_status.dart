import 'package:freezed_annotation/freezed_annotation.dart';
import 'base_model.dart';

part 'critical_status.freezed.dart';
part 'critical_status.g.dart';

@freezed
class Status with _$Status {
  const factory Status({
    required bool isStable,
    required bool isFailure,
    String? message,
  }) = _Status;

  factory Status.fromJson(Map<String, dynamic> json) => _$StatusFromJson(json);
}

@freezed
class ResourceStatus with _$ResourceStatus {
  const factory ResourceStatus({
    required bool isSufficient,
    required bool isCritical,
    required double memoryUsage,
    required double storageUsage,
    required double powerUsage,
  }) = _ResourceStatus;

  factory ResourceStatus.fromJson(Map<String, dynamic> json) =>
      _$ResourceStatusFromJson(json);
}

@freezed
class SecurityStatus with _$SecurityStatus {
  const factory SecurityStatus({
    required bool isSecure,
    required bool isCompromised,
    required List<String> threats,
  }) = _SecurityStatus;

  factory SecurityStatus.fromJson(Map<String, dynamic> json) =>
      _$SecurityStatusFromJson(json);
}

@freezed
class SystemStatus with _$SystemStatus {
  const factory SystemStatus({
    required bool isOperational,
    required bool isFailure,
    required List<String> errors,
  }) = _SystemStatus;

  factory SystemStatus.fromJson(Map<String, dynamic> json) =>
      _$SystemStatusFromJson(json);
}

@freezed
class CriticalStatus with BaseModelMixin, _$CriticalStatus {
  const factory CriticalStatus({
    required String id,
    required DateTime timestamp,
    required Status stateStatus,
    required ResourceStatus resourceStatus,
    required SecurityStatus securityStatus,
    required SystemStatus systemStatus,
  }) = _CriticalStatus;

  factory CriticalStatus.fromJson(Map<String, dynamic> json) =>
      _$CriticalStatusFromJson(json);
}
