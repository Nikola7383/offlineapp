import 'package:freezed_annotation/freezed_annotation.dart';

part 'raw_event.freezed.dart';
part 'raw_event.g.dart';

@freezed
class RawEvent with _$RawEvent {
  const factory RawEvent({
    required String id,
    required String type,
    required String source,
    required DateTime timestamp,
    required Map<String, dynamic> data,
  }) = _RawEvent;

  factory RawEvent.fromJson(Map<String, dynamic> json) =>
      _$RawEventFromJson(json);
}
