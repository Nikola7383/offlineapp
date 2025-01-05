class NetworkLatencyTest extends TestCase {
  final MetricsCollector _metrics;
  static const LATENCY_THRESHOLD = Duration(milliseconds: 200);

  NetworkLatencyTest(this._metrics);

  @override
  String get name => 'Network Latency Test';

  @override
  Future<void> run() async {
    final latencies = <Duration>[];

    for (var i = 0; i < 100; i++) {
      final latency = await _measureLatency();
      latencies.add(latency);
    }

    final averageLatency = _calculateAverageLatency(latencies);
    if (averageLatency > LATENCY_THRESHOLD) {
      throw PerformanceTestException(
          'Network latency too high: ${averageLatency.inMilliseconds}ms');
    }
  }

  Future<Duration> _measureLatency() async {
    final stopwatch = Stopwatch()..start();
    // Implementacija merenja mrežne latencije
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  Duration _calculateAverageLatency(List<Duration> latencies) {
    final totalMs = latencies.fold<int>(
        0, (sum, duration) => sum + duration.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ latencies.length);
  }
}
