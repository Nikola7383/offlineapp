class FrameMetricsService {
  final LoggerService _logger;
  final MetricsStorage _storage;

  // Performance thresholds
  static const int CRITICAL_FPS_THRESHOLD = 30;
  static const Duration JANK_THRESHOLD = Duration(milliseconds: 32); // 2 frames

  FrameMetricsService({
    required LoggerService logger,
    required MetricsStorage storage,
  })  : _logger = logger,
        _storage = storage;

  Future<void> startMonitoring({
    required Function(FrameInfo) onFrameDrop,
    required Function(JankInfo) onJank,
    required Function(FPSInfo) onLowFPS,
  }) async {
    try {
      // 1. Initialize frame callback
      await _initializeFrameCallback();

      // 2. Start metrics collection
      _startMetricsCollection(
          onFrameDrop: onFrameDrop, onJank: onJank, onLowFPS: onLowFPS);

      // 3. Setup periodic analysis
      _setupPeriodicAnalysis();
    } catch (e) {
      _logger.error('Frame metrics monitoring failed: $e');
      throw MetricsException('Failed to start frame monitoring');
    }
  }

  void _startMetricsCollection({
    required Function(FrameInfo) onFrameDrop,
    required Function(JankInfo) onJank,
    required Function(FPSInfo) onLowFPS,
  }) {
    SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      final frameTime = DateTime.now();

      // Collect frame metrics
      final metrics = _collectFrameMetrics(frameTime);

      // Analyze frame performance
      _analyzeFramePerformance(metrics,
          onFrameDrop: onFrameDrop, onJank: onJank, onLowFPS: onLowFPS);

      // Store metrics
      _storage.storeMetrics(metrics);
    });
  }

  void _analyzeFramePerformance(
    FrameMetrics metrics, {
    required Function(FrameInfo) onFrameDrop,
    required Function(JankInfo) onJank,
    required Function(FPSInfo) onLowFPS,
  }) {
    // Check for frame drops
    if (metrics.droppedFrames > 0) {
      onFrameDrop(FrameInfo(
          timestamp: metrics.timestamp,
          droppedFrames: metrics.droppedFrames,
          computation: metrics.computationTime));
    }

    // Check for jank
    if (metrics.frameDuration > JANK_THRESHOLD) {
      onJank(JankInfo(
          timestamp: metrics.timestamp,
          duration: metrics.frameDuration,
          cause: _analyzeJankCause(metrics)));
    }

    // Check FPS
    if (metrics.fps < CRITICAL_FPS_THRESHOLD) {
      onLowFPS(FPSInfo(
          timestamp: metrics.timestamp,
          fps: metrics.fps,
          trend: _analyzeFPSTrend(metrics)));
    }
  }
}
