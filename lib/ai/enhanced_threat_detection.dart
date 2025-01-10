import 'dart:async';
import 'dart:math';
import 'dart:collection';
import 'package:collection/collection.dart';
import '../mesh/models/node.dart';
import '../mesh/models/node_stats.dart';
import '../security/models/threat_pattern.dart';
import '../security/models/security_event.dart';

/// Napredni sistem za detekciju pretnji koji koristi AI za analizu ponašanja mreže
class EnhancedThreatDetection {
  // Čuva istoriju ponašanja čvorova
  final Map<String, List<SecurityEvent>> _nodeHistory = {};

  // Poznati obrasci pretnji
  final List<ThreatPattern> _knownPatterns = [];

  // Statistike anomalija po čvoru
  final Map<String, NodeAnomalyStats> _anomalyStats = {};

  // Stream kontroler za emitovanje detektovanih pretnji
  final _threatController = StreamController<SecurityEvent>.broadcast();

  // Konstante
  static const int MAX_HISTORY_SIZE = 1000;
  static const Duration PATTERN_UPDATE_INTERVAL = Duration(minutes: 30);
  static const double ANOMALY_THRESHOLD = 0.85;

  Timer? _patternUpdateTimer;

  Stream<SecurityEvent> get threatStream => _threatController.stream;

  EnhancedThreatDetection() {
    _initializePatternUpdater();
  }

  void _initializePatternUpdater() {
    _patternUpdateTimer?.cancel();
    _patternUpdateTimer = Timer.periodic(PATTERN_UPDATE_INTERVAL, (_) {
      _updateThreatPatterns();
    });
  }

  /// Analizira novo ponašanje čvora
  Future<void> analyzeNodeBehavior(Node node, SecurityEvent event) async {
    // Dodaj događaj u istoriju
    final history = _nodeHistory[node.id] ?? [];
    history.add(event);

    // Ograniči veličinu istorije
    if (history.length > MAX_HISTORY_SIZE) {
      history.removeAt(0);
    }
    _nodeHistory[node.id] = history;

    // Analiziraj ponašanje
    final anomalyScore = await _calculateAnomalyScore(node.id, event);
    _updateAnomalyStats(node.id, anomalyScore);

    // Proveri poznate obrasce pretnji
    final matchedPatterns = _findMatchingPatterns(history);

    // Ako je detektovana anomalija ili poznat obrazac, emituj pretnju
    if (anomalyScore > ANOMALY_THRESHOLD || matchedPatterns.isNotEmpty) {
      final threat = SecurityEvent(
        type: SecurityEventType.potentialThreat,
        sourceId: node.id,
        timestamp: DateTime.now(),
        severity: _calculateThreatSeverity(anomalyScore, matchedPatterns),
        details: {
          'anomalyScore': anomalyScore,
          'matchedPatterns': matchedPatterns.map((p) => p.name).toList(),
          'nodeType': node.type.toString(),
          'recentEvents': history.take(5).map((e) => e.toJson()).toList(),
        },
      );

      _threatController.add(threat);
    }
  }

  /// Računa anomaly score za događaj
  Future<double> _calculateAnomalyScore(
      String nodeId, SecurityEvent event) async {
    double score = 0.0;
    final history = _nodeHistory[nodeId] ?? [];

    // Faktori za računanje anomaly score-a
    score += _calculateTimingAnomaly(history, event);
    score += _calculateBehaviorAnomaly(history, event);
    score += _calculateContextAnomaly(nodeId, event);

    return score / 3.0; // Normalizuj score
  }

  /// Računa anomaliju u vremenu događaja
  double _calculateTimingAnomaly(
      List<SecurityEvent> history, SecurityEvent event) {
    if (history.isEmpty) return 0.0;

    // Izračunaj prosečan interval između događaja
    final intervals = <int>[];
    for (var i = 1; i < history.length; i++) {
      intervals.add(
          history[i].timestamp.difference(history[i - 1].timestamp).inSeconds);
    }

    if (intervals.isEmpty) return 0.0;

    final avgInterval = intervals.average;
    final stdDev = _calculateStdDev(intervals, avgInterval);

    // Izračunaj koliko trenutni interval odstupa od proseka
    final currentInterval =
        event.timestamp.difference(history.last.timestamp).inSeconds;
    final zScore = (currentInterval - avgInterval) / (stdDev == 0 ? 1 : stdDev);

    return (zScore.abs() / 3.0).clamp(0.0, 1.0); // Normalizuj na 0-1
  }

  /// Računa anomaliju u ponašanju
  double _calculateBehaviorAnomaly(
      List<SecurityEvent> history, SecurityEvent event) {
    if (history.isEmpty) return 0.0;

    // Broj sličnih događaja u istoriji
    final similarEvents = history.where((e) => e.type == event.type).length;
    final similarity = similarEvents / history.length;

    // Ako je događaj redak, to je više sumnjivo
    return 1.0 - similarity;
  }

  /// Računa anomaliju u kontekstu
  double _calculateContextAnomaly(String nodeId, SecurityEvent event) {
    final stats = _anomalyStats[nodeId];
    if (stats == null) return 0.0;

    // Uzmi u obzir prethodne anomalije
    return stats.recentAnomalyRate;
  }

  /// Ažurira statistike anomalija za čvor
  void _updateAnomalyStats(String nodeId, double anomalyScore) {
    final stats = _anomalyStats[nodeId] ?? NodeAnomalyStats();
    stats.addScore(anomalyScore);
    _anomalyStats[nodeId] = stats;
  }

  /// Pronalazi obrasce pretnji koji se poklapaju sa istorijom
  List<ThreatPattern> _findMatchingPatterns(List<SecurityEvent> history) {
    return _knownPatterns.where((pattern) => pattern.matches(history)).toList();
  }

  /// Računa ozbiljnost pretnje
  double _calculateThreatSeverity(
      double anomalyScore, List<ThreatPattern> patterns) {
    double severity = anomalyScore;

    // Povećaj severity ako su pronađeni poznati obrasci
    if (patterns.isNotEmpty) {
      severity += patterns.map((p) => p.severity).reduce(max) * 0.5;
    }

    return severity.clamp(0.0, 1.0);
  }

  /// Ažurira poznate obrasce pretnji na osnovu novih podataka
  Future<void> _updateThreatPatterns() async {
    // Implementirati machine learning za prepoznavanje novih obrazaca
    // TODO: Dodati ML logiku
  }

  /// Računa standardnu devijaciju
  double _calculateStdDev(List<num> values, double mean) {
    if (values.isEmpty) return 0.0;
    final squares = values.map((v) => pow(v - mean, 2));
    return sqrt(squares.average);
  }

  /// Čisti resurse
  void dispose() {
    _patternUpdateTimer?.cancel();
    _threatController.close();
  }
}

/// Pomoćna klasa za praćenje statistika anomalija
class NodeAnomalyStats {
  final Queue<double> _recentScores = Queue();
  static const int MAX_RECENT_SCORES = 100;

  void addScore(double score) {
    _recentScores.add(score);
    if (_recentScores.length > MAX_RECENT_SCORES) {
      _recentScores.removeFirst();
    }
  }

  double get recentAnomalyRate {
    if (_recentScores.isEmpty) return 0.0;
    return _recentScores
            .where((s) => s > EnhancedThreatDetection.ANOMALY_THRESHOLD)
            .length /
        _recentScores.length;
  }

  void reset() {
    _recentScores.clear();
  }
}
