import 'dart:async';
import '../communication/connection_manager.dart';
import 'network_metrics_collector.dart';

/// Statistika konekcije
class ConnectionStats {
  final String nodeId;
  final ConnectionType type;
  final Duration uptime;
  final int reconnectCount;
  final double reliability;
  final double latency;
  final double packetLoss;
  final double bandwidth;
  final DateTime lastCheck;

  const ConnectionStats({
    required this.nodeId,
    required this.type,
    required this.uptime,
    required this.reconnectCount,
    required this.reliability,
    required this.latency,
    required this.packetLoss,
    required this.bandwidth,
    required this.lastCheck,
  });
}

/// Izveštaj o stanju konekcija
class ConnectionReport {
  final DateTime timestamp;
  final List<ConnectionStats> stats;
  final int totalConnections;
  final int activeConnections;
  final double averageReliability;
  final double averageLatency;
  final double totalBandwidth;

  const ConnectionReport({
    required this.timestamp,
    required this.stats,
    required this.totalConnections,
    required this.activeConnections,
    required this.averageReliability,
    required this.averageLatency,
    required this.totalBandwidth,
  });

  /// Kreira izveštaj iz liste statistika
  factory ConnectionReport.fromStats(List<ConnectionStats> stats) {
    final activeStats = stats.where((s) => s.reliability > 0).toList();

    return ConnectionReport(
      timestamp: DateTime.now(),
      stats: stats,
      totalConnections: stats.length,
      activeConnections: activeStats.length,
      averageReliability: activeStats.isEmpty
          ? 0
          : activeStats.map((s) => s.reliability).reduce((a, b) => a + b) /
              activeStats.length,
      averageLatency: activeStats.isEmpty
          ? double.infinity
          : activeStats.map((s) => s.latency).reduce((a, b) => a + b) /
              activeStats.length,
      totalBandwidth:
          activeStats.map((s) => s.bandwidth).reduce((a, b) => a + b),
    );
  }
}

/// Prati stanje konekcija i generiše izveštaje
class ConnectionMonitor {
  final ConnectionManager _connectionManager;
  final NetworkMetricsCollector _metricsCollector;

  // Statistika po čvoru
  final Map<String, ConnectionStats> _stats = {};

  // Stream controller za izveštaje
  final _reportController = StreamController<ConnectionReport>.broadcast();

  // Konstante
  static const Duration CHECK_INTERVAL = Duration(minutes: 1);
  static const Duration REPORT_INTERVAL = Duration(minutes: 5);

  Stream<ConnectionReport> get reportStream => _reportController.stream;

  ConnectionMonitor({
    required ConnectionManager connectionManager,
    required NetworkMetricsCollector metricsCollector,
  })  : _connectionManager = connectionManager,
        _metricsCollector = metricsCollector {
    // Pretplati se na promene statusa konekcija
    _connectionManager.statusStream.listen(_handleStatusChange);

    // Pokreni periodičnu proveru
    Timer.periodic(CHECK_INTERVAL, (_) => _checkConnections());

    // Pokreni periodično generisanje izveštaja
    Timer.periodic(REPORT_INTERVAL, (_) => _generateReport());
  }

  /// Obrađuje promenu statusa konekcije
  void _handleStatusChange(ConnectionInfo info) {
    final existing = _stats[info.nodeId];

    if (info.status == ConnectionStatus.connected) {
      _stats[info.nodeId] = ConnectionStats(
        nodeId: info.nodeId,
        type: info.type,
        uptime: Duration.zero,
        reconnectCount: existing?.reconnectCount ?? 0,
        reliability: 1.0,
        latency: existing?.latency ?? double.infinity,
        packetLoss: existing?.packetLoss ?? 1.0,
        bandwidth: existing?.bandwidth ?? 0.0,
        lastCheck: DateTime.now(),
      );
    } else if (info.status == ConnectionStatus.disconnected) {
      _stats[info.nodeId] = ConnectionStats(
        nodeId: info.nodeId,
        type: info.type,
        uptime: Duration.zero,
        reconnectCount: (existing?.reconnectCount ?? 0) + 1,
        reliability: 0.0,
        latency: double.infinity,
        packetLoss: 1.0,
        bandwidth: 0.0,
        lastCheck: DateTime.now(),
      );
    }
  }

  /// Proverava stanje konekcija
  Future<void> _checkConnections() async {
    final activeConnections = _connectionManager.getActiveConnections();

    for (final info in activeConnections) {
      try {
        // Prikupi metrike
        final metrics = await _metricsCollector.collectNodeMetrics(info.nodeId);

        final existing = _stats[info.nodeId];
        if (existing == null) continue;

        // Ažuriraj statistiku
        _stats[info.nodeId] = ConnectionStats(
          nodeId: info.nodeId,
          type: info.type,
          uptime:
              existing.uptime + DateTime.now().difference(existing.lastCheck),
          reconnectCount: existing.reconnectCount,
          reliability: metrics['latency'] != double.infinity ? 1.0 : 0.0,
          latency: metrics['latency'] ?? double.infinity,
          packetLoss: metrics['packetLoss'] ?? 1.0,
          bandwidth: metrics['bandwidth'] ?? 0.0,
          lastCheck: DateTime.now(),
        );
      } catch (e) {
        print('Greška pri proveri konekcije ${info.nodeId}: $e');
      }
    }
  }

  /// Generiše izveštaj o stanju konekcija
  void _generateReport() {
    final report = ConnectionReport.fromStats(_stats.values.toList());
    _reportController.add(report);
  }

  /// Vraća statistiku za čvor
  ConnectionStats? getNodeStats(String nodeId) {
    return _stats[nodeId];
  }

  /// Vraća sve statistike
  List<ConnectionStats> getAllStats() {
    return _stats.values.toList();
  }

  /// Čisti resurse
  void dispose() {
    _reportController.close();
  }
}
