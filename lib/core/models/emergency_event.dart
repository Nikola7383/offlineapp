import 'package:freezed_annotation/freezed_annotation.dart';

part 'emergency_event.freezed.dart';
part 'emergency_event.g.dart';

@freezed
class EmergencyEvent with _$EmergencyEvent {
  const factory EmergencyEvent({
    required String id,
    required String type,
    required Map<String, dynamic> data,
    required DateTime timestamp,
    required int priority,
    String? location,
    String? severity,
    Map<String, dynamic>? metadata,
  }) = _EmergencyEvent;

  factory EmergencyEvent.fromJson(Map<String, dynamic> json) =>
      _$EmergencyEventFromJson(json);
}
