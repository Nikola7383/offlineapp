import 'dart:async';
import '../../mesh/models/node.dart';
import '../../security/models/security_event.dart';
import 'network_metrics_collector.dart';

/// Prati stanje mreže i detektuje anomalije
class NetworkMonitor {
  final NetworkMetricsCollector _metricsCollector;

  // Stream controlleri za različite tipove događaja
  final _healthController = StreamController<NetworkHealthEvent>.broadcast();
  final _anomalyController = StreamController<NetworkAnomalyEvent>.broadcast();
  final _metricsController = StreamController<NetworkMetrics>.broadcast();

  // Trenutno stanje mreže
  final Map<String, NodeHealth> _nodeHealth = {};
  final Map<String, List<NetworkMetric>> _nodeMetrics = {};

  // Istorija anomalija
  final List<NetworkAnomalyEvent> _anomalyHistory = [];

  // Konstante
  static const Duration METRICS_INTERVAL = Duration(seconds: 30);
  static const Duration HEALTH_CHECK_INTERVAL = Duration(seconds: 15);
  static const int MAX_HISTORY_SIZE = 1000;

  // Pragovi za detekciju anomalija
  static const double LATENCY_THRESHOLD_MS = 500.0;
  static const double PACKET_LOSS_THRESHOLD = 0.1;
  static const double BANDWIDTH_THRESHOLD_KBPS = 100.0;

  Stream<NetworkHealthEvent> get healthStream => _healthController.stream;
  Stream<NetworkAnomalyEvent> get anomalyStream => _anomalyController.stream;
  Stream<NetworkMetrics> get metricsStream => _metricsController.stream;

  NetworkMonitor({
    NetworkMetricsCollector? metricsCollector,
  }) : _metricsCollector = metricsCollector ?? NetworkMetricsCollector() {
    _initializeMonitoring();
  }

  /// Inicijalizuje monitoring
  void _initializeMonitoring() {
    // Pokreni periodično prikupljanje metrika
    Timer.periodic(METRICS_INTERVAL, (_) => _collectMetrics());

    // Pokreni periodičnu proveru zdravlja
    Timer.periodic(HEALTH_CHECK_INTERVAL, (_) => _checkNetworkHealth());
  }

  /// Registruje novi čvor za praćenje
  void registerNode(String nodeId) {
    _nodeHealth[nodeId] = NodeHealth(
      nodeId: nodeId,
      status: NodeStatus.unknown,
      lastSeen: DateTime.now(),
      metrics: {},
    );
  }

  /// Uklanja čvor iz praćenja
  void unregisterNode(String nodeId) {
    _nodeHealth.remove(nodeId);
    _nodeMetrics.remove(nodeId);
  }

  /// Ažurira metriku za čvor
  void updateMetric(String nodeId, String metricName, double value) {
    final metrics = _nodeMetrics[nodeId] ??= [];

    metrics.add(NetworkMetric(
      timestamp: DateTime.now(),
      name: metricName,
      value: value,
    ));

    // Održavaj maksimalnu veličinu istorije
    while (metrics.length > MAX_HISTORY_SIZE) {
      metrics.removeAt(0);
    }

    // Proveri da li nova metrika predstavlja anomaliju
    _checkForAnomalies(nodeId, metricName, value);
  }

  /// Prikuplja metrike za sve čvorove
  Future<void> _collectMetrics() async {
    final timestamp = DateTime.now();
    final metrics = <String, Map<String, double>>{};

    // Prikupi metrike za svaki čvor
    for (var nodeId in _nodeHealth.keys) {
      metrics[nodeId] = await _collectNodeMetrics(nodeId);
    }

    // Kreiraj i emituj događaj sa metrikama
    final networkMetrics = NetworkMetrics(
      timestamp: timestamp,
      metrics: metrics,
    );

    _metricsController.add(networkMetrics);
  }

  /// Prikuplja metrike za pojedinačni čvor
  Future<Map<String, double>> _collectNodeMetrics(String nodeId) async {
    try {
      return await _metricsCollector.collectNodeMetrics(nodeId);
    } catch (e) {
      print('Greška pri prikupljanju metrika za čvor $nodeId: $e');
      return {
        'latency': double.infinity,
        'packetLoss': 1.0,
        'bandwidth': 0.0,
      };
    }
  }

  /// Proverava zdravlje mreže
  Future<void> _checkNetworkHealth() async {
    final timestamp = DateTime.now();

    for (var entry in _nodeHealth.entries) {
      final nodeId = entry.key;
      final health = entry.value;

      // Proveri dostupnost čvora
      final isResponding = await _checkNodeAvailability(nodeId);

      // Ažuriraj status čvora
      final newStatus =
          isResponding ? NodeStatus.healthy : NodeStatus.unhealthy;
      if (newStatus != health.status) {
        final newHealth = NodeHealth(
          nodeId: nodeId,
          status: newStatus,
          lastSeen: isResponding ? timestamp : health.lastSeen,
          metrics: health.metrics,
        );

        _nodeHealth[nodeId] = newHealth;

        // Emituj događaj promene zdravlja
        _healthController.add(NetworkHealthEvent(
          nodeId: nodeId,
          oldStatus: health.status,
          newStatus: newStatus,
          timestamp: timestamp,
        ));
      }
    }
  }

