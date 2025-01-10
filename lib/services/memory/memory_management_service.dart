class MemoryManagementService {
  final LoggerService _logger;
  final PerformanceService _performance;

  // Memory tracking
  final Map<String, MemoryMetrics> _memoryUsage = {};
  final List<WeakReference> _objectReferences = [];

  // Thresholds (u MB)
  static const int WARNING_THRESHOLD = 150;
  static const int CRITICAL_THRESHOLD = 200;

  MemoryManagementService({
    required LoggerService logger,
    required PerformanceService performance,
  })  : _logger = logger,
        _performance = performance {
    _initializeMemoryMonitoring();
  }

  void _initializeMemoryMonitoring() {
    // Monitor svakih 30 sekundi
    Timer.periodic(Duration(seconds: 30), (_) => _checkMemoryUsage());

    // Garbage collection suggestion timer
    Timer.periodic(Duration(minutes: 5), (_) => _suggestGarbageCollection());
  }

  Future<void> _checkMemoryUsage() async {
    try {
      final currentUsage = await _getCurrentMemoryUsage();
      _updateMemoryMetrics(currentUsage);

      if (currentUsage > WARNING_THRESHOLD) {
        await _handleHighMemoryUsage(currentUsage);
      }

      if (currentUsage > CRITICAL_THRESHOLD) {
        await _handleCriticalMemoryUsage();
      }

      // Proveri memory leaks
      _detectPotentialLeaks();
    } catch (e) {
      _logger.error('Memory check failed: $e');
    }
  }

  void trackObject(String key, Object object) {
    _objectReferences.add(WeakReference(object));

    if (!_memoryUsage.containsKey(key)) {
      _memoryUsage[key] = MemoryMetrics(key);
    }

    _memoryUsage[key]!.addReference();
  }

  void releaseObject(String key) {
    if (_memoryUsage.containsKey(key)) {
      _memoryUsage[key]!.removeReference();
    }
  }

  Future<void> _handleHighMemoryUsage(int currentUsage) async {
    _logger.warning('High memory usage detected: ${currentUsage}MB');

    // 1. Clear non-essential caches
    await _performance.clearNonEssentialCaches();

    // 2. Suggest garbage collection
    _suggestGarbageCollection();

    // 3. Notify performance service
    await _performance.handleHighMemoryUsage();
  }

  Future<void> _handleCriticalMemoryUsage() async {
    _logger.critical('Critical memory usage detected!');

    // 1. Clear all caches
    await _performance.clearAllCaches();

    // 2. Force garbage collection suggestion
    _suggestGarbageCollection(force: true);

    // 3. Disable non-critical features
    await _disableNonCriticalFeatures();

    // 4. Notify error handling service
    ErrorHandlingService.instance.handleCriticalMemory();
  }

  void _detectPotentialLeaks() {
    for (final metrics in _memoryUsage.values) {
      if (metrics.isPotentialLeak) {
        _logger.warning('Potential memory leak detected: ${metrics.key}');
        _handlePotentialLeak(metrics);
      }
    }

    // Clean up dead references
    _objectReferences.removeWhere((ref) => ref.target == null);
  }

  void _handlePotentialLeak(MemoryMetrics metrics) {
    // Log detailed metrics
    _logger.info('Memory metrics for ${metrics.key}:');
    _logger.info('- Active references: ${metrics.activeReferences}');
    _logger.info('- Peak usage: ${metrics.peakUsage}MB');
    _logger.info('- Age: ${metrics.age.inMinutes} minutes');

    // Attempt cleanup
    if (metrics.shouldForceCleanup) {
      metrics.forceCleanup();
      _suggestGarbageCollection();
    }
  }
}
