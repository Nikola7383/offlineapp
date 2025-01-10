import 'dart:async';
import '../communication/connection_manager.dart';
import '../monitoring/connection_monitor.dart';
import '../monitoring/connection_health_check.dart';
import '../monitoring/network_metrics_collector.dart';
import '../diagnostics/network_diagnostics.dart';

/// Tip optimizacije
enum OptimizationType {
  performance,
  reliability,
  efficiency,
  security,
}

/// Predlog za optimizaciju
class OptimizationSuggestion {
  final String title;
  final String description;
  final OptimizationType type;
  final double impact; // 0.0 - 1.0
  final double effort; // 0.0 - 1.0
  final List<String> steps;
  final Map<String, dynamic> metrics;

  const OptimizationSuggestion({
    required this.title,
    required this.description,
    required this.type,
    required this.impact,
    required this.effort,
    required this.steps,
    required this.metrics,
  });
}

/// Izveštaj o analizi
class AnalysisReport {
  final DateTime timestamp;
  final Map<String, dynamic> metrics;
  final List<OptimizationSuggestion> suggestions;
  final Map<String, List<String>> insights;
  final double overallScore; // 0.0 - 1.0

  const AnalysisReport({
    required this.timestamp,
    required this.metrics,
    required this.suggestions,
    required this.insights,
    required this.overallScore,
  });
}

/// Analizira mrežne performanse i predlaže optimizacije
class NetworkAnalyzer {
  final ConnectionManager _connectionManager;
  final ConnectionMonitor _connectionMonitor;
  final ConnectionHealthCheck _healthCheck;
  final NetworkMetricsCollector _metricsCollector;
  final NetworkDiagnostics _diagnostics;

  // Stream controller za predloge optimizacija
  final _suggestionController =
      StreamController<OptimizationSuggestion>.broadcast();

  // Konstante
  static const Duration ANALYSIS_INTERVAL = Duration(minutes: 30);
  static const double LATENCY_THRESHOLD = 200.0; // ms
  static const double PACKET_LOSS_THRESHOLD = 0.05; // 5%
  static const double BANDWIDTH_THRESHOLD = 100.0; // KB/s
  static const int MIN_CONNECTIONS = 3;
  static const double MIN_RELIABILITY = 0.95;

  Stream<OptimizationSuggestion> get suggestionStream =>
      _suggestionController.stream;

  NetworkAnalyzer({
    required ConnectionManager connectionManager,
    required ConnectionMonitor connectionMonitor,
    required ConnectionHealthCheck healthCheck,
    required NetworkMetricsCollector metricsCollector,
    required NetworkDiagnostics diagnostics,
  })  : _connectionManager = connectionManager,
        _connectionMonitor = connectionMonitor,
        _healthCheck = healthCheck,
        _metricsCollector = metricsCollector,
        _diagnostics = diagnostics {
    // Pokreni periodičnu analizu
    Timer.periodic(ANALYSIS_INTERVAL, (_) => analyzeNetwork());
  }

  /// Analizira mrežu i generiše izveštaj
  Future<AnalysisReport> analyzeNetwork() async {
    final metrics = <String, dynamic>{};
    final suggestions = <OptimizationSuggestion>[];
    final insights = <String, List<String>>{};

    try {
      // Prikupi metrike i statistike
      final activeConnections = _connectionManager.getActiveConnections();
      final networkStats = await _collectNetworkStats(activeConnections);
      final healthStats = await _collectHealthStats(activeConnections);

      metrics.addAll(networkStats);
      metrics.addAll(healthStats);

      // Analiziraj različite aspekte mreže
      await _analyzePerformance(activeConnections, suggestions, insights);
      await _analyzeReliability(activeConnections, suggestions, insights);
      await _analyzeEfficiency(activeConnections, suggestions, insights);
      await _analyzeSecurity(activeConnections, suggestions, insights);

      // Izračunaj ukupnu ocenu
      final overallScore = _calculateOverallScore(metrics);

      return AnalysisReport(
        timestamp: DateTime.now(),
        metrics: metrics,
        suggestions: suggestions,
        insights: insights,
        overallScore: overallScore,
      );
    } catch (e) {
      print('Greška pri analizi mreže: $e');
      return AnalysisReport(
        timestamp: DateTime.now(),
        metrics: metrics,
        suggestions: [],
        insights: {
          'error': ['Greška pri analizi: $e']
        },
        overallScore: 0.0,
      );
    }
  }

