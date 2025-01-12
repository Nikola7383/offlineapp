import 'dart:async';
import 'dart:math' as math;
import 'base_ai_service.dart';
import 'ai_service_interface.dart';
import '../enums/ai_enums.dart';

class ThreatSignature {
  final String id;
  final String pattern;
  final double severity;
  final Map<String, dynamic> attributes;
  final DateTime created;

  const ThreatSignature({
    required this.id,
    required this.pattern,
    required this.severity,
    required this.attributes,
    required this.created,
  });
}

class ThreatIndicator {
  final String type;
  final double confidence;
  final Map<String, dynamic> metadata;
  final DateTime detected;

  const ThreatIndicator({
    required this.type,
    required this.confidence,
    required this.metadata,
    required this.detected,
  });
}

class EnhancedThreatDetection extends BaseAIService {
  final List<ThreatSignature> _signatures = [];
  final Map<String, List<ThreatIndicator>> _indicators = {};
  final Map<String, double> _threatLevels = {};
  Timer? _analysisTimer;

  static const int _maxIndicatorsPerType = 1000;
  static const Duration _analysisInterval = Duration(minutes: 2);

  @override
  Future<void> processData(dynamic input) async {
    if (input is! Map<String, dynamic>) {
      throw ArgumentError('Input must be a Map<String, dynamic>');
    }

    final indicators = await _extractIndicators(input);
    for (final indicator in indicators) {
      _addIndicator(indicator);
    }

    await _analyzeIndicators(indicators);

    updateMetrics(
      processedEvents: _getTotalIndicators(),
      accuracy: _calculateDetectionAccuracy(),
      performance: _calculatePerformance(),
    );
  }

  @override
  Future<Map<String, dynamic>> getAnalysis() async {
    return {
      'activeThreatLevels': Map<String, double>.from(_threatLevels),
      'indicatorTypes': _getIndicatorTypeSummary(),
      'recentDetections': _getRecentDetections(),
      'signatureCount': _signatures.length,
      'analysisTimestamp': DateTime.now().toIso8601String(),
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
          'Training detection model with ${trainingData.length} samples',
    );

    // Extract signatures from training data
    final newSignatures = await _extractSignatures(trainingData);
    _signatures.addAll(newSignatures);

    // Train on each sample
    for (final sample in trainingData) {
      final indicators = await _extractIndicators(sample);
      await _analyzeIndicators(indicators, isTraining: true);
    }

    updateStatus(
      state: AIProcessingState.idle,
      confidenceLevel: AIConfidenceLevel.high,
      statusMessage:
          'Detection model trained with ${newSignatures.length} new signatures',
    );
  }

  @override
  Future<void> optimize() async {
    updateStatus(
      state: AIProcessingState.adapting,
      statusMessage: 'Optimizing threat detection patterns',
    );

    // Remove outdated signatures
    _removeOutdatedSignatures();

    // Consolidate similar patterns
    await _consolidatePatterns();

    // Update detection thresholds
    _updateDetectionThresholds();

    updateStatus(
      state: AIProcessingState.idle,
      statusMessage: 'Detection patterns optimized',
    );
  }

  @override
  Future<void> onStart() async {
    _analysisTimer = Timer.periodic(
      _analysisInterval,
      (_) => _performPeriodicAnalysis(),
    );
  }

  @override
  Future<void> onStop() async {
    _analysisTimer?.cancel();
  }

  @override
  Future<void> onCleanup() async {
    _signatures.clear();
    _indicators.clear();
    _threatLevels.clear();
    _analysisTimer?.cancel();
  }

  void _addIndicator(ThreatIndicator indicator) {
    final indicators = _indicators.putIfAbsent(indicator.type, () => []);
    indicators.add(indicator);

    // Maintain max size per type
    if (indicators.length > _maxIndicatorsPerType) {
      indicators.removeAt(0);
    }
  }

  Future<List<ThreatIndicator>> _extractIndicators(
      Map<String, dynamic> data) async {
    final indicators = <ThreatIndicator>[];
    final timestamp = DateTime.now();

    // Network anomaly detection
    if (data.containsKey('networkStats')) {
      final networkStats = data['networkStats'] as Map<String, dynamic>;
      indicators.addAll(_detectNetworkAnomalies(networkStats, timestamp));
    }

    // Behavioral analysis
    if (data.containsKey('userActivity')) {
      final activity = data['userActivity'] as Map<String, dynamic>;
      indicators.addAll(_analyzeBehavior(activity, timestamp));
    }

    // Pattern matching
    if (data.containsKey('events')) {
      final events = data['events'] as List<dynamic>;
      indicators.addAll(
          _matchPatterns(events.cast<Map<String, dynamic>>(), timestamp));
    }

    return indicators;
  }

