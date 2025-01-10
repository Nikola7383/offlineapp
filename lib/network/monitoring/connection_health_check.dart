import 'dart:async';
import '../communication/connection_manager.dart';
import '../communication/connection_factory.dart';
import 'connection_monitor.dart';

/// Status zdravlja konekcije
enum HealthStatus {
  healthy,
  degraded,
  critical,
  failed,
}

/// Rezultat provere zdravlja
class HealthCheckResult {
  final String nodeId;
  final HealthStatus status;
  final List<String> issues;
  final List<String> recommendations;
  final DateTime timestamp;

  const HealthCheckResult({
    required this.nodeId,
    required this.status,
    required this.issues,
    required this.recommendations,
    required this.timestamp,
  });
}

/// Prati zdravlje konekcija i preduzima korektivne akcije
class ConnectionHealthCheck {
  final ConnectionManager _connectionManager;
  final ConnectionMonitor _connectionMonitor;

  // Stream controller za rezultate provere
  final _resultController = StreamController<HealthCheckResult>.broadcast();

  // Konstante
  static const Duration CHECK_INTERVAL = Duration(seconds: 30);
  static const double LATENCY_THRESHOLD_DEGRADED = 500.0; // ms
  static const double LATENCY_THRESHOLD_CRITICAL = 1000.0; // ms
  static const double PACKET_LOSS_THRESHOLD_DEGRADED = 0.1; // 10%
  static const double PACKET_LOSS_THRESHOLD_CRITICAL = 0.3; // 30%
  static const double BANDWIDTH_THRESHOLD_DEGRADED = 50.0; // KB/s
  static const double BANDWIDTH_THRESHOLD_CRITICAL = 10.0; // KB/s

  Stream<HealthCheckResult> get resultStream => _resultController.stream;

  ConnectionHealthCheck({
    required ConnectionManager connectionManager,
    required ConnectionMonitor connectionMonitor,
  })  : _connectionManager = connectionManager,
        _connectionMonitor = connectionMonitor {
    // Pokreni periodičnu proveru
    Timer.periodic(CHECK_INTERVAL, (_) => _checkHealth());
  }

  /// Proverava zdravlje svih konekcija
  Future<void> _checkHealth() async {
    final activeConnections = _connectionManager.getActiveConnections();

    for (final info in activeConnections) {
      try {
        final stats = _connectionMonitor.getNodeStats(info.nodeId);
        if (stats == null) continue;

        final issues = <String>[];
        final recommendations = <String>[];

        // Proveri latenciju
        if (stats.latency >= LATENCY_THRESHOLD_CRITICAL) {
          issues.add(
              'Kritično visoka latencija: ${stats.latency.toStringAsFixed(1)}ms');
        } else if (stats.latency >= LATENCY_THRESHOLD_DEGRADED) {
          issues
              .add('Povišena latencija: ${stats.latency.toStringAsFixed(1)}ms');
        }

        // Proveri gubitak paketa
        if (stats.packetLoss >= PACKET_LOSS_THRESHOLD_CRITICAL) {
          issues.add(
              'Kritičan gubitak paketa: ${(stats.packetLoss * 100).toStringAsFixed(1)}%');
        } else if (stats.packetLoss >= PACKET_LOSS_THRESHOLD_DEGRADED) {
          issues.add(
              'Povišen gubitak paketa: ${(stats.packetLoss * 100).toStringAsFixed(1)}%');
        }

        // Proveri propusni opseg
        if (stats.bandwidth <= BANDWIDTH_THRESHOLD_CRITICAL) {
          issues.add(
              'Kritično nizak propusni opseg: ${stats.bandwidth.toStringAsFixed(1)}KB/s');
        } else if (stats.bandwidth <= BANDWIDTH_THRESHOLD_DEGRADED) {
          issues.add(
              'Smanjen propusni opseg: ${stats.bandwidth.toStringAsFixed(1)}KB/s');
        }

        // Odredi status zdravlja
        final status = _determineHealthStatus(stats);

        // Generiši preporuke
        recommendations.addAll(
          _generateRecommendations(status, stats),
        );

        // Preduzmi korektivne akcije
        await _takeCorrectiveActions(status, stats);

        // Emituj rezultat
        final result = HealthCheckResult(
          nodeId: info.nodeId,
          status: status,
          issues: issues,
          recommendations: recommendations,
          timestamp: DateTime.now(),
        );

        _resultController.add(result);
      } catch (e) {
        print('Greška pri proveri zdravlja konekcije ${info.nodeId}: $e');
      }
    }
  }

