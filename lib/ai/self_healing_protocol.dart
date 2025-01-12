import 'dart:async';
import 'base_ai_service.dart';
import 'ai_service_interface.dart';
import '../enums/ai_enums.dart';

class SystemHealth {
  final double systemLoad;
  final double memoryUsage;
  final double networkLatency;
  final int errorCount;
  final Map<String, dynamic> metrics;

  const SystemHealth({
    required this.systemLoad,
    required this.memoryUsage,
    required this.networkLatency,
    required this.errorCount,
    this.metrics = const {},
  });
}

class HealingAction {
  final String actionId;
  final String description;
  final DateTime timestamp;
  final Duration estimatedDuration;
  final Map<String, dynamic> parameters;

  const HealingAction({
    required this.actionId,
    required this.description,
    required this.timestamp,
    required this.estimatedDuration,
    this.parameters = const {},
  });
}

class SelfHealingProtocol extends BaseAIService {
  final List<SystemHealth> _healthHistory = [];
  final List<HealingAction> _actionHistory = [];
  final Map<String, int> _issueFrequency = {};
  Timer? _monitoringTimer;

  static const int _maxHistorySize = 1000;
  static const Duration _monitoringInterval = Duration(minutes: 1);

  @override
  Future<void> processData(dynamic input) async {
    if (input is! SystemHealth) {
      throw ArgumentError('Input must be a SystemHealth object');
    }

    _healthHistory.add(input);
    if (_healthHistory.length > _maxHistorySize) {
      _healthHistory.removeAt(0);
    }

    await _analyzeHealth(input);
    updateMetrics(
      accuracy: _calculateHealingAccuracy(),
      performance: _calculatePerformance(),
      resourceUsage: input.systemLoad,
      processedEvents: _healthHistory.length,
    );
  }

  @override
  Future<Map<String, dynamic>> getAnalysis() async {
    return {
      'currentHealth': _healthHistory.isNotEmpty ? _healthHistory.last : null,
      'healingActions': _actionHistory.length,
      'issueFrequency': Map<String, int>.from(_issueFrequency),
      'systemStatus': _determineSystemStatus(),
      'recommendations': await _generateRecommendations(),
    };
  }

  @override
  Future<void> train(dynamic trainingData) async {
    if (trainingData is! List<Map<String, dynamic>>) {
      throw ArgumentError('Training data must be a List of Maps');
    }

    updateStatus(
      state: AIProcessingState.learning,
      statusMessage:
          'Training healing protocols with ${trainingData.length} samples',
    );

    for (final sample in trainingData) {
      final health = SystemHealth(
        systemLoad: sample['systemLoad'] as double,
        memoryUsage: sample['memoryUsage'] as double,
        networkLatency: sample['networkLatency'] as double,
        errorCount: sample['errorCount'] as int,
        metrics: sample['metrics'] as Map<String, dynamic>,
      );

      await _analyzeHealth(health, isTraining: true);
    }

    updateStatus(
      state: AIProcessingState.idle,
      confidenceLevel: AIConfidenceLevel.high,
      statusMessage: 'Healing protocols trained successfully',
    );
  }

  @override
  Future<void> optimize() async {
    updateStatus(
      state: AIProcessingState.adapting,
      statusMessage: 'Optimizing healing strategies',
    );

    // Analyze healing action effectiveness
    final effectiveActions = _analyzeActionEffectiveness();

    // Update healing strategies based on effectiveness
    await _updateHealingStrategies(effectiveActions);

    updateStatus(
      state: AIProcessingState.idle,
      statusMessage: 'Healing strategies optimized',
    );
  }

  @override
  Future<void> onStart() async {
    _monitoringTimer = Timer.periodic(
      _monitoringInterval,
      (_) => _performHealthCheck(),
    );
  }

  @override
  Future<void> onStop() async {
    _monitoringTimer?.cancel();
  }

  @override
  Future<void> onCleanup() async {
    _healthHistory.clear();
    _actionHistory.clear();
    _issueFrequency.clear();
    _monitoringTimer?.cancel();
  }

  Future<void> _analyzeHealth(
    SystemHealth health, {
    bool isTraining = false,
  }) async {
    final issues = _detectIssues(health);

    for (final issue in issues) {
      _issueFrequency[issue] = (_issueFrequency[issue] ?? 0) + 1;

      if (!isTraining) {
        final action = await _determineHealingAction(issue, health);
        if (action != null) {
          _actionHistory.add(action);
          await _executeHealingAction(action);
        }
      }
    }

    if (!isTraining && issues.isNotEmpty) {
      updateStatus(
        state: AIProcessingState.processing,
        confidenceLevel: _determineConfidenceLevel(health),
        statusMessage: 'Healing actions initiated for ${issues.length} issues',
      );
    }
  }

