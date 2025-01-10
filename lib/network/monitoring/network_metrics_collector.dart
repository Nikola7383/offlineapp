import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import '../communication/connection_manager.dart';

/// Kolektor mrežnih metrika
class NetworkMetricsCollector {
  final ConnectionManager _connectionManager;

  // Keš za metrike
  final Map<String, Map<String, double>> _metricsCache = {};

  // Konstante
  static const Duration CACHE_DURATION = Duration(minutes: 1);
  static const int PING_SAMPLE_SIZE = 5;
  static const Duration PING_INTERVAL = Duration(milliseconds: 100);

  NetworkMetricsCollector({
    required ConnectionManager connectionManager,
  }) : _connectionManager = connectionManager;

  /// Prikuplja metrike za čvor
  Future<Map<String, double>> collectNodeMetrics(String nodeId) async {
    // Proveri keš
    final cachedMetrics = _metricsCache[nodeId];
    if (cachedMetrics != null) {
      final timestamp = cachedMetrics['timestamp'] ?? 0;
      if (DateTime.now().millisecondsSinceEpoch - timestamp <
          CACHE_DURATION.inMilliseconds) {
        return Map<String, double>.from(cachedMetrics)..remove('timestamp');
      }
    }

    try {
      // Izmeri latenciju
      final latency = await _measureLatency(nodeId);

      // Izmeri gubitak paketa
      final packetLoss = await _measurePacketLoss(nodeId);

      // Izmeri propusni opseg
      final bandwidth = await _measureBandwidth(nodeId);

      // Ažuriraj keš
      final metrics = {
        'latency': latency,
        'packetLoss': packetLoss,
        'bandwidth': bandwidth,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toDouble(),
      };

      _metricsCache[nodeId] = metrics;

      return Map<String, double>.from(metrics)..remove('timestamp');
    } catch (e) {
      print('Greška pri prikupljanju metrika za čvor $nodeId: $e');
      return {
        'latency': double.infinity,
        'packetLoss': 1.0,
        'bandwidth': 0.0,
      };
    }
  }

  /// Meri latenciju slanjem ping paketa
  Future<double> _measureLatency(String nodeId) async {
    final latencies = <double>[];

    for (var i = 0; i < PING_SAMPLE_SIZE; i++) {
      final startTime = DateTime.now().millisecondsSinceEpoch;

      final success = await _connectionManager.sendPing(nodeId);
      if (!success) {
        latencies.add(double.infinity);
        continue;
      }

      final endTime = DateTime.now().millisecondsSinceEpoch;
      latencies.add((endTime - startTime).toDouble());

      await Future.delayed(PING_INTERVAL);
    }

    // Izračunaj prosečnu latenciju (isključi beskonačne vrednosti)
    final validLatencies =
        latencies.where((l) => l != double.infinity).toList();
    if (validLatencies.isEmpty) return double.infinity;

    return validLatencies.reduce((a, b) => a + b) / validLatencies.length;
  }

  /// Meri gubitak paketa
  Future<double> _measurePacketLoss(String nodeId) async {
    var successfulPings = 0;

    for (var i = 0; i < PING_SAMPLE_SIZE; i++) {
      final success = await _connectionManager.sendPing(nodeId);
      if (success) successfulPings++;

      await Future.delayed(PING_INTERVAL);
    }

    return 1.0 - (successfulPings / PING_SAMPLE_SIZE);
  }

  /// Meri propusni opseg
  Future<double> _measureBandwidth(String nodeId) async {
    try {
      // Generiši test podatke (1KB)
      final testData = List.generate(1024, (i) => math.Random().nextInt(256));

      final startTime = DateTime.now().millisecondsSinceEpoch;

      // Pošalji podatke
      final success = await _connectionManager.sendData(
        nodeId,
        Uint8List.fromList(testData),
        timeout: Duration(seconds: 5),
      );

      if (!success) return 0.0;

      final endTime = DateTime.now().millisecondsSinceEpoch;
      final duration = endTime - startTime;

      // Izračunaj propusni opseg u KB/s
      return (1.0 / duration) * 1000;
    } catch (e) {
      print('Greška pri merenju propusnog opsega: $e');
      return 0.0;
    }
  }

  /// Čisti keš za čvor
  void clearNodeCache(String nodeId) {
    _metricsCache.remove(nodeId);
  }

  /// Čisti ceo keš
  void clearCache() {
    _metricsCache.clear();
  }
}
