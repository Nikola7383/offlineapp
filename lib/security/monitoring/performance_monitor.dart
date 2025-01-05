class SecurityPerformanceMonitor {
  static final SecurityPerformanceMonitor _instance =
      SecurityPerformanceMonitor._internal();

  final Map<String, List<PerformanceMetric>> _metrics = {};
  final StreamController<PerformanceAlert> _alertStream =
      StreamController.broadcast();

  factory SecurityPerformanceMonitor() {
    return _instance;
  }

  SecurityPerformanceMonitor._internal();

  void recordMetric(String operation, Duration duration) {
    final metric = PerformanceMetric(
        operation: operation, duration: duration, timestamp: DateTime.now());

    _metrics.putIfAbsent(operation, () => []).add(metric);
    _checkPerformance(metric);
  }

  void _checkPerformance(PerformanceMetric metric) {
    if (metric.duration.inMilliseconds > 1000) {
      _alertStream.add(PerformanceAlert(
          operation: metric.operation,
          duration: metric.duration,
          severity: _calculateSeverity(metric.duration)));
    }
  }

  AlertSeverity _calculateSeverity(Duration duration) {
    final ms = duration.inMilliseconds;
    if (ms > 5000) return AlertSeverity.critical;
    if (ms > 2000) return AlertSeverity.high;
    if (ms > 1000) return AlertSeverity.medium;
    return AlertSeverity.low;
  }

  List<PerformanceMetric> getMetrics(String operation) {
    return _metrics[operation] ?? [];
  }

  Stream<PerformanceAlert> get alerts => _alertStream.stream;
}

class PerformanceMetric {
  final String operation;
  final Duration duration;
  final DateTime timestamp;

  PerformanceMetric(
      {required this.operation,
      required this.duration,
      required this.timestamp});
}

class PerformanceAlert {
  final String operation;
  final Duration duration;
  final AlertSeverity severity;

  PerformanceAlert(
      {required this.operation,
      required this.duration,
      required this.severity});
}

enum AlertSeverity { low, medium, high, critical }
