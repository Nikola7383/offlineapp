import '../enums/ai_enums.dart';

class AIServiceConfiguration {
  final AIServiceType serviceType;
  final AIOperatingMode operatingMode;
  final AILearningStrategy learningStrategy;
  final AIOptimizationTarget optimizationTarget;
  final Map<String, dynamic> additionalParams;

  const AIServiceConfiguration({
    required this.serviceType,
    required this.operatingMode,
    required this.learningStrategy,
    required this.optimizationTarget,
    this.additionalParams = const {},
  });
}

class AIServiceMetrics {
  final double accuracy;
  final double performance;
  final double resourceUsage;
  final int processedEvents;
  final Duration uptime;
  final Map<String, dynamic> customMetrics;

  const AIServiceMetrics({
    required this.accuracy,
    required this.performance,
    required this.resourceUsage,
    required this.processedEvents,
    required this.uptime,
    this.customMetrics = const {},
  });
}

class AIServiceStatus {
  final AIProcessingState state;
  final AIConfidenceLevel confidenceLevel;
  final String statusMessage;
  final DateTime lastUpdated;
  final bool isHealthy;
  final List<String> activeProcesses;

  const AIServiceStatus({
    required this.state,
    required this.confidenceLevel,
    required this.statusMessage,
    required this.lastUpdated,
    required this.isHealthy,
    this.activeProcesses = const [],
  });
}

abstract class AIService {
  AIServiceConfiguration get configuration;
  AIServiceStatus get status;
  AIServiceMetrics get metrics;

  Future<void> initialize(AIServiceConfiguration config);
  Future<void> start();
  Future<void> stop();
  Future<void> pause();
  Future<void> resume();

  Future<void> updateConfiguration(AIServiceConfiguration newConfig);
  Future<void> processData(dynamic input);
  Future<Map<String, dynamic>> getAnalysis();

  Future<void> train(dynamic trainingData);
  Future<void> validate(dynamic validationData);
  Future<void> optimize();

  Stream<AIServiceStatus> get statusStream;
  Stream<AIServiceMetrics> get metricsStream;

  Future<void> handleError(dynamic error);
  Future<void> cleanup();
}
