import 'package:freezed_annotation/freezed_annotation.dart';

part 'system_health.freezed.dart';
part 'system_health.g.dart';

@freezed
class SystemHealthMetrics with _$SystemHealthMetrics {
  const factory SystemHealthMetrics({
    @Default(0) int cpuUsage,
    @Default(0) int memoryUsage,
    @Default(0) int networkLatency,
    @Default(0) int diskUsage,
    @Default([]) List<String> warnings,
  }) = _SystemHealthMetrics;

  factory SystemHealthMetrics.fromJson(Map<String, dynamic> json) =>
      _$SystemHealthMetricsFromJson(json);
}

class SystemHealthMonitor {
  Future<SystemHealthMetrics> checkHealth() async {
    // TODO: Implementirati proveru zdravlja sistema
    return const SystemHealthMetrics();
  }
}
