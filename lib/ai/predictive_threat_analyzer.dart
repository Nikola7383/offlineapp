import 'dart:async';
import '../mesh/models/node_stats.dart';
import '../mesh/models/connection_info.dart';
import '../security/security_event.dart';

/// Tipovi pretnji koje sistem može da detektuje
enum ThreatType {
  nodeCompromise,
  networkPartition,
  dataManipulation,
  resourceExhaustion,
  communicationInterference,
  patternAnomaly
}

/// Nivo ozbiljnosti pretnje
enum ThreatSeverity { critical, high, medium, low, info }

/// Detalji o detektovanoj pretnji
class ThreatInfo {
  final ThreatType type;
  final ThreatSeverity severity;
  final String nodeId;
  final DateTime detectedAt;
  final Map<String, dynamic> metadata;
  final double confidence;

  const ThreatInfo({
    required this.type,
    required this.severity,
    required this.nodeId,
    required this.detectedAt,
    required this.metadata,
    required this.confidence,
  });

  @override
  String toString() {
    return 'ThreatInfo('
        'type: $type, '
        'severity: $severity, '
        'nodeId: $nodeId, '
        'confidence: ${confidence.toStringAsFixed(2)})';
  }
}

/// Analizira mrežu i predviđa potencijalne pretnje
class PredictiveThreatAnalyzer {
  // Istorija pretnji po čvoru
  final Map<String, List<ThreatInfo>> _threatHistory = {};

  // Statistike čvorova kroz vreme
  final Map<String, List<NodeStats>> _nodeStatsHistory = {};

  // Stream controller za pretnje
  final _threatController = StreamController<ThreatInfo>.broadcast();

  // Konstante
  static const int MAX_HISTORY_SIZE = 1000;
  static const Duration ANALYSIS_INTERVAL = Duration(minutes: 5);
  static const double CONFIDENCE_THRESHOLD = 0.75;

  Timer? _analysisTimer;
  bool _isAnalyzing = false;

  /// Pokreće analizator
  void start() {
    if (_analysisTimer != null) return;
    _analysisTimer =
        Timer.periodic(ANALYSIS_INTERVAL, (_) => _analyzeNetwork());
  }

  /// Dodaje nove statistike čvora u istoriju
  void addNodeStats(String nodeId, NodeStats stats) {
    final history = _nodeStatsHistory.putIfAbsent(nodeId, () => []);
    history.add(stats);

    // Održavaj maksimalnu veličinu istorije
    if (history.length > MAX_HISTORY_SIZE) {
      history.removeAt(0);
    }
  }

  /// Analizira mrežu i detektuje potencijalne pretnje
  Future<void> _analyzeNetwork() async {
    if (_isAnalyzing) return;
    _isAnalyzing = true;

    try {
      for (final entry in _nodeStatsHistory.entries) {
        final nodeId = entry.key;
        final history = entry.value;

        if (history.length < 2) continue;

        // Analiziraj trendove
        await _analyzeNodeTrends(nodeId, history);

        // Analiziraj anomalije
        await _analyzeNodeAnomalies(nodeId, history);

        // Analiziraj obrasce
        await _analyzeNodePatterns(nodeId, history);
      }
    } finally {
      _isAnalyzing = false;
    }
  }

  /// Analizira trendove u performansama čvora
  Future<void> _analyzeNodeTrends(
      String nodeId, List<NodeStats> history) async {
    // Analiziraj trend pouzdanosti
    final reliabilityTrend = _calculateTrend(
      history.map((s) => s.reliability).toList(),
    );

    if (reliabilityTrend < -0.1) {
      _reportThreat(ThreatInfo(
        type: ThreatType.nodeCompromise,
        severity: ThreatSeverity.high,
        nodeId: nodeId,
        detectedAt: DateTime.now(),
        metadata: {'reliabilityTrend': reliabilityTrend},
        confidence: _calculateConfidence(reliabilityTrend.abs()),
      ));
    }

    // Analiziraj trend grešaka
    final errorTrend = _calculateTrend(
      history.map((s) => s.errorRate).toList(),
    );

    if (errorTrend > 0.1) {
      _reportThreat(ThreatInfo(
        type: ThreatType.communicationInterference,
        severity: ThreatSeverity.medium,
        nodeId: nodeId,
        detectedAt: DateTime.now(),
        metadata: {'errorTrend': errorTrend},
        confidence: _calculateConfidence(errorTrend),
      ));
    }
  }