  /// Određuje status zdravlja na osnovu statistike
  HealthStatus _determineHealthStatus(ConnectionStats stats) {
    if (stats.latency >= LATENCY_THRESHOLD_CRITICAL ||
        stats.packetLoss >= PACKET_LOSS_THRESHOLD_CRITICAL ||
        stats.bandwidth <= BANDWIDTH_THRESHOLD_CRITICAL) {
      return HealthStatus.critical;
    }

    if (stats.latency >= LATENCY_THRESHOLD_DEGRADED ||
        stats.packetLoss >= PACKET_LOSS_THRESHOLD_DEGRADED ||
        stats.bandwidth <= BANDWIDTH_THRESHOLD_DEGRADED) {
      return HealthStatus.degraded;
    }

    if (stats.reliability < 1.0) {
      return HealthStatus.failed;
    }

    return HealthStatus.healthy;
  }

  /// Generiše preporuke za poboljšanje performansi
  List<String> _generateRecommendations(
    HealthStatus status,
    ConnectionStats stats,
  ) {
    final recommendations = <String>[];

    switch (status) {
      case HealthStatus.critical:
        recommendations.add('Preporučuje se hitna promena tipa konekcije');
        recommendations.add('Razmotriti prelazak na alternativni čvor');
        break;

      case HealthStatus.degraded:
        if (stats.latency >= LATENCY_THRESHOLD_DEGRADED) {
          recommendations
              .add('Smanjiti veličinu poruka za poboljšanje latencije');
        }
        if (stats.packetLoss >= PACKET_LOSS_THRESHOLD_DEGRADED) {
          recommendations.add('Povećati interval između poruka');
        }
        if (stats.bandwidth <= BANDWIDTH_THRESHOLD_DEGRADED) {
          recommendations.add('Optimizovati količinu podataka koja se šalje');
        }
        break;

      case HealthStatus.failed:
        recommendations.add('Pokušati ponovno uspostavljanje konekcije');
        recommendations.add('Proveriti dostupnost čvora');
        break;

      case HealthStatus.healthy:
        // Nema preporuka za zdrave konekcije
        break;
    }

    return recommendations;
  }

  /// Preduzima korektivne akcije na osnovu statusa zdravlja
  Future<void> _takeCorrectiveActions(
    HealthStatus status,
    ConnectionStats stats,
  ) async {
    switch (status) {
      case HealthStatus.critical:
        // Pokušaj promenu tipa konekcije
        final availableTypes =
            await ConnectionFactory.getAvailableConnectionTypes();
        final currentTypeIndex = availableTypes.indexOf(stats.type);

        if (currentTypeIndex < availableTypes.length - 1) {
          // Probaj sledeći tip konekcije
          final nextType = availableTypes[currentTypeIndex + 1];
          await _connectionManager.connect(stats.nodeId,
              preferredType: nextType);
        }
        break;

      case HealthStatus.degraded:
        // Za sada samo pratimo degradirane konekcije
        break;

      case HealthStatus.failed:
        // Pokušaj ponovno povezivanje
        await _connectionManager.connect(stats.nodeId);
        break;

      case HealthStatus.healthy:
        // Nije potrebna akcija
        break;
    }
  }

  /// Čisti resurse
  void dispose() {
    _resultController.close();
  }
}
