import 'dart:async';
import 'dart:math';
import '../security/security_types.dart';
import '../ai/autonomous_security_core.dart';
import '../mesh/secure_mesh_network.dart';

class EmergencyRecoverySystem {
  static const Duration MESSENGER_LIFETIME = Duration(minutes: 5);
  static const int MAX_ACTIVE_MESSENGERS = 3;
  static const Duration ROTATION_INTERVAL = Duration(minutes: 5);

  final AutonomousSecurityCore _ai;
  final SecureMeshNetwork _network;

  bool _isEmergencyActive = false;
  final Map<String, _EmergencyMessenger> _activeMessengers = {};
  final List<_RecoveryPhase> _recoveryLog = [];
  Timer? _rotationTimer;

  EmergencyRecoverySystem({
    required AutonomousSecurityCore ai,
    required SecureMeshNetwork network,
  })  : _ai = ai,
        _network = network;

  Future<void> initiateEmergencyRecovery({
    required EmergencyTrigger trigger,
    required Map<String, dynamic> context,
  }) async {
    if (_isEmergencyActive) return;

    try {
      _isEmergencyActive = true;
      _logRecoveryPhase(RecoveryPhaseType.initiated, context);

      // 1. Aktiviraj emergency protokol
      await _activateEmergencyProtocol(trigger);

      // 2. Pokreni rotaciju glasnika
      _startMessengerRotation();

      // 3. Započni oporavak mreže
      await _executeRecoverySequence();
    } catch (e) {
      _logRecoveryPhase(RecoveryPhaseType.failed, {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> _activateEmergencyProtocol(EmergencyTrigger trigger) async {
    // Zaustavi sve normalne operacije
    await _network.pauseOperations();

    // Sačuvaj trenutno stanje
    final snapshot = await _createNetworkSnapshot();

    // Identifikuj zdrave čvorove
    final healthyNodes = await _identifyHealthyNodes();
    if (healthyNodes.isEmpty) {
      throw EmergencyException('No healthy nodes available for recovery');
    }

    // Aktiviraj prvi set glasnika
    await _activateInitialMessengers(healthyNodes);
  }

  Future<void> _activateInitialMessengers(List<String> healthyNodes) async {
    final selectedNodes = _selectMessengerNodes(healthyNodes);

    for (final node in selectedNodes) {
      final messenger = await _createEmergencyMessenger(node);
      _activeMessengers[node] = messenger;

      // Postavi vreme isteka
      _scheduleMessengerExpiration(node);
    }
  }

  List<String> _selectMessengerNodes(List<String> healthyNodes) {
    // Koristi AI za izbor najboljih čvorova za glasnike
    final rankedNodes = healthyNodes.map((node) {
      final score = _calculateNodeScore(node);
      return MapEntry(node, score);
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return rankedNodes.take(MAX_ACTIVE_MESSENGERS).map((e) => e.key).toList();
  }

  void _startMessengerRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(ROTATION_INTERVAL, (_) {
      _rotateMessengers();
    });
  }

  Future<void> _rotateMessengers() async {
    // Pronađi glasnike kojima ističe vreme
    final expiredMessengers = _activeMessengers.entries
        .where((entry) => entry.value.isExpired)
        .toList();

    // Pronađi nove zdrave čvorove
    final healthyNodes = await _identifyHealthyNodes();
    final availableNodes = healthyNodes
        .where((node) => !_activeMessengers.containsKey(node))
        .toList();

    // Zameni istekle glasnike
    for (final expired in expiredMessengers) {
      if (availableNodes.isEmpty) break;

      // Deaktiviraj starog glasnika
      await _deactivateMessenger(expired.key);

      // Aktiviraj novog
      final newNode = availableNodes.removeAt(0);
      final newMessenger = await _createEmergencyMessenger(newNode);
      _activeMessengers[newNode] = newMessenger;

      _scheduleMessengerExpiration(newNode);
    }
  }

  Future<void> _executeRecoverySequence() async {
    try {
      // 1. Uspostavi emergency mesh mrežu
      await _establishEmergencyMesh();

      // 2. Pokreni oporavak podataka
      await _recoverCriticalData();

      // 3. Regeneriši sigurnosne protokole
      await _regenerateSecurityProtocols();

      // 4. Verifikuj oporavak
      if (await _verifyRecovery()) {
        _logRecoveryPhase(RecoveryPhaseType.completed, {
          'activeMessengers': _activeMessengers.length,
          'recoveredNodes': await _getRecoveredNodeCount(),
        });
      }
    } finally {
      // Zakaži gašenje emergency moda
      _scheduleEmergencyDeactivation();
    }
  }

  Future<void> _deactivateEmergency() async {
    _isEmergencyActive = false;
    _rotationTimer?.cancel();

    // Deaktiviraj sve glasnike
    for (final node in _activeMessengers.keys) {
      await _deactivateMessenger(node);
    }
    _activeMessengers.clear();

    // Vrati mrežu u normalno stanje
    await _network.resumeOperations();
  }

  void _logRecoveryPhase(RecoveryPhaseType phase, Map<String, dynamic> data) {
    _recoveryLog.add(_RecoveryPhase(
      type: phase,
      timestamp: DateTime.now(),
      data: data,
    ));
  }

  void dispose() {
    _rotationTimer?.cancel();
    _activeMessengers.clear();
    _recoveryLog.clear();
  }
}

class _EmergencyMessenger {
  final String nodeId;
  final DateTime activatedAt;
  final DateTime expiresAt;
  bool isActive = true;

  _EmergencyMessenger({
    required this.nodeId,
    required this.activatedAt,
  }) : expiresAt = activatedAt.add(EmergencyRecoverySystem.MESSENGER_LIFETIME);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class _RecoveryPhase {
  final RecoveryPhaseType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  _RecoveryPhase({
    required this.type,
    required this.timestamp,
    required this.data,
  });
}

enum RecoveryPhaseType {
  initiated,
  messengerActivated,
  messengerRotated,
  dataRecovered,
  completed,
  failed,
}

enum EmergencyTrigger {
  networkCompromised,
  masterUnavailable,
  adminsCompromised,
  phoenixFailed,
  criticalDataBreach,
}

class EmergencyException implements Exception {
  final String message;
  EmergencyException(this.message);
}
