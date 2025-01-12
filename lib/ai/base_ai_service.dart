import 'dart:async';
import 'package:meta/meta.dart';
import 'ai_service_interface.dart';
import '../enums/ai_enums.dart';

abstract class BaseAIService implements AIService {
  late AIServiceConfiguration _configuration;
  late AIServiceStatus _status;
  late AIServiceMetrics _metrics;

  final _statusController = StreamController<AIServiceStatus>.broadcast();
  final _metricsController = StreamController<AIServiceMetrics>.broadcast();

  DateTime _startTime = DateTime.now();
  bool _isInitialized = false;

  @override
  AIServiceConfiguration get configuration => _configuration;

  @override
  AIServiceStatus get status => _status;

  @override
  AIServiceMetrics get metrics => _metrics;

  @override
  Stream<AIServiceStatus> get statusStream => _statusController.stream;

  @override
  Stream<AIServiceMetrics> get metricsStream => _metricsController.stream;

  @override
  Future<void> initialize(AIServiceConfiguration config) async {
    if (_isInitialized) {
      throw StateError('Service already initialized');
    }

    _configuration = config;
    _startTime = DateTime.now();

    _status = AIServiceStatus(
      state: AIProcessingState.initializing,
      confidenceLevel: AIConfidenceLevel.low,
      statusMessage: 'Initializing service',
      lastUpdated: DateTime.now(),
      isHealthy: true,
    );

    _metrics = AIServiceMetrics(
      accuracy: 0.0,
      performance: 0.0,
      resourceUsage: 0.0,
      processedEvents: 0,
      uptime: Duration.zero,
    );

    _isInitialized = true;
    await onInitialize();

    updateStatus(
      state: AIProcessingState.idle,
      confidenceLevel: AIConfidenceLevel.medium,
      statusMessage: 'Service initialized successfully',
    );
  }

  @override
  Future<void> start() async {
    _checkInitialized();
    updateStatus(
      state: AIProcessingState.processing,
      statusMessage: 'Service started',
    );
    await onStart();
  }

  @override
  Future<void> stop() async {
    _checkInitialized();
    updateStatus(
      state: AIProcessingState.idle,
      statusMessage: 'Service stopped',
    );
    await onStop();
  }

  @override
  Future<void> pause() async {
    _checkInitialized();
    updateStatus(
      state: AIProcessingState.idle,
      statusMessage: 'Service paused',
    );
    await onPause();
  }

  @override
  Future<void> resume() async {
    _checkInitialized();
    updateStatus(
      state: AIProcessingState.processing,
      statusMessage: 'Service resumed',
    );
    await onResume();
  }

  @override
  Future<void> updateConfiguration(AIServiceConfiguration newConfig) async {
    _checkInitialized();
    _configuration = newConfig;
    await onConfigurationUpdate(newConfig);
  }

  @override
  Future<void> handleError(dynamic error) async {
    updateStatus(
      state: AIProcessingState.error,
      confidenceLevel: AIConfidenceLevel.low,
      statusMessage: 'Error occurred: ${error.toString()}',
      isHealthy: false,
    );
    await onError(error);
  }

  @override
  Future<void> cleanup() async {
    await onCleanup();
    await _statusController.close();
    await _metricsController.close();
  }

  void _checkInitialized() {
    if (!_isInitialized) {
      throw StateError('Service not initialized');
    }
  }

  @protected
  void updateStatus({
    AIProcessingState? state,
    AIConfidenceLevel? confidenceLevel,
    String? statusMessage,
    bool? isHealthy,
    List<String>? activeProcesses,
  }) {
    _status = AIServiceStatus(
      state: state ?? _status.state,
      confidenceLevel: confidenceLevel ?? _status.confidenceLevel,
      statusMessage: statusMessage ?? _status.statusMessage,
      lastUpdated: DateTime.now(),
      isHealthy: isHealthy ?? _status.isHealthy,
      activeProcesses: activeProcesses ?? _status.activeProcesses,
    );
    _statusController.add(_status);
  }

  @protected
  void updateMetrics({
    double? accuracy,
    double? performance,
    double? resourceUsage,
    int? processedEvents,
    Map<String, dynamic>? customMetrics,
  }) {
    _metrics = AIServiceMetrics(
      accuracy: accuracy ?? _metrics.accuracy,
      performance: performance ?? _metrics.performance,
      resourceUsage: resourceUsage ?? _metrics.resourceUsage,
      processedEvents: processedEvents ?? _metrics.processedEvents,
      uptime: DateTime.now().difference(_startTime),
      customMetrics: customMetrics ?? _metrics.customMetrics,
    );
    _metricsController.add(_metrics);
  }

  // Template methods for subclasses to override
  @protected
  Future<void> onInitialize() async {}

  @protected
  Future<void> onStart() async {}

  @protected
  Future<void> onStop() async {}

  @protected
  Future<void> onPause() async {}

  @protected
  Future<void> onResume() async {}

  @protected
  Future<void> onConfigurationUpdate(AIServiceConfiguration newConfig) async {}

  @protected
  Future<void> onError(dynamic error) async {}

  @protected
  Future<void> onCleanup() async {}
}
