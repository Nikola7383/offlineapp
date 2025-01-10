import 'dart:async';
import '../communication/connection_manager.dart';
import '../monitoring/connection_monitor.dart';
import '../monitoring/connection_health_check.dart';
import '../monitoring/network_metrics_collector.dart';

/// Tip dijagnostičke informacije
enum DiagnosticType {
  info,
  warning,
  error,
  critical,
}

/// Dijagnostička informacija
class DiagnosticInfo {
  final String nodeId;
  final DiagnosticType type;
  final String message;
  final Map<String, dynamic> details;
  final DateTime timestamp;

  const DiagnosticInfo({
    required this.nodeId,
    required this.type,
    required this.message,
    required this.details,
    required this.timestamp,
  });
}

/// Dijagnostički izveštaj
class DiagnosticReport {
  final DateTime timestamp;
  final List<DiagnosticInfo> diagnostics;
  final Map<String, dynamic> networkStats;
  final Map<String, dynamic> healthStats;
  final List<String> recommendations;

  const DiagnosticReport({
    required this.timestamp,
    required this.diagnostics,
    required this.networkStats,
    required this.healthStats,
    required this.recommendations,
  });
}

/// Pruža dijagnostičke informacije o mreži
class NetworkDiagnostics {
  final ConnectionManager _connectionManager;
  final ConnectionMonitor _connectionMonitor;
  final ConnectionHealthCheck _healthCheck;
  final NetworkMetricsCollector _metricsCollector;

  // Stream controller za dijagnostičke informacije
  final _diagnosticController = StreamController<DiagnosticInfo>.broadcast();

  // Konstante
  static const Duration DIAGNOSTIC_INTERVAL = Duration(minutes: 15);

  Stream<DiagnosticInfo> get diagnosticStream => _diagnosticController.stream;

  NetworkDiagnostics({
    required ConnectionManager connectionManager,
    required ConnectionMonitor connectionMonitor,
    required ConnectionHealthCheck healthCheck,
    required NetworkMetricsCollector metricsCollector,
  })  : _connectionManager = connectionManager,
        _connectionMonitor = connectionMonitor,
        _healthCheck = healthCheck,
        _metricsCollector = metricsCollector {
    // Pretplati se na promene statusa konekcija
    _connectionManager.statusStream.listen(_handleStatusChange);

    // Pretplati se na rezultate provere zdravlja
    _healthCheck.resultStream.listen(_handleHealthCheck);

    // Pokreni periodičnu dijagnostiku
    Timer.periodic(DIAGNOSTIC_INTERVAL, (_) => runDiagnostics());
  }

  /// Obrađuje promenu statusa konekcije
  void _handleStatusChange(ConnectionInfo info) {
    if (info.status == ConnectionStatus.error) {
      _diagnosticController.add(DiagnosticInfo(
        nodeId: info.nodeId,
        type: DiagnosticType.error,
        message: 'Greška pri povezivanju sa čvorom',
        details: {
          'status': info.status.toString(),
          'type': info.type.toString(),
          'error': info.errorMessage ?? 'Nepoznata greška',
        },
        timestamp: DateTime.now(),
      ));
    }
  }

  /// Obrađuje rezultat provere zdravlja
  void _handleHealthCheck(HealthCheckResult result) {
    if (result.status == HealthStatus.critical ||
        result.status == HealthStatus.failed) {
      _diagnosticController.add(DiagnosticInfo(
        nodeId: result.nodeId,
        type: DiagnosticType.critical,
        message: 'Kritičan status zdravlja konekcije',
        details: {
          'status': result.status.toString(),
          'issues': result.issues,
          'recommendations': result.recommendations,
        },
        timestamp: DateTime.now(),
      ));
    }
  }

