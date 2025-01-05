import 'dart:async';
import '../security/security_types.dart';
import '../ai/autonomous_security_core.dart';
import '../emergency/emergency_recovery_system.dart';

class ProtocolCoordinator {
  static const Duration LOCK_TIMEOUT = Duration(seconds: 30);
  static const int MAX_TRANSITION_ATTEMPTS = 3;

  final AutonomousSecurityCore _ai;
  final EmergencyRecoverySystem _emergency;

  bool _isLocked = false;
  SystemState _currentState = SystemState.normal;
  final Map<DateTime, _StateTransition> _transitionLog = {};
  final _cleanupQueue = StreamController<_CleanupTask>();

  ProtocolCoordinator({
    required AutonomousSecurityCore ai,
    required EmergencyRecoverySystem emergency,
  })  : _ai = ai,
        _emergency = emergency {
    _initializeCoordinator();
  }

  Future<void> _initializeCoordinator() async {
    // Postavi cleanup worker
    _cleanupQueue.stream.listen(_processCleanupTask);

    // Inicijalno stanje sistema
    await _validateAndSetState(SystemState.normal);
  }

  Future<bool> handleStateTransition(
    SystemState newState, {
    required String trigger,
    Map<String, dynamic>? context,
  }) async {
    if (!await _canTransition(newState)) {
      return false;
    }

    var attempts = 0;
    while (attempts < MAX_TRANSITION_ATTEMPTS) {
      try {
        await _lockSystemForTransition();

        // Pripremi tranziciju
        final transition = _StateTransition(
          from: _currentState,
          to: newState,
          trigger: trigger,
          context: context,
        );

        // Validiraj i izvrši
        if (await _executeTransition(transition)) {
          _logTransition(transition);
          return true;
        }
      } catch (e) {
        attempts++;
        await _handleTransitionError(e, attempts);
      } finally {
        await _unlockSystem();
      }
    }

    // Ako sve tranzicije nisu uspele, aktiviraj emergency
    await _emergency.initiateEmergencyRecovery(
      trigger: EmergencyTrigger.transitionFailed,
      context: {
        'failedState': newState.toString(),
        'attempts': attempts,
      },
    );

    return false;
  }

  Future<bool> _canTransition(SystemState newState) async {
    // Proveri da li je tranzicija logički moguća
    if (!_isValidTransition(_currentState, newState)) {
      return false;
    }

    // Proveri integritet sistema
    if (!await _verifySystemIntegrity()) {
      return false;
    }

    // Proveri AI procenu
    final aiDecision = await _ai.evaluateTransition(
      _currentState,
      newState,
    );

    return aiDecision.confidence > 0.85;
  }

  Future<bool> _executeTransition(_StateTransition transition) async {
    // 1. Pripremi sistem
    await _prepareForTransition(transition);

    // 2. Izvrši tranziciju
    final success = await _performStateChange(transition);
    if (!success) return false;

    // 3. Verifikuj novo stanje
    if (!await _verifyNewState(transition.to)) {
      await _rollbackTransition(transition);
      return false;
    }

    // 4. Očisti tragove
    _queueCleanup(transition);

    return true;
  }

  Future<void> _queueCleanup(_StateTransition transition) async {
    _cleanupQueue.add(_CleanupTask(
      transition: transition,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _processCleanupTask(_CleanupTask task) async {
    try {
      // 1. Očisti memoriju
      await _cleanupMemory(task.transition);

      // 2. Očisti logove
      await _sanitizeLogs(task.transition);

      // 3. Randomizuj tajminge
      await _randomizeTimings();

      // 4. Verifikuj čišćenje
      await _verifyNoTraces(task.transition);
    } catch (e) {
      // Log error ali ne prekidaj rad
      print('Cleanup error: $e');
    }
  }

  void dispose() {
    _cleanupQueue.close();
  }
}

class _StateTransition {
  final SystemState from;
  final SystemState to;
  final String trigger;
  final Map<String, dynamic>? context;
  final DateTime timestamp;

  _StateTransition({
    required this.from,
    required this.to,
    required this.trigger,
    this.context,
  }) : timestamp = DateTime.now();
}

class _CleanupTask {
  final _StateTransition transition;
  final DateTime timestamp;

  _CleanupTask({
    required this.transition,
    required this.timestamp,
  });
}

enum SystemState { normal, heightenedSecurity, phoenix, emergency, recovery }
