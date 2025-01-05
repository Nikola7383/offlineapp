class CacheEfficiencyTest extends TestCase {
  final PerformanceOptimizer _optimizer;
  final CacheMetrics _cacheMetrics;
  static const MIN_HIT_RATIO = 0.8; // 80% hit ratio
  static const TEST_KEY = 'cache_efficiency_test';

  CacheEfficiencyTest(this._optimizer, this._cacheMetrics);

  @override
  String get name => 'Cache Efficiency Test';

  @override
  Future<void> setUp() async {
    _cacheMetrics.resetMetrics();
  }

  @override
  Future<void> run() async {
    final hitRatio = await _measureCacheEfficiency();

    if (hitRatio < MIN_HIT_RATIO) {
      throw PerformanceTestException(
          'Cache hit ratio too low: ${(hitRatio * 100).toStringAsFixed(1)}%');
    }
  }

  Future<double> _measureCacheEfficiency() async {
    final testData = List.generate(1000, (i) => 'Test data $i');

    for (var i = 0; i < testData.length; i++) {
      // Ponavljamo pristup istim podacima da simuliramo realne scenarije
      final dataIndex = i % (testData.length ~/ 10);
      await _performCacheOperation(
        '$TEST_KEY:$dataIndex',
        testData[dataIndex],
      );
    }

    return _cacheMetrics.getHitRatio(TEST_KEY);
  }

  Future<bool> _performCacheOperation(String key, String value) async {
    return await _cacheMetrics.measureCacheOperation(key, value);
  }

  @override
  Future<void> tearDown() async {
    _cacheMetrics.resetMetrics();
  }
}