  /// Pokreće dijagnostiku mreže
  Future<DiagnosticReport> runDiagnostics() async {
    final diagnostics = <DiagnosticInfo>[];
    final recommendations = <String>[];

    try {
      // Prikupi informacije o aktivnim konekcijama
      final activeConnections = _connectionManager.getActiveConnections();
      final networkStats = await _collectNetworkStats(activeConnections);
      final healthStats = await _collectHealthStats(activeConnections);

      // Analiziraj mrežne performanse
      await _analyzePeerConnectivity(activeConnections, diagnostics);
      await _analyzeNetworkTopology(activeConnections, diagnostics);
      await _analyzePerformancePatterns(activeConnections, diagnostics);

      // Generiši preporuke
      recommendations.addAll(
        _generateNetworkRecommendations(networkStats, healthStats),
      );

      return DiagnosticReport(
        timestamp: DateTime.now(),
        diagnostics: diagnostics,
        networkStats: networkStats,
        healthStats: healthStats,
        recommendations: recommendations,
      );
    } catch (e) {
      print('Greška pri pokretanju dijagnostike: $e');
      diagnostics.add(DiagnosticInfo(
        nodeId: 'system',
        type: DiagnosticType.error,
        message: 'Greška pri pokretanju dijagnostike',
        details: {'error': e.toString()},
        timestamp: DateTime.now(),
      ));

      return DiagnosticReport(
        timestamp: DateTime.now(),
        diagnostics: diagnostics,
        networkStats: {},
        healthStats: {},
        recommendations: ['Pokušajte ponovo pokrenuti dijagnostiku'],
      );
    }
  }

  /// Prikuplja statistiku o mreži
  Future<Map<String, dynamic>> _collectNetworkStats(
    List<ConnectionInfo> connections,
  ) async {
    final stats = <String, dynamic>{
      'totalConnections': connections.length,
      'connectionTypes': <String, int>{},
      'averageLatency': 0.0,
      'totalBandwidth': 0.0,
      'packetLoss': 0.0,
    };

    var totalLatency = 0.0;
    var totalPacketLoss = 0.0;

    for (final info in connections) {
      // Broj konekcija po tipu
      stats['connectionTypes'][info.type.toString()] =
          (stats['connectionTypes'][info.type.toString()] ?? 0) + 1;

      // Prikupi metrike
      final metrics = await _metricsCollector.collectNodeMetrics(info.nodeId);

      totalLatency += metrics['latency'] ?? 0.0;
      totalPacketLoss += metrics['packetLoss'] ?? 0.0;
      stats['totalBandwidth'] += metrics['bandwidth'] ?? 0.0;
    }

    if (connections.isNotEmpty) {
      stats['averageLatency'] = totalLatency / connections.length;
      stats['packetLoss'] = totalPacketLoss / connections.length;
    }

    return stats;
  }

  /// Prikuplja statistiku o zdravlju mreže
  Future<Map<String, dynamic>> _collectHealthStats(
    List<ConnectionInfo> connections,
  ) async {
    final stats = <String, dynamic>{
      'healthStatus': <String, int>{},
      'totalIssues': 0,
      'criticalIssues': 0,
      'degradedConnections': 0,
    };

    for (final info in connections) {
      final nodeStats = _connectionMonitor.getNodeStats(info.nodeId);
      if (nodeStats == null) continue;

      final status = _determineHealthStatus(nodeStats);

      // Broj konekcija po statusu zdravlja
      stats['healthStatus'][status.toString()] =
          (stats['healthStatus'][status.toString()] ?? 0) + 1;

      if (status == HealthStatus.critical) {
        stats['criticalIssues']++;
      } else if (status == HealthStatus.degraded) {
        stats['degradedConnections']++;
      }
    }

    stats['totalIssues'] =
        stats['criticalIssues'] + stats['degradedConnections'];

    return stats;
  }

  /// Analizira povezanost između čvorova
  Future<void> _analyzePeerConnectivity(
    List<ConnectionInfo> connections,
    List<DiagnosticInfo> diagnostics,
  ) async {
    for (final info in connections) {
      final nodeStats = _connectionMonitor.getNodeStats(info.nodeId);
      if (nodeStats == null) continue;

      if (nodeStats.reconnectCount > 3) {
        diagnostics.add(DiagnosticInfo(
          nodeId: info.nodeId,
          type: DiagnosticType.warning,
          message: 'Česte rekonekcije sa čvorom',
          details: {
            'reconnectCount': nodeStats.reconnectCount,
            'uptime': nodeStats.uptime.toString(),
          },
          timestamp: DateTime.now(),
        ));
      }
    }
  }