  /// Prikuplja mrežne statistike
  Future<Map<String, dynamic>> _collectNetworkStats(
    List<ConnectionInfo> connections,
  ) async {
    final stats = <String, dynamic>{};

    // Prikupi osnovne metrike
    var totalLatency = 0.0;
    var totalPacketLoss = 0.0;
    var totalBandwidth = 0.0;
    var totalReliability = 0.0;

    for (final info in connections) {
      final metrics = await _metricsCollector.collectNodeMetrics(info.nodeId);
      final nodeStats = _connectionMonitor.getNodeStats(info.nodeId);

      if (nodeStats != null) {
        totalLatency += metrics['latency'] ?? 0.0;
        totalPacketLoss += metrics['packetLoss'] ?? 0.0;
        totalBandwidth += metrics['bandwidth'] ?? 0.0;
        totalReliability += nodeStats.reliability;
      }
    }

    final count = connections.length;
    if (count > 0) {
      stats['averageLatency'] = totalLatency / count;
      stats['averagePacketLoss'] = totalPacketLoss / count;
      stats['totalBandwidth'] = totalBandwidth;
      stats['averageReliability'] = totalReliability / count;
    }

    // Prikupi statistike po tipu konekcije
    final typeStats = <ConnectionType, Map<String, double>>{};
    for (final info in connections) {
      final metrics = await _metricsCollector.collectNodeMetrics(info.nodeId);
      final nodeStats = _connectionMonitor.getNodeStats(info.nodeId);

      if (nodeStats != null) {
        typeStats[info.type] ??= {
          'count': 0,
          'latency': 0.0,
          'packetLoss': 0.0,
          'bandwidth': 0.0,
          'reliability': 0.0,
        };

        final typeStat = typeStats[info.type]!;
        typeStat['count'] = typeStat['count']! + 1;
        typeStat['latency'] =
            typeStat['latency']! + (metrics['latency'] ?? 0.0);
        typeStat['packetLoss'] =
            typeStat['packetLoss']! + (metrics['packetLoss'] ?? 0.0);
        typeStat['bandwidth'] =
            typeStat['bandwidth']! + (metrics['bandwidth'] ?? 0.0);
        typeStat['reliability'] =
            typeStat['reliability']! + nodeStats.reliability;
      }
    }

    // Izračunaj proseke po tipu
    for (final entry in typeStats.entries) {
      final count = entry.value['count']!;
      if (count > 0) {
        stats['${entry.key}_latency'] = entry.value['latency']! / count;
        stats['${entry.key}_packetLoss'] = entry.value['packetLoss']! / count;
        stats['${entry.key}_bandwidth'] = entry.value['bandwidth']!;
        stats['${entry.key}_reliability'] = entry.value['reliability']! / count;
      }
    }

    return stats;
  }

  /// Prikuplja statistike o zdravlju
  Future<Map<String, dynamic>> _collectHealthStats(
    List<ConnectionInfo> connections,
  ) async {
    final stats = <String, dynamic>{};

    var criticalCount = 0;
    var degradedCount = 0;
    var failedCount = 0;

    for (final info in connections) {
      final nodeStats = _connectionMonitor.getNodeStats(info.nodeId);
      if (nodeStats == null) continue;

      final status = _determineHealthStatus(nodeStats);
      switch (status) {
        case HealthStatus.critical:
          criticalCount++;
          break;
        case HealthStatus.degraded:
          degradedCount++;
          break;
        case HealthStatus.failed:
          failedCount++;
          break;
        default:
          break;
      }
    }

    stats['criticalConnections'] = criticalCount;
    stats['degradedConnections'] = degradedCount;
    stats['failedConnections'] = failedCount;
    stats['healthyConnections'] =
        connections.length - (criticalCount + degradedCount + failedCount);

    return stats;
  }

