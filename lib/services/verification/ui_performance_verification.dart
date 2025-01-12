import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'ui_performance_verification.freezed.dart';
part 'ui_performance_verification.g.dart';

@freezed
class UIPerformanceMetrics with _$UIPerformanceMetrics {
  const factory UIPerformanceMetrics({
    @Default(0) int frameTime,
    @Default(0) int buildTime,
    @Default(0) int layoutTime,
    @Default(0) int paintTime,
    @Default([]) List<String> jankFrames,
  }) = _UIPerformanceMetrics;

  factory UIPerformanceMetrics.fromJson(Map<String, dynamic> json) =>
      _$UIPerformanceMetricsFromJson(json);
}

@freezed
class UIPerformanceReport with _$UIPerformanceReport {
  const factory UIPerformanceReport({
    required UIPerformanceMetrics metrics,
    @Default([]) List<String> warnings,
    @Default([]) List<String> recommendations,
  }) = _UIPerformanceReport;

  factory UIPerformanceReport.fromJson(Map<String, dynamic> json) =>
      _$UIPerformanceReportFromJson(json);
}

@injectable
class UIPerformanceVerification {
  Future<UIPerformanceReport> verifyPerformance() async {
    // TODO: Implementirati verifikaciju performansi
    return const UIPerformanceReport(
      metrics: UIPerformanceMetrics(),
      warnings: [],
      recommendations: [],
    );
  }
}