  /// Analizira anomalije u ponašanju čvora
  Future<void> _analyzeNodeAnomalies(
      String nodeId, List<NodeStats> history) async {
    final currentStats = history.last;
    final previousStats = history[history.length - 2];

    // Detektuj nagle promene u broju konekcija
    final connectionDelta = currentStats.activeConnections.length -
        previousStats.activeConnections.length;

    if (connectionDelta.abs() > 5) {
      _reportThreat(ThreatInfo(
        type: ThreatType.networkPartition,
        severity: ThreatSeverity.high,
        nodeId: nodeId,
        detectedAt: DateTime.now(),
        metadata: {'connectionDelta': connectionDelta},
        confidence: _calculateConfidence(connectionDelta.abs() / 10),
      ));
    }

    // Detektuj anomalije u potrošnji resursa
    if (currentStats.batteryLevel < previousStats.batteryLevel * 0.8) {
      _reportThreat(ThreatInfo(
        type: ThreatType.resourceExhaustion,
        severity: ThreatSeverity.medium,
        nodeId: nodeId,
        detectedAt: DateTime.now(),
        metadata: {
          'batteryDrain': previousStats.batteryLevel - currentStats.batteryLevel
        },
        confidence: _calculateConfidence(
            (previousStats.batteryLevel - currentStats.batteryLevel) /
                previousStats.batteryLevel),
      ));
    }
  }

  /// Analizira obrasce u ponašanju čvora
  Future<void> _analyzeNodePatterns(
      String nodeId, List<NodeStats> history) async {
    // Analiziraj obrasce u konekcijama
    final connectionPatterns = _analyzeConnectionPatterns(
      history.expand((s) => s.activeConnections).toList(),
    );

    if (connectionPatterns.isNotEmpty) {
      _reportThreat(ThreatInfo(
        type: ThreatType.patternAnomaly,
        severity: ThreatSeverity.low,
        nodeId: nodeId,
        detectedAt: DateTime.now(),
        metadata: {'patterns': connectionPatterns},
        confidence: _calculateConfidence(connectionPatterns.length / 10),
      ));
    }
  }

  /// Računa trend u nizu vrednosti
  double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;

    var sum = 0.0;
    for (var i = 1; i < values.length; i++) {
      sum += (values[i] - values[i - 1]);
    }

    return sum / (values.length - 1);
  }

  /// Analizira obrasce u konekcijama
  List<Map<String, dynamic>> _analyzeConnectionPatterns(
      List<ConnectionInfo> connections) {
    final patterns = <Map<String, dynamic>>[];

    // Grupiši konekcije po čvoru
    final connectionsByNode = <String, List<ConnectionInfo>>{};
    for (final conn in connections) {
      connectionsByNode.putIfAbsent(conn.targetNodeId, () => []).add(conn);
    }

    // Traži obrasce u svakoj grupi
    for (final entry in connectionsByNode.entries) {
      final nodeConnections = entry.value;

      // Traži ponavljajuće konekcije
      if (nodeConnections.length > 10) {
        patterns.add({
          'type': 'highFrequencyConnections',
          'nodeId': entry.key,
          'count': nodeConnections.length,
        });
      }

      // Traži obrasce u vremenu uspostavljanja konekcija
      final timings = _analyzeConnectionTimings(nodeConnections);
      if (timings != null) {
        patterns.add(timings);
      }
    }

    return patterns;
  }

  /// Analizira vremenske obrasce u konekcijama
  Map<String, dynamic>? _analyzeConnectionTimings(
      List<ConnectionInfo> connections) {
    if (connections.length < 3) return null;

    final intervals = <Duration>[];
    for (var i = 1; i < connections.length; i++) {
      intervals.add(connections[i].establishedAt.difference(
            connections[i - 1].establishedAt,
          ));
    }

    // Traži regularne intervale
    final avgInterval = intervals.fold<Duration>(
          Duration.zero,
          (sum, interval) => sum + interval,
        ) ~/
        intervals.length;

    var regularCount = 0;
    for (final interval in intervals) {
      if ((interval - avgInterval).abs() < const Duration(seconds: 5)) {
        regularCount++;
      }
    }

    if (regularCount > intervals.length * 0.7) {
      return {
        'type': 'regularIntervals',
        'avgInterval': avgInterval.inSeconds,
        'confidence': regularCount / intervals.length,
      };
    }

    return null;
  }

  /// Računa pouzdanost predikcije
  double _calculateConfidence(double factor) {
    return (factor * 0.8 + 0.2).clamp(0.0, 1.0);
  }

  /// Prijavljuje detektovanu pretnju
  void _reportThreat(ThreatInfo threat) {
    if (threat.confidence < CONFIDENCE_THRESHOLD) return;

    final history = _threatHistory.putIfAbsent(threat.nodeId, () => []);
    history.add(threat);

    // Održavaj maksimalnu veličinu istorije
    if (history.length > MAX_HISTORY_SIZE) {
      history.removeAt(0);
    }

    _threatController.add(threat);
  }

  /// Stream detektovanih pretnji
  Stream<ThreatInfo> get threatStream => _threatController.stream;

  /// Vraća istoriju pretnji za čvor
  List<ThreatInfo> getThreatHistory(String nodeId) {
    return List.unmodifiable(_threatHistory[nodeId] ?? []);
  }

  /// Zaustavlja analizator
  void dispose() {
    _analysisTimer?.cancel();
    _threatController.close();
  }
}