  List<ThreatIndicator> _detectNetworkAnomalies(
    Map<String, dynamic> networkStats,
    DateTime timestamp,
  ) {
    final indicators = <ThreatIndicator>[];

    // Check for unusual traffic patterns
    if (networkStats.containsKey('bytesPerSecond')) {
      final bps = networkStats['bytesPerSecond'] as num;
      if (bps > 1000000) {
        // 1 MB/s threshold
        indicators.add(ThreatIndicator(
          type: 'high_network_usage',
          confidence: _calculateConfidence(bps / 2000000), // Scale to 0-1
          metadata: {'bytesPerSecond': bps},
          detected: timestamp,
        ));
      }
    }

    // Check for connection spikes
    if (networkStats.containsKey('connectionCount')) {
      final connections = networkStats['connectionCount'] as int;
      if (connections > 100) {
        indicators.add(ThreatIndicator(
          type: 'connection_spike',
          confidence: _calculateConfidence(connections / 200),
          metadata: {'connectionCount': connections},
          detected: timestamp,
        ));
      }
    }

    return indicators;
  }

  List<ThreatIndicator> _analyzeBehavior(
    Map<String, dynamic> activity,
    DateTime timestamp,
  ) {
    final indicators = <ThreatIndicator>[];

    // Check for rapid resource access
    if (activity.containsKey('resourceAccesses')) {
      final accesses = activity['resourceAccesses'] as int;
      if (accesses > 50) {
        indicators.add(ThreatIndicator(
          type: 'rapid_resource_access',
          confidence: _calculateConfidence(accesses / 100),
          metadata: {'accessCount': accesses},
          detected: timestamp,
        ));
      }
    }

    // Check for unusual access patterns
    if (activity.containsKey('accessPattern')) {
      final pattern = activity['accessPattern'] as String;
      final unusualScore = _calculatePatternUnusualness(pattern);
      if (unusualScore > 0.7) {
        indicators.add(ThreatIndicator(
          type: 'unusual_access_pattern',
          confidence: unusualScore,
          metadata: {'pattern': pattern},
          detected: timestamp,
        ));
      }
    }

    return indicators;
  }

  List<ThreatIndicator> _matchPatterns(
    List<Map<String, dynamic>> events,
    DateTime timestamp,
  ) {
    final indicators = <ThreatIndicator>[];

    for (final event in events) {
      for (final signature in _signatures) {
        if (_matchesSignature(event, signature)) {
          indicators.add(ThreatIndicator(
            type: 'signature_match',
            confidence: signature.severity,
            metadata: {
              'signatureId': signature.id,
              'event': event,
            },
            detected: timestamp,
          ));
        }
      }
    }

    return indicators;
  }

  Future<void> _analyzeIndicators(
    List<ThreatIndicator> indicators, {
    bool isTraining = false,
  }) async {
    if (indicators.isEmpty) return;

    // Group indicators by type
    final groupedIndicators = <String, List<ThreatIndicator>>{};
    for (final indicator in indicators) {
      groupedIndicators.putIfAbsent(indicator.type, () => []).add(indicator);
    }

    // Analyze each group
    for (final entry in groupedIndicators.entries) {
      final type = entry.key;
      final typeIndicators = entry.value;

      // Calculate aggregate threat level
      final threatLevel = _calculateThreatLevel(typeIndicators);
      _threatLevels[type] = threatLevel;

      if (!isTraining && threatLevel > 0.7) {
        updateStatus(
          state: AIProcessingState.analyzing,
          confidenceLevel: _determineConfidenceLevel(threatLevel),
          statusMessage:
              'High threat level detected: $type (${(threatLevel * 100).toStringAsFixed(1)}%)',
        );
      }
    }
  }

  double _calculateThreatLevel(List<ThreatIndicator> indicators) {
    if (indicators.isEmpty) return 0.0;

    // Weight recent indicators more heavily
    double weightedSum = 0.0;
    double weightSum = 0.0;
    final now = DateTime.now();

    for (final indicator in indicators) {
      final age = now.difference(indicator.detected).inMinutes;
      final weight = math.exp(-age / 60); // Exponential decay
      weightedSum += indicator.confidence * weight;
      weightSum += weight;
    }

    return (weightedSum / weightSum).clamp(0.0, 1.0);
  }

  Future<List<ThreatSignature>> _extractSignatures(
    List<Map<String, dynamic>> trainingData,
  ) async {
    final signatures = <ThreatSignature>[];
    final timestamp = DateTime.now();

    for (final data in trainingData) {
      if (data.containsKey('signature')) {
        final sig = data['signature'] as Map<String, dynamic>;
        signatures.add(ThreatSignature(
          id: sig['id'] as String,
          pattern: sig['pattern'] as String,
          severity: sig['severity'] as double,
          attributes: sig['attributes'] as Map<String, dynamic>,
          created: timestamp,
        ));
      }
    }

    return signatures;
  }

  void _removeOutdatedSignatures() {
    final now = DateTime.now();
    _signatures.removeWhere((sig) => now.difference(sig.created).inDays > 30);
  }

  Future<void> _consolidatePatterns() async {
    // Implement pattern consolidation logic
    await Future.delayed(const Duration(seconds: 1));
  }

  void _updateDetectionThresholds() {
    // Implement threshold update logic
  }

  bool _matchesSignature(
      Map<String, dynamic> event, ThreatSignature signature) {
    // Implement signature matching logic
    return false; // Placeholder
  }

