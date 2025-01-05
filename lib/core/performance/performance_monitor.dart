import 'dart:developer' as developer;
import '../logging/logger_service.dart';

class PerformanceMonitor {
  final LoggerService _logger;
  final Map<String, _PerformanceMetric> _metrics = {};
  static const int _warningThresholdMs = 16; // 60fps target

  PerformanceMonitor({
    required LoggerService logger,
  }) : _logger = logger;

  void startOperation(String name) {
    _metrics[name] = _PerformanceMetric(
      name: name,
      startTime: DateTime.now(),
    );
  }

  void endOperation(String name) {
    final metric = _metrics[name];
    if (metric == null) {
      _logger.warning('No matching start time found for operation: $name');
      return;
    }

    final duration = DateTime.now().difference(metric.startTime);
    metric.durations.add(duration);

    if (duration.inMilliseconds > _warningThresholdMs) {
      _logger.warning(
        'Operation $name took ${duration.inMilliseconds}ms '
        '(exceeds ${_warningThresholdMs}ms threshold)',
      );
    }

    // Dodaj u Timeline za detaljniju analizu
    developer.Timeline.timeSync(
      name,
      () {},
      arguments: {'duration': duration.inMicroseconds},
    );
  }

  void clearMetrics() {
    _metrics.clear();
  }

  Map<String, PerformanceReport> getReports() {
    return _metrics.map((key, metric) {
      return MapEntry(key, metric.generateReport());
    });
  }

  // Memorija
  void reportMemoryUsage() {
    final memoryInfo = developer.Service.getInfo();
    _logger.info('Memory Usage: ${memoryInfo.toString()}');
  }
}

class _PerformanceMetric {
  final String name;
  final DateTime startTime;
  final List<Duration> durations = [];

  _PerformanceMetric({
    required this.name,
    required this.startTime,
  });

  PerformanceReport generateReport() {
    if (durations.isEmpty) return PerformanceReport.empty(name);

    final totalMs = durations.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );

    final avgMs = totalMs / durations.length;
    final sorted = List<Duration>.from(durations)..sort();
    final medianMs = sorted[sorted.length ~/ 2].inMilliseconds;

    return PerformanceReport(
      name: name,
      averageMs: avgMs,
      medianMs: medianMs,
      minMs: sorted.first.inMilliseconds,
      maxMs: sorted.last.inMilliseconds,
      sampleCount: durations.length,
    );
  }
}

class PerformanceReport {
  final String name;
  final double averageMs;
  final int medianMs;
  final int minMs;
  final int maxMs;
  final int sampleCount;

  PerformanceReport({
    required this.name,
    required this.averageMs,
    required this.medianMs,
    required this.minMs,
    required this.maxMs,
    required this.sampleCount,
  });

  factory PerformanceReport.empty(String name) {
    return PerformanceReport(
      name: name,
      averageMs: 0,
      medianMs: 0,
      minMs: 0,
      maxMs: 0,
      sampleCount: 0,
    );
  }

  @override
  String toString() {
    return 'Performance Report for $name:\n'
        'Average: ${averageMs.toStringAsFixed(2)}ms\n'
        'Median: ${medianMs}ms\n'
        'Min: ${minMs}ms\n'
        'Max: ${maxMs}ms\n'
        'Samples: $sampleCount';
  }
}
