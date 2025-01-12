import 'package:freezed_annotation/freezed_annotation.dart';

part 'critical_event.freezed.dart';
part 'critical_event.g.dart';

@freezed
class CriticalEvent with _$CriticalEvent {
  const factory CriticalEvent({
    required String id,
    required DateTime timestamp,
    required String message,
    required CriticalLevel level,
  }) = _CriticalEvent;

  factory CriticalEvent.fromJson(Map<String, dynamic> json) =>
      _$CriticalEventFromJson(json);
}

enum CriticalLevel { normal, warning, severe, critical, failure }