  /// Proverava dostupnost čvora
  Future<bool> _checkNodeAvailability(String nodeId) async {
    try {
      return await _metricsCollector.checkNodeAvailability(nodeId);
    } catch (e) {
      print('Greška pri proveri dostupnosti čvora $nodeId: $e');
      return false;
    }
  }

  /// Proverava da li metrika predstavlja anomaliju
  void _checkForAnomalies(String nodeId, String metricName, double value) {
    bool isAnomaly = false;
    String reason = '';

    switch (metricName) {
      case 'latency':
        if (value > LATENCY_THRESHOLD_MS) {
          isAnomaly = true;
          reason = 'Visoka latencija';
        }
        break;
      case 'packetLoss':
        if (value > PACKET_LOSS_THRESHOLD) {
          isAnomaly = true;
          reason = 'Veliki gubitak paketa';
        }
        break;
      case 'bandwidth':
        if (value < BANDWIDTH_THRESHOLD_KBPS) {
          isAnomaly = true;
          reason = 'Nizak propusni opseg';
        }
        break;
    }

    if (isAnomaly) {
      final event = NetworkAnomalyEvent(
        nodeId: nodeId,
        metricName: metricName,
        value: value,
        reason: reason,
        timestamp: DateTime.now(),
        severity: _calculateAnomalySeverity(metricName, value),
      );

      _anomalyHistory.add(event);
      _anomalyController.add(event);

      // Održavaj maksimalnu veličinu istorije
      while (_anomalyHistory.length > MAX_HISTORY_SIZE) {
        _anomalyHistory.removeAt(0);
      }
    }
  }

  /// Računa ozbiljnost anomalije
  AnomalySeverity _calculateAnomalySeverity(String metricName, double value) {
    switch (metricName) {
      case 'latency':
        if (value > LATENCY_THRESHOLD_MS * 2) return AnomalySeverity.high;
        return AnomalySeverity.medium;
      case 'packetLoss':
        if (value > PACKET_LOSS_THRESHOLD * 2) return AnomalySeverity.high;
        return AnomalySeverity.medium;
      case 'bandwidth':
        if (value < BANDWIDTH_THRESHOLD_KBPS / 2) return AnomalySeverity.high;
        return AnomalySeverity.medium;
      default:
        return AnomalySeverity.low;
    }
  }

  /// Vraća trenutno zdravlje čvora
  NodeHealth? getNodeHealth(String nodeId) => _nodeHealth[nodeId];

  /// Vraća istoriju metrika za čvor
  List<NetworkMetric> getNodeMetrics(String nodeId) =>
      _nodeMetrics[nodeId]?.toList() ?? [];

  /// Vraća nedavne anomalije za čvor
  List<NetworkAnomalyEvent> getNodeAnomalies(
    String nodeId, {
    Duration? period,
  }) {
    final cutoff =
        period != null ? DateTime.now().subtract(period) : DateTime(0);

    return _anomalyHistory
        .where((e) => e.nodeId == nodeId && e.timestamp.isAfter(cutoff))
        .toList();
  }

  /// Čisti resurse
  void dispose() {
    _healthController.close();
    _anomalyController.close();
    _metricsController.close();
  }
}

/// Status čvora u mreži
enum NodeStatus {
  unknown,
  healthy,
  unhealthy,
}

/// Ozbiljnost anomalije
enum AnomalySeverity {
  low,
  medium,
  high,
}

/// Zdravlje čvora
class NodeHealth {
  final String nodeId;
  final NodeStatus status;
  final DateTime lastSeen;
  final Map<String, double> metrics;

  const NodeHealth({
    required this.nodeId,
    required this.status,
    required this.lastSeen,
    required this.metrics,
  });
}

/// Metrika mreže
class NetworkMetric {
  final DateTime timestamp;
  final String name;
  final double value;

  const NetworkMetric({
    required this.timestamp,
    required this.name,
    required this.value,
  });
}

/// Događaj promene zdravlja mreže
class NetworkHealthEvent {
  final String nodeId;
  final NodeStatus oldStatus;
  final NodeStatus newStatus;
  final DateTime timestamp;

  const NetworkHealthEvent({
    required this.nodeId,
    required this.oldStatus,
    required this.newStatus,
    required this.timestamp,
  });
}

/// Događaj anomalije u mreži
class NetworkAnomalyEvent {
  final String nodeId;
  final String metricName;
  final double value;
  final String reason;
  final DateTime timestamp;
  final AnomalySeverity severity;

  const NetworkAnomalyEvent({
    required this.nodeId,
    required this.metricName,
    required this.value,
    required this.reason,
    required this.timestamp,
    required this.severity,
  });
}

/// Metrike mreže
class NetworkMetrics {
  final DateTime timestamp;
  final Map<String, Map<String, double>> metrics;

  const NetworkMetrics({
    required this.timestamp,
    required this.metrics,
  });
}