  /// Analizira performanse mreže
  Future<void> _analyzePerformance(
    List<ConnectionInfo> connections,
    List<OptimizationSuggestion> suggestions,
    Map<String, List<String>> insights,
  ) async {
    final performanceInsights = <String>[];

    for (final info in connections) {
      final metrics = await _metricsCollector.collectNodeMetrics(info.nodeId);
      final latency = metrics['latency'] ?? double.infinity;

      // Proveri latenciju
      if (latency > LATENCY_THRESHOLD) {
        suggestions.add(OptimizationSuggestion(
          title: 'Optimizacija latencije za čvor ${info.nodeId}',
          description: 'Visoka latencija utiče na performanse komunikacije',
          type: OptimizationType.performance,
          impact: 0.8,
          effort: 0.6,
          steps: [
            'Smanjiti veličinu poruka',
            'Optimizovati frekvenciju komunikacije',
            'Razmotriti promenu tipa konekcije',
          ],
          metrics: {
            'currentLatency': latency,
            'threshold': LATENCY_THRESHOLD,
          },
        ));

        performanceInsights.add(
          'Visoka latencija (${latency.toStringAsFixed(1)}ms) za čvor ${info.nodeId}',
        );
      }
    }

    insights['performance'] = performanceInsights;
  }

  /// Analizira pouzdanost mreže
  Future<void> _analyzeReliability(
    List<ConnectionInfo> connections,
    List<OptimizationSuggestion> suggestions,
    Map<String, List<String>> insights,
  ) async {
    final reliabilityInsights = <String>[];

    // Proveri broj aktivnih konekcija
    if (connections.length < MIN_CONNECTIONS) {
      suggestions.add(OptimizationSuggestion(
        title: 'Povećanje redundanse mreže',
        description: 'Nedovoljan broj aktivnih konekcija za pouzdanu mrežu',
        type: OptimizationType.reliability,
        impact: 0.9,
        effort: 0.7,
        steps: [
          'Dodati nove čvorove u mrežu',
          'Uspostaviti alternativne putanje',
          'Implementirati load balancing',
        ],
        metrics: {
          'currentConnections': connections.length,
          'minimumRequired': MIN_CONNECTIONS,
        },
      ));

      reliabilityInsights.add(
        'Nedovoljan broj konekcija (${connections.length}/$MIN_CONNECTIONS)',
      );
    }

    for (final info in connections) {
      final nodeStats = _connectionMonitor.getNodeStats(info.nodeId);
      if (nodeStats == null) continue;

      // Proveri pouzdanost
      if (nodeStats.reliability < MIN_RELIABILITY) {
        suggestions.add(OptimizationSuggestion(
          title: 'Poboljšanje pouzdanosti čvora ${info.nodeId}',
          description: 'Niska pouzdanost utiče na stabilnost mreže',
          type: OptimizationType.reliability,
          impact: 0.7,
          effort: 0.5,
          steps: [
            'Istražiti uzroke nestabilnosti',
            'Implementirati mehanizme za oporavak',
            'Razmotriti alternativne putanje',
          ],
          metrics: {
            'currentReliability': nodeStats.reliability,
            'minimumRequired': MIN_RELIABILITY,
          },
        ));

        reliabilityInsights.add(
          'Niska pouzdanost (${(nodeStats.reliability * 100).toStringAsFixed(1)}%) za čvor ${info.nodeId}',
        );
      }
    }

    insights['reliability'] = reliabilityInsights;
  }