  /// Analizira topologiju mreže
  Future<void> _analyzeNetworkTopology(
    List<ConnectionInfo> connections,
    List<DiagnosticInfo> diagnostics,
  ) async {
    // Proveri distribuciju tipova konekcija
    final typeDistribution = <ConnectionType, int>{};
    for (final info in connections) {
      typeDistribution[info.type] = (typeDistribution[info.type] ?? 0) + 1;
    }

    // Proveri da li je mreža previše zavisna od jednog tipa konekcije
    final totalConnections = connections.length;
    for (final entry in typeDistribution.entries) {
      final percentage = entry.value / totalConnections;
      if (percentage > 0.8) {
        diagnostics.add(DiagnosticInfo(
          nodeId: 'system',
          type: DiagnosticType.warning,
          message: 'Prevelika zavisnost od jednog tipa konekcije',
          details: {
            'type': entry.key.toString(),
            'percentage': '${(percentage * 100).toStringAsFixed(1)}%',
          },
          timestamp: DateTime.now(),
        ));
      }
    }
  }

  /// Analizira obrasce performansi
  Future<void> _analyzePerformancePatterns(
    List<ConnectionInfo> connections,
    List<DiagnosticInfo> diagnostics,
  ) async {
    for (final info in connections) {
      final nodeStats = _connectionMonitor.getNodeStats(info.nodeId);
      if (nodeStats == null) continue;

      // Proveri trend performansi
      if (nodeStats.reliability < 0.8) {
        diagnostics.add(DiagnosticInfo(
          nodeId: info.nodeId,
          type: DiagnosticType.warning,
          message: 'Niska pouzdanost konekcije',
          details: {
            'reliability': nodeStats.reliability.toString(),
            'uptime': nodeStats.uptime.toString(),
          },
          timestamp: DateTime.now(),
        ));
      }
    }
  }

  /// Generiše preporuke za poboljšanje mreže
  List<String> _generateNetworkRecommendations(
    Map<String, dynamic> networkStats,
    Map<String, dynamic> healthStats,
  ) {
    final recommendations = <String>[];

    // Proveri kritične probleme
    if (healthStats['criticalIssues'] > 0) {
      recommendations.add(
        'Hitno rešiti ${healthStats['criticalIssues']} kritičnih problema',
      );
    }

    // Proveri prosečnu latenciju
    final averageLatency = networkStats['averageLatency'] as double;
    if (averageLatency > 500) {
      recommendations.add(
        'Optimizovati mrežu za smanjenje latencije (trenutno ${averageLatency.toStringAsFixed(1)}ms)',
      );
    }

    // Proveri gubitak paketa
    final packetLoss = networkStats['packetLoss'] as double;
    if (packetLoss > 0.1) {
      recommendations.add(
        'Istražiti uzroke gubitka paketa (trenutno ${(packetLoss * 100).toStringAsFixed(1)}%)',
      );
    }

    // Proveri distribuciju tipova konekcija
    final connectionTypes = networkStats['connectionTypes'] as Map<String, int>;
    if (connectionTypes.length == 1) {
      recommendations.add(
        'Razmotriti dodavanje alternativnih tipova konekcija za redundansu',
      );
    }

    return recommendations;
  }

  /// Određuje status zdravlja na osnovu statistike
  HealthStatus _determineHealthStatus(ConnectionStats stats) {
    if (stats.latency >= 1000 ||
        stats.packetLoss >= 0.3 ||
        stats.bandwidth <= 10.0) {
      return HealthStatus.critical;
    }

    if (stats.latency >= 500 ||
        stats.packetLoss >= 0.1 ||
        stats.bandwidth <= 50.0) {
      return HealthStatus.degraded;
    }

    if (stats.reliability < 1.0) {
      return HealthStatus.failed;
    }

    return HealthStatus.healthy;
  }

  /// Čisti resurse
  void dispose() {
    _diagnosticController.close();
  }
}
