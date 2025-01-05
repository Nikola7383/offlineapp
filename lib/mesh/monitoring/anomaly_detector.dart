import 'dart:math';
import 'package:ml_algo/ml_algo.dart';
import '../security/security_types.dart';

class AnomalyDetector {
  static const int HISTORY_SIZE = 1000;
  static const double ANOMALY_THRESHOLD = 0.95;

  final List<_NetworkMetrics> _history = [];
  late final KMeans _kmeans;
  late final IsolationForest _isolationForest;

  bool _isInitialized = false;
  DateTime? _lastTraining;

  AnomalyDetector() {
    _initializeModels();
  }

  Future<void> _initializeModels() async {
    _kmeans = KMeans(
      numberOfClusters: 3,
      distance: EuclideanDistance(),
      randomSeed: 42,
    );

    _isolationForest = IsolationForest(
      numberOfTrees: 100,
      maxSamples: 256,
      randomSeed: 42,
    );

    _isInitialized = true;
  }

  /// Analizira metrike i vraća skor anomalije
  Future<double> analyzeMetrics(_NetworkMetrics metrics) async {
    if (!_isInitialized) await _initializeModels();

    _history.add(metrics);
    if (_history.length > HISTORY_SIZE) {
      _history.removeAt(0);
    }

    // Retrain models periodically
    if (_shouldRetrain()) {
      await _retrainModels();
    }

    // Get anomaly scores from both models
    final kmeansScore = await _getKMeansScore(metrics);
    final isolationScore = await _getIsolationScore(metrics);

    // Combine scores (ensemble approach)
    return (kmeansScore + isolationScore) / 2;
  }

  /// Vraća true ako je detektovana anomalija
  bool isAnomaly(double score) {
    return score > ANOMALY_THRESHOLD;
  }

  Future<double> _getKMeansScore(_NetworkMetrics metrics) async {
    final vector = metrics.toVector();
    final clusters = await _kmeans.predict([vector]);
    final centroid = _kmeans.centroids[clusters[0]];

    // Calculate distance to nearest centroid
    return _calculateDistance(vector, centroid);
  }

  Future<double> _getIsolationScore(_NetworkMetrics metrics) async {
    final vector = metrics.toVector();
    return _isolationForest.getAnomalyScore(vector);
  }

  bool _shouldRetrain() {
    if (_lastTraining == null) return true;
    return DateTime.now().difference(_lastTraining!) > Duration(hours: 1);
  }

  Future<void> _retrainModels() async {
    if (_history.length < 10) return; // Need minimum samples

    final trainingData = _history.map((m) => m.toVector()).toList();

    await _kmeans.fit(trainingData);
    await _isolationForest.fit(trainingData);

    _lastTraining = DateTime.now();
  }

  double _calculateDistance(List<double> v1, List<double> v2) {
    var sum = 0.0;
    for (var i = 0; i < v1.length; i++) {
      sum += pow(v1[i] - v2[i], 2);
    }
    return sqrt(sum);
  }
}

class _NetworkMetrics {
  final int messageCount;
  final double avgMessageSize;
  final double messageFrequency;
  final int uniqueNodes;
  final double networkDensity;
  final int failedAttempts;
  final double batteryLevel;
  final double signalStrength;
  final int honeypotHits;

  _NetworkMetrics({
    required this.messageCount,
    required this.avgMessageSize,
    required this.messageFrequency,
    required this.uniqueNodes,
    required this.networkDensity,
    required this.failedAttempts,
    required this.batteryLevel,
    required this.signalStrength,
    required this.honeypotHits,
  });

  List<double> toVector() => [
        messageCount.toDouble(),
        avgMessageSize,
        messageFrequency,
        uniqueNodes.toDouble(),
        networkDensity,
        failedAttempts.toDouble(),
        batteryLevel,
        signalStrength,
        honeypotHits.toDouble(),
      ];
}