  /// Analizira efikasnost mreže
  Future<void> _analyzeEfficiency(
    List<ConnectionInfo> connections,
    List<OptimizationSuggestion> suggestions,
    Map<String, List<String>> insights,
  ) async {
    final efficiencyInsights = <String>[];

    for (final info in connections) {
      final metrics = await _metricsCollector.collectNodeMetrics(info.nodeId);
      final packetLoss = metrics['packetLoss'] ?? 1.0;
      final bandwidth = metrics['bandwidth'] ?? 0.0;

      // Proveri gubitak paketa
      if (packetLoss > PACKET_LOSS_THRESHOLD) {
        suggestions.add(OptimizationSuggestion(
          title: 'Smanjenje gubitka paketa za čvor ${info.nodeId}',
          description: 'Visok gubitak paketa smanjuje efikasnost',
          type: OptimizationType.efficiency,
          impact: 0.6,
          effort: 0.4,
          steps: [
            'Optimizovati veličinu paketa',
            'Prilagoditi timeout vrednosti',
            'Implementirati naprednije retry mehanizme',
          ],
          metrics: {
            'currentPacketLoss': packetLoss,
            'threshold': PACKET_LOSS_THRESHOLD,
          },
        ));

        efficiencyInsights.add(
          'Visok gubitak paketa (${(packetLoss * 100).toStringAsFixed(1)}%) za čvor ${info.nodeId}',
        );
      }

      // Proveri propusni opseg
      if (bandwidth < BANDWIDTH_THRESHOLD) {
        suggestions.add(OptimizationSuggestion(
          title: 'Optimizacija propusnog opsega za čvor ${info.nodeId}',
          description: 'Nizak propusni opseg ograničava performanse',
          type: OptimizationType.efficiency,
          impact: 0.7,
          effort: 0.5,
          steps: [
            'Implementirati kompresiju podataka',
            'Optimizovati protokol komunikacije',
            'Razmotriti alternativne putanje',
          ],
          metrics: {
            'currentBandwidth': bandwidth,
            'threshold': BANDWIDTH_THRESHOLD,
          },
        ));

        efficiencyInsights.add(
          'Nizak propusni opseg (${bandwidth.toStringAsFixed(1)}KB/s) za čvor ${info.nodeId}',
        );
      }
    }

    insights['efficiency'] = efficiencyInsights;
  }

  /// Analizira sigurnost mreže
  Future<void> _analyzeSecurity(
    List<ConnectionInfo> connections,
    List<OptimizationSuggestion> suggestions,
    Map<String, List<String>> insights,
  ) async {
    final securityInsights = <String>[];

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
        suggestions.add(OptimizationSuggestion(
          title: 'Diversifikacija tipova konekcija',
          description: 'Prevelika zavisnost od jednog tipa konekcije',
          type: OptimizationType.security,
          impact: 0.8,
          effort: 0.7,
          steps: [
            'Implementirati podršku za alternativne protokole',
            'Uspostaviti backup konekcije',
            'Implementirati automatsko prebacivanje',
          ],
          metrics: {
            'dominantType': entry.key.toString(),
            'percentage': percentage,
          },
        ));

        securityInsights.add(
          'Prevelika zavisnost od ${entry.key} konekcija (${(percentage * 100).toStringAsFixed(1)}%)',
        );
      }
    }

    insights['security'] = securityInsights;
  }

  /// Izračunava ukupnu ocenu mreže
  double _calculateOverallScore(Map<String, dynamic> metrics) {
    var score = 1.0;

    // Penali za loše performanse
    if (metrics['averageLatency'] > LATENCY_THRESHOLD) {
      score *= 0.8;
    }
    if (metrics['averagePacketLoss'] > PACKET_LOSS_THRESHOLD) {
      score *= 0.7;
    }
    if (metrics['totalBandwidth'] < BANDWIDTH_THRESHOLD) {
      score *= 0.9;
    }

    // Penali za probleme sa zdravljem
    final totalConnections = metrics['healthyConnections'] +
        metrics['degradedConnections'] +
        metrics['criticalConnections'] +
        metrics['failedConnections'];

    if (totalConnections > 0) {
      final healthyRatio = metrics['healthyConnections'] / totalConnections;
      score *= (0.3 + 0.7 * healthyRatio);
    }

    return score;
  }

  /// Određuje status zdravlja konekcije
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
    _suggestionController.close();
  }
}
