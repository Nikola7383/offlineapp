import 'package:freezed_annotation/freezed_annotation.dart';

part 'critical_message.freezed.dart';
part 'critical_message.g.dart';

@freezed
class CriticalMessage with _$CriticalMessage {
  const factory CriticalMessage({
    required String id,
    required String message,
    required MessagePriority priority,
    required MessageStatus status,
    required DateTime timestamp,
    String? source,
    String? destination,
    Map<String, dynamic>? metadata,
  }) = _CriticalMessage;

  factory CriticalMessage.fromJson(Map<String, dynamic> json) =>
      _$CriticalMessageFromJson(json);
}

enum MessagePriority { low, medium, high, critical, immediate }

enum MessageStatus { pending, sent, delivered, failed }
