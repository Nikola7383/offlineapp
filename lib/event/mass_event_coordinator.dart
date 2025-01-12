import 'package:freezed_annotation/freezed_annotation.dart';

part 'mass_event_coordinator.freezed.dart';
part 'mass_event_coordinator.g.dart';

@freezed
class EventMetrics with _$EventMetrics {
  const factory EventMetrics({
    @Default(0) int activeUsers,
    @Default(0) int messageCount,
    @Default(0) int errorCount,
    @Default([]) List<String> warnings,
  }) = _EventMetrics;

  factory EventMetrics.fromJson(Map<String, dynamic> json) =>
      _$EventMetricsFromJson(json);
}

class MassEventCoordinator {
  Future<EventMetrics> monitorEvent() async {
    // TODO: Implementirati monitoring događaja
    return const EventMetrics();
  }
}
