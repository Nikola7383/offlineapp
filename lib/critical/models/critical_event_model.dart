import 'package:freezed_annotation/freezed_annotation.dart';

part 'critical_event_model.freezed.dart';
part 'critical_event_model.g.dart';

@freezed
class CriticalEvent with _$CriticalEvent {
  const factory CriticalEvent({
    required String id,
    required CriticalLevel level,
    required String message,
    required DateTime timestamp,
  }) = _CriticalEvent;

  factory CriticalEvent.fromJson(Map<String, dynamic> json) =>
      _$CriticalEventFromJson(json);
}

@freezed
class CriticalStatusModel with _$CriticalStatusModel {
  const factory CriticalStatusModel({
    required StatusModel stateStatus,
    required ResourceStatusModel resourceStatus,
    required SecurityStatusModel securityStatus,
    required SystemStatusModel systemStatus,
    required DateTime timestamp,
  }) = _CriticalStatusModel;

  factory CriticalStatusModel.fromJson(Map<String, dynamic> json) =>
      _$CriticalStatusModelFromJson(json);
}

@freezed
class StatusModel with _$StatusModel {
  const factory StatusModel({
    required bool isStable,
    required bool isFailure,
    String? message,
  }) = _StatusModel;

  factory StatusModel.fromJson(Map<String, dynamic> json) =>
      _$StatusModelFromJson(json);
}

@freezed
class ResourceStatusModel with _$ResourceStatusModel {
  const factory ResourceStatusModel({
    required bool isSufficient,
    required bool isCritical,
    required double memoryUsage,
    required double storageUsage,
    required double powerUsage,
  }) = _ResourceStatusModel;

  factory ResourceStatusModel.fromJson(Map<String, dynamic> json) =>
      _$ResourceStatusModelFromJson(json);
}

@freezed
class SecurityStatusModel with _$SecurityStatusModel {
  const factory SecurityStatusModel({
    required bool isSecure,
    required bool isCompromised,
    required List<String> threats,
  }) = _SecurityStatusModel;

  factory SecurityStatusModel.fromJson(Map<String, dynamic> json) =>
      _$SecurityStatusModelFromJson(json);
}

@freezed
class SystemStatusModel with _$SystemStatusModel {
  const factory SystemStatusModel({
    required bool isOperational,
    required bool isFailure,
    required List<String> errors,
  }) = _SystemStatusModel;

  factory SystemStatusModel.fromJson(Map<String, dynamic> json) =>
      _$SystemStatusModelFromJson(json);
}

enum CriticalLevel { normal, warning, severe, critical, failure }
