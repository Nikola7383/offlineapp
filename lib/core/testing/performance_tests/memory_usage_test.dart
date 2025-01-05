class MemoryUsageTest extends TestCase {
  final MetricsCollector _metrics;
  final SystemMetrics _systemMetrics;
  static const MEMORY_THRESHOLD = 512 * 1024 * 1024; // 512MB

  MemoryUsageTest(this._metrics, this._systemMetrics);

  @override
  String get name => 'Memory Usage Test';

  @override
  Future<void> run() async {
    final initialMemory = await _getCurrentMemoryUsage();

    await _performMemoryIntensiveOperations();

    final peakMemory = await _getCurrentMemoryUsage();
    final memoryIncrease = peakMemory - initialMemory;

    _metrics.track(
      'memory_usage_increase',
      memoryIncrease.toDouble(),
      tags: {'test': name},
    );

    if (memoryIncrease > MEMORY_THRESHOLD) {
      throw PerformanceTestException(
          'Memory usage increase too high: ${memoryIncrease ~/ 1024 / 1024}MB');
    }
  }

  Future<int> _getCurrentMemoryUsage() async {
    return await _systemMetrics.getCurrentMemoryUsage();
  }

  Future<void> _performMemoryIntensiveOperations() async {
    // Simuliramo opterećenje memorije
    final largeList = List.generate(
      1000000,
      (i) => 'Test string $i' * 100,
    );

    // Izvršavamo neke operacije nad podacima
    await Future.delayed(Duration(seconds: 1));

    // Čistimo podatke
    largeList.clear();
  }
}