  List<String> _detectIssues(SystemHealth health) {
    final issues = <String>[];

    if (health.systemLoad > 0.9) {
      issues.add('high_system_load');
    }
    if (health.memoryUsage > 0.85) {
      issues.add('high_memory_usage');
    }
    if (health.networkLatency > 1000) {
      issues.add('high_network_latency');
    }
    if (health.errorCount > 10) {
      issues.add('high_error_rate');
    }

    // Check custom metrics
    for (final entry in health.metrics.entries) {
      if (entry.value is num && entry.value > 0.8) {
        issues.add('high_${entry.key}');
      }
    }

    return issues;
  }

  Future<HealingAction?> _determineHealingAction(
    String issue,
    SystemHealth health,
  ) async {
    // Define healing actions based on issue type
    switch (issue) {
      case 'high_system_load':
        return HealingAction(
          actionId: 'reduce_load_${DateTime.now().millisecondsSinceEpoch}',
          description: 'Initiating load balancing protocol',
          timestamp: DateTime.now(),
          estimatedDuration: const Duration(minutes: 5),
          parameters: {'targetLoad': 0.7},
        );

      case 'high_memory_usage':
        return HealingAction(
          actionId: 'optimize_memory_${DateTime.now().millisecondsSinceEpoch}',
          description: 'Initiating memory optimization',
          timestamp: DateTime.now(),
          estimatedDuration: const Duration(minutes: 3),
          parameters: {'targetUsage': 0.75},
        );

      case 'high_network_latency':
        return HealingAction(
          actionId: 'optimize_network_${DateTime.now().millisecondsSinceEpoch}',
          description: 'Optimizing network connections',
          timestamp: DateTime.now(),
          estimatedDuration: const Duration(minutes: 2),
          parameters: {'targetLatency': 500},
        );

      case 'high_error_rate':
        return HealingAction(
          actionId: 'reduce_errors_${DateTime.now().millisecondsSinceEpoch}',
          description: 'Implementing error reduction protocol',
          timestamp: DateTime.now(),
          estimatedDuration: const Duration(minutes: 4),
          parameters: {'targetErrorRate': 5},
        );

      default:
        if (issue.startsWith('high_')) {
          return HealingAction(
            actionId: '${issue}_${DateTime.now().millisecondsSinceEpoch}',
            description: 'Optimizing ${issue.substring(5)}',
            timestamp: DateTime.now(),
            estimatedDuration: const Duration(minutes: 3),
            parameters: {'targetValue': 0.7},
          );
        }
        return null;
    }
  }

  Future<void> _executeHealingAction(HealingAction action) async {
    updateStatus(
      state: AIProcessingState.processing,
      statusMessage: 'Executing healing action: ${action.description}',
    );

    // Simulate action execution
    await Future.delayed(const Duration(seconds: 2));

    updateStatus(
      state: AIProcessingState.idle,
      statusMessage: 'Healing action completed: ${action.description}',
    );
  }

  Map<String, double> _analyzeActionEffectiveness() {
    final effectiveness = <String, double>{};

    for (var i = 0; i < _actionHistory.length; i++) {
      final action = _actionHistory[i];
      if (i + 1 < _healthHistory.length) {
        final beforeHealth = _healthHistory[i];
        final afterHealth = _healthHistory[i + 1];

        final improvement = _calculateImprovement(beforeHealth, afterHealth);
        effectiveness[action.actionId] = improvement;
      }
    }

    return effectiveness;
  }

  Future<void> _updateHealingStrategies(
      Map<String, double> effectiveness) async {
    // Implement strategy updates based on effectiveness
    await Future.delayed(const Duration(seconds: 1));
  }

  double _calculateImprovement(SystemHealth before, SystemHealth after) {
    double improvement = 0.0;

    improvement += (before.systemLoad - after.systemLoad).clamp(0.0, 1.0);
    improvement += (before.memoryUsage - after.memoryUsage).clamp(0.0, 1.0);
    improvement +=
        ((before.networkLatency - after.networkLatency) / 1000).clamp(0.0, 1.0);
    improvement +=
        ((before.errorCount - after.errorCount) / 10).clamp(0.0, 1.0);

    return (improvement / 4).clamp(0.0, 1.0);
  }

  AIConfidenceLevel _determineConfidenceLevel(SystemHealth health) {
    final issues = _detectIssues(health);
    if (issues.isEmpty) return AIConfidenceLevel.veryHigh;
    if (issues.length <= 2) return AIConfidenceLevel.high;
    if (issues.length <= 4) return AIConfidenceLevel.medium;
    if (issues.length <= 6) return AIConfidenceLevel.low;
    return AIConfidenceLevel.veryLow;
  }

