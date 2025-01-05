import 'dart:async';
import 'dart:isolate';
import 'package:crypto/crypto.dart';
import '../security/security_types.dart';
import '../core/protocol_coordinator.dart';

class SystemHealthMonitor {
  static const Duration CHECK_INTERVAL = Duration(seconds: 30);
  static const int HISTORY_LIMIT =
      1000; // Broj istorijskih podataka koji se čuvaju
  static const double THREAT_THRESHOLD = 0.75;

  final ProtocolCoordinator _coordinator;
  final _HealthDataStore _dataStore = _HealthDataStore();
  final _BehaviorAnalyzer _behaviorAnalyzer = _BehaviorAnalyzer();

  late final Isolate _monitorIsolate;
  final _anomalies = StreamController<_HealthAnomaly>.broadcast();

  bool _isInitialized = false;
  DateTime? _lastCheck;

  SystemHealthMonitor({
    required ProtocolCoordinator coordinator,
  }) : _coordinator = coordinator;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Pokreni monitoring u zasebnom isolate-u
      final receivePort = ReceivePort();
      _monitorIsolate = await Isolate.spawn(
        _healthMonitorWorker,
        _WorkerParams(
          sendPort: receivePort.sendPort,
          interval: CHECK_INTERVAL,
        ),
      );

      // Slušaj rezultate
      receivePort.listen(_handleHealthUpdate);

      _isInitialized = true;
    } catch (e) {
      throw HealthMonitorException('Failed to initialize health monitor: $e');
    }
  }

  Future<void> _handleHealthUpdate(_HealthUpdate update) async {
    // Sačuvaj podatke
    _dataStore.addHealthData(update);

    // Analiziraj ponašanje
    final anomalies = await _behaviorAnalyzer.analyze(
      update,
      _dataStore.recentHistory,
    );

    // Ako ima anomalija, reaguj
    if (anomalies.isNotEmpty) {
      await _handleAnomalies(anomalies);
    }

    _lastCheck = DateTime.now();
  }

  Future<void> _handleAnomalies(List<_HealthAnomaly> anomalies) async {
    for (final anomaly in anomalies) {
      if (anomaly.threatLevel >= THREAT_THRESHOLD) {
        // Visok nivo pretnje - potrebna hitna akcija
        await _handleHighThreat(anomaly);
      } else {
        // Niži nivo - preventivna akcija
        await _handleLowThreat(anomaly);
      }
    }
  }

  Future<void> _handleHighThreat(_HealthAnomaly anomaly) async {
    // Odluči o nivou intervencije
    final action = await _determineAction(anomaly);

    switch (action) {
      case _HealthAction.preventive:
        await _coordinator.handleStateTransition(
          SystemState.heightenedSecurity,
          trigger: 'health_monitor',
          context: {'anomaly': anomaly.toJson()},
        );
        break;

      case _HealthAction.phoenix:
        await _coordinator.handleStateTransition(
          SystemState.phoenix,
          trigger: 'health_monitor',
          context: {'anomaly': anomaly.toJson()},
        );
        break;

      case _HealthAction.emergency:
        await _coordinator.handleStateTransition(
          SystemState.emergency,
          trigger: 'health_monitor',
          context: {'anomaly': anomaly.toJson()},
        );
        break;
    }
  }

  Future<_HealthAction> _determineAction(_HealthAnomaly anomaly) async {
    // Koristi AI za odluku, ali potpuno offline
    final context = _SecurityContext(
      recentAnomalies: _dataStore.recentAnomalies,
      systemState: await _coordinator.getCurrentState(),
      resourceUsage: await _getResourceUsage(),
    );

    return _SecurityDecision.determine(
      anomaly: anomaly,
      context: context,
    );
  }

  Future<Map<String, double>> _getResourceUsage() async {
    // Offline provera resursa
    return {
      'memory': await _getMemoryUsage(),
      'cpu': await _getCpuUsage(),
      'storage': await _getStorageUsage(),
    };
  }

  void dispose() {
    _monitorIsolate.kill();
    _anomalies.close();
    _dataStore.clear();
  }
}

class _HealthDataStore {
  final Map<DateTime, _HealthUpdate> _history = {};
  final List<_HealthAnomaly> _recentAnomalies = [];

  void addHealthData(_HealthUpdate update) {
    // Dodaj nove podatke
    _history[update.timestamp] = update;

    // Očisti stare podatke
    _cleanupOldData();
  }

  void _cleanupOldData() {
    final now = DateTime.now();
    _history
        .removeWhere((timestamp, _) => now.difference(timestamp).inHours > 24);

    while (_history.length > SystemHealthMonitor.HISTORY_LIMIT) {
      _history.remove(_history.keys.first);
    }
  }

  List<_HealthUpdate> get recentHistory => _history.values.toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  List<_HealthAnomaly> get recentAnomalies => _recentAnomalies;

  void clear() {
    _history.clear();
    _recentAnomalies.clear();
  }
}

class _BehaviorAnalyzer {
  Future<List<_HealthAnomaly>> analyze(
    _HealthUpdate current,
    List<_HealthUpdate> history,
  ) async {
    final anomalies = <_HealthAnomaly>[];

    // Analiziraj patterns
    if (_hasAbnormalPattern(current, history)) {
      anomalies.add(_HealthAnomaly(
        type: AnomalyType.abnormalPattern,
        threatLevel: _calculateThreatLevel(current, history),
        timestamp: DateTime.now(),
      ));
    }

    // Analiziraj resource usage
    if (_hasResourceAnomaly(current, history)) {
      anomalies.add(_HealthAnomaly(
        type: AnomalyType.resourceSpike,
        threatLevel: _calculateResourceThreat(current, history),
        timestamp: DateTime.now(),
      ));
    }

    return anomalies;
  }
}

class HealthMonitorException implements Exception {
  final String message;
  HealthMonitorException(this.message);
}
