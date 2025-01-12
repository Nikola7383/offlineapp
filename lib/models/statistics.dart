import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics.freezed.dart';
part 'statistics.g.dart';

@freezed
class Statistics with _$Statistics {
  const factory Statistics({
    required int totalUsers,
    required int activeUsers,
    required int totalMessages,
    required int messagesPerHour,
    required double networkHealth,
    required Map<String, int> usersByRole,
    required List<NetworkEvent> recentEvents,
  }) = _Statistics;

  factory Statistics.fromJson(Map<String, dynamic> json) =>
      _$StatisticsFromJson(json);
}

@freezed
class NetworkEvent with _$NetworkEvent {
  const factory NetworkEvent({
    required String type,
    required String description,
    required DateTime timestamp,
    required String severity,
  }) = _NetworkEvent;

  factory NetworkEvent.fromJson(Map<String, dynamic> json) =>
      _$NetworkEventFromJson(json);
}