  String _determineSystemStatus() {
    if (_healthHistory.isEmpty) return 'unknown';

    final currentHealth = _healthHistory.last;
    final issues = _detectIssues(currentHealth);

    if (issues.isEmpty) return 'healthy';
    if (issues.length <= 2) return 'stable';
    if (issues.length <= 4) return 'degraded';
    return 'critical';
  }

  Future<List<String>> _generateRecommendations() async {
    final recommendations = <String>[];
    final status = _determineSystemStatus();

    switch (status) {
      case 'healthy':
        recommendations.add('Continue monitoring system health');
        recommendations.add('Consider optimizing resource allocation');
        break;

      case 'stable':
        recommendations.add('Monitor identified issues closely');
        recommendations.add('Implement preventive measures');
        break;

      case 'degraded':
        recommendations
            .add('Immediate attention required for system stability');
        recommendations.add('Scale resources to handle load');
        recommendations.add('Review and optimize system configuration');
        break;

      case 'critical':
        recommendations.add('Urgent intervention required');
        recommendations.add('Consider failing over to backup systems');
        recommendations.add('Initiate emergency response protocol');
        recommendations.add('Notify system administrators');
        break;

      default:
        recommendations.add('Initialize system health monitoring');
    }

    return recommendations;
  }

  Future<void> _performHealthCheck() async {
    if (_healthHistory.isEmpty) return;

    final currentHealth = _healthHistory.last;
    final status = _determineSystemStatus();

    updateStatus(
      state: AIProcessingState.analyzing,
      confidenceLevel: _determineConfidenceLevel(currentHealth),
      statusMessage: 'System Status: $status',
    );
  }

  double _calculateHealingAccuracy() {
    if (_actionHistory.isEmpty) return 0.0;

    final effectiveness = _analyzeActionEffectiveness();
    if (effectiveness.isEmpty) return 0.0;

    return effectiveness.values.reduce((a, b) => a + b) / effectiveness.length;
  }

  double _calculatePerformance() {
    if (_healthHistory.isEmpty) return 1.0;

    final currentHealth = _healthHistory.last;
    return (1.0 - currentHealth.systemLoad).clamp(0.0, 1.0);
  }

  @override
  Future<void> validate(dynamic validationData) async {
    if (validationData is! List<Map<String, dynamic>>) {
      throw ArgumentError('Validation data must be a List of Maps');
    }

    updateStatus(
      state: AIProcessingState.analyzing,
      statusMessage:
          'Validating healing protocols with ${validationData.length} samples',
    );

    double totalEffectiveness = 0;
    int validSamples = 0;

    for (final sample in validationData) {
      try {
        final health = SystemHealth(
          systemLoad: sample['systemLoad'] as double,
          memoryUsage: sample['memoryUsage'] as double,
          networkLatency: sample['networkLatency'] as double,
          errorCount: sample['errorCount'] as int,
          metrics: sample['metrics'] as Map<String, dynamic>,
        );

        final beforeIssues = _detectIssues(health);
        await _analyzeHealth(health, isTraining: false);

        if (beforeIssues.isNotEmpty) {
          final afterHealth = SystemHealth(
            systemLoad:
                sample['afterSystemLoad'] as double? ?? health.systemLoad,
            memoryUsage:
                sample['afterMemoryUsage'] as double? ?? health.memoryUsage,
            networkLatency: sample['afterNetworkLatency'] as double? ??
                health.networkLatency,
            errorCount: sample['afterErrorCount'] as int? ?? health.errorCount,
            metrics: sample['afterMetrics'] as Map<String, dynamic>? ??
                health.metrics,
          );

          final improvement = _calculateImprovement(health, afterHealth);
          totalEffectiveness += improvement;
          validSamples++;
        }
      } catch (e) {
        // Preskačemo nevažeće uzorke
        continue;
      }
    }

    final averageEffectiveness =
        validSamples > 0 ? totalEffectiveness / validSamples : 0.0;
    updateMetrics(accuracy: averageEffectiveness);

    final lastHealth = _healthHistory.isNotEmpty ? _healthHistory.last : null;
    updateStatus(
      state: AIProcessingState.idle,
      statusMessage:
          'Validation completed with ${(averageEffectiveness * 100).toStringAsFixed(2)}% effectiveness',
      confidenceLevel: lastHealth != null
          ? _determineConfidenceLevel(lastHealth)
          : _determineEffectivenessConfidence(averageEffectiveness),
    );
  }

  AIConfidenceLevel _determineEffectivenessConfidence(double effectiveness) {
    if (effectiveness >= 0.9) return AIConfidenceLevel.veryHigh;
    if (effectiveness >= 0.7) return AIConfidenceLevel.high;
    if (effectiveness >= 0.5) return AIConfidenceLevel.medium;
    if (effectiveness >= 0.3) return AIConfidenceLevel.low;
    return AIConfidenceLevel.veryLow;
  }
}
