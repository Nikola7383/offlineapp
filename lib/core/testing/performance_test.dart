@isTest
class PerformanceTest {
  final LoggerService _logger;
  final Stopwatch _stopwatch = Stopwatch();
  final Map<String, List<Duration>> _measurements = {};

  PerformanceTest(this._logger);

  Future<T> measureOperation<T>(
    String name,
    Future<T> Function() operation,
  ) async {
    _stopwatch.start();
    try {
      final result = await operation();
      _stopwatch.stop();

      _measurements.putIfAbsent(name, () => []).add(_stopwatch.elapsed);

      return result;
    } finally {
      _stopwatch.reset();
    }
  }

  void generateReport() {
    final report = StringBuffer();
    report.writeln('Performance Test Report:');
    report.writeln('========================');

    for (final entry in _measurements.entries) {
      final durations = entry.value;
      final avg = durations.reduce((a, b) => a + b) ~/ durations.length;
      final max = durations.reduce(max);
      final min = durations.reduce(min);

      report.writeln('Operation: ${entry.key}');
      report.writeln('  Average: ${avg.inMilliseconds}ms');
      report.writeln('  Max: ${max.inMilliseconds}ms');
      report.writeln('  Min: ${min.inMilliseconds}ms');
      report.writeln('  Samples: ${durations.length}');
      report.writeln();
    }

    _logger.info(report.toString());
  }
}