  double _calculatePatternUnusualness(String pattern) {
    // Implement pattern analysis logic
    return 0.5; // Placeholder
  }

  double _calculateConfidence(double value) {
    return value.clamp(0.0, 1.0);
  }

  AIConfidenceLevel _determineConfidenceLevel(double threatLevel) {
    if (threatLevel >= 0.9) return AIConfidenceLevel.veryHigh;
    if (threatLevel >= 0.7) return AIConfidenceLevel.high;
    if (threatLevel >= 0.5) return AIConfidenceLevel.medium;
    if (threatLevel >= 0.3) return AIConfidenceLevel.low;
    return AIConfidenceLevel.veryLow;
  }

  Map<String, int> _getIndicatorTypeSummary() {
    final summary = <String, int>{};
    for (final entry in _indicators.entries) {
      summary[entry.key] = entry.value.length;
    }
    return summary;
  }

  List<Map<String, dynamic>> _getRecentDetections() {
    final now = DateTime.now();
    final recentDetections = <Map<String, dynamic>>[];

    for (final entry in _indicators.entries) {
      for (final indicator in entry.value) {
        if (now.difference(indicator.detected).inMinutes <= 30) {
          recentDetections.add({
            'type': indicator.type,
            'confidence': indicator.confidence,
            'metadata': indicator.metadata,
            'detected': indicator.detected.toIso8601String(),
          });
        }
      }
    }

    return recentDetections;
  }

  int _getTotalIndicators() {
    return _indicators.values
        .fold(0, (sum, indicators) => sum + indicators.length);
  }

  double _calculateDetectionAccuracy() {
    // Implement accuracy calculation logic
    return 0.9; // Placeholder
  }

  double _calculatePerformance() {
    // Implement performance calculation logic
    return 0.95; // Placeholder
  }

  Future<void> _performPeriodicAnalysis() async {
    updateStatus(
      state: AIProcessingState.analyzing,
      statusMessage: 'Performing periodic threat analysis',
    );

    final analysis = await getAnalysis();
    final threatTypes = analysis['activeThreatLevels'] as Map<String, double>;

    final highThreats = threatTypes.entries
        .where((e) => e.value > 0.7)
        .map((e) => e.key)
        .toList();

    updateStatus(
      state: AIProcessingState.idle,
      statusMessage: highThreats.isEmpty
          ? 'No high threats detected'
          : 'High threats detected: ${highThreats.join(", ")}',
    );
  }

  @override
  Future<void> validate(dynamic validationData) async {
    if (validationData is! List<Map<String, dynamic>>) {
      throw ArgumentError('Validation data must be a List of Maps');
    }

    updateStatus(
      state: AIProcessingState.analyzing,
      statusMessage:
          'Validating threat detection with ${validationData.length} samples',
    );

    double totalAccuracy = 0;
    int validSamples = 0;

    for (final sample in validationData) {
      try {
        final indicators = await _extractIndicators(sample);
        if (indicators.isEmpty) continue;

        // Proveri da li uzorak sadrži očekivane pretnje
        final expectedThreats = sample['expectedThreats'] as List<dynamic>?;
        if (expectedThreats == null) continue;

        // Izračunaj tačnost detekcije
        final detectedThreats = indicators.map((i) => i.type).toSet();
        final expectedThreatSet = expectedThreats.toSet();

        // Izračunaj true positives, false positives i false negatives
        final truePositives =
            detectedThreats.intersection(expectedThreatSet).length;
        final falsePositives =
            detectedThreats.difference(expectedThreatSet).length;
        final falseNegatives =
            expectedThreatSet.difference(detectedThreats).length;

        // Izračunaj F1 score
        final precision = truePositives / (truePositives + falsePositives);
        final recall = truePositives / (truePositives + falseNegatives);
        final f1Score = 2 * (precision * recall) / (precision + recall);

        if (!f1Score.isNaN) {
          totalAccuracy += f1Score;
          validSamples++;
        }

        // Analiziraj indikatore
        await _analyzeIndicators(indicators, isTraining: false);
      } catch (e) {
        // Preskoči nevažeće uzorke
        continue;
      }
    }

    final averageAccuracy =
        validSamples > 0 ? totalAccuracy / validSamples : 0.0;
    updateMetrics(accuracy: averageAccuracy);

    updateStatus(
      state: AIProcessingState.idle,
      statusMessage:
          'Validation completed with ${(averageAccuracy * 100).toStringAsFixed(2)}% accuracy',
      confidenceLevel: _determineAccuracyConfidence(averageAccuracy),
    );
  }

  AIConfidenceLevel _determineAccuracyConfidence(double accuracy) {
    if (accuracy >= 0.9) return AIConfidenceLevel.veryHigh;
    if (accuracy >= 0.7) return AIConfidenceLevel.high;
    if (accuracy >= 0.5) return AIConfidenceLevel.medium;
    if (accuracy >= 0.3) return AIConfidenceLevel.low;
    return AIConfidenceLevel.veryLow;
  }
}
