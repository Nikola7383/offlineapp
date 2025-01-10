import 'dart:async';
import '../../mesh/models/node.dart';
import '../models/security_event.dart';

/// Upravlja izolacijom kompromitovanih čvorova iz mreže
class NodeIsolationManager {
  // Set izolovanih čvorova
  final Set<String> _isolatedNodeIds = {};

  // Mapa razloga izolacije
  final Map<String, IsolationReason> _isolationReasons = {};

  // Stream controller za događaje izolacije
  final _isolationController = StreamController<IsolationEventBase>.broadcast();

  // Konstante
  static const Duration DEFAULT_ISOLATION_DURATION = Duration(hours: 1);
  static const int MAX_ISOLATION_ATTEMPTS = 3;

  Stream<IsolationEventBase> get isolationStream => _isolationController.stream;

  /// Izoluje čvor iz mreže
  Future<bool> isolateNode(
    String nodeId,
    IsolationReason reason, {
    Duration duration = DEFAULT_ISOLATION_DURATION,
  }) async {
    if (_isolatedNodeIds.contains(nodeId)) {
      // Čvor je već izolovan, ažuriraj razlog
      _updateIsolationReason(nodeId, reason);
      return true;
    }

    try {
      // Pokušaj izolaciju čvora
      final success = await _executeIsolation(nodeId);
      if (!success) return false;

      // Dodaj čvor u set izolovanih
      _isolatedNodeIds.add(nodeId);
      _isolationReasons[nodeId] = reason;

      // Kreiraj i emituj događaj
      final event = IsolationEvent(
        nodeId: nodeId,
        reason: reason,
        timestamp: DateTime.now(),
        duration: duration,
      );
      _isolationController.add(event);

      // Postavi tajmer za automatsko vraćanje čvora
      _scheduleNodeReintegration(nodeId, duration);

      return true;
    } catch (e) {
      print('Greška pri izolaciji čvora $nodeId: $e');
      return false;
    }
  }

  /// Vraća čvor u mrežu
  Future<bool> reintegrateNode(String nodeId) async {
    if (!_isolatedNodeIds.contains(nodeId)) {
      return false; // Čvor nije izolovan
    }

    try {
      // Pokušaj reintegraciju čvora
      final success = await _executeReintegration(nodeId);
      if (!success) return false;

      // Ukloni čvor iz seta izolovanih
      _isolatedNodeIds.remove(nodeId);
      _isolationReasons.remove(nodeId);

      // Kreiraj i emituj događaj
      final event = ReintegrationEvent(
        nodeId: nodeId,
        timestamp: DateTime.now(),
        success: true,
      );
      _isolationController.add(event);

      return true;
    } catch (e) {
      print('Greška pri reintegraciji čvora $nodeId: $e');
      return false;
    }
  }

  /// Proverava da li je čvor izolovan
  bool isNodeIsolated(String nodeId) => _isolatedNodeIds.contains(nodeId);

  /// Vraća razlog izolacije za čvor
  IsolationReason? getIsolationReason(String nodeId) =>
      _isolationReasons[nodeId];

  /// Vraća listu svih izolovanih čvorova
  Set<String> getIsolatedNodes() => Set.from(_isolatedNodeIds);

  /// Izvršava stvarnu izolaciju čvora
  Future<bool> _executeIsolation(String nodeId) async {
    // TODO: Implementirati stvarnu izolaciju čvora iz mreže
    // 1. Prekini sve aktivne konekcije
    // 2. Blokiraj nove konekcije
    // 3. Obavesti susedne čvorove
    return true;
  }

  /// Izvršava stvarnu reintegraciju čvora
  Future<bool> _executeReintegration(String nodeId) async {
    // TODO: Implementirati stvarnu reintegraciju čvora u mrežu
    // 1. Proveri stanje čvora
    // 2. Uspostavi nove konekcije
    // 3. Obavesti susedne čvorove
    return true;
  }

  /// Ažurira razlog izolacije za čvor
  void _updateIsolationReason(String nodeId, IsolationReason newReason) {
    final currentReason = _isolationReasons[nodeId];
    if (currentReason == null) return;

    // Ažuriraj samo ako je novi razlog ozbiljniji
    if (newReason.severity > currentReason.severity) {
      _isolationReasons[nodeId] = newReason;

      // Emituj događaj ažuriranja
      final event = IsolationUpdateEvent(
        nodeId: nodeId,
        oldReason: currentReason,
        newReason: newReason,
        timestamp: DateTime.now(),
      );
      _isolationController.add(event);
    }
  }

  /// Postavlja tajmer za automatsko vraćanje čvora
  void _scheduleNodeReintegration(String nodeId, Duration duration) {
    Timer(duration, () async {
      // Proveri da li je čvor još uvek izolovan
      if (isNodeIsolated(nodeId)) {
        // Pokušaj reintegraciju
        await reintegrateNode(nodeId);
      }
    });
  }

  /// Čisti resurse
  void dispose() {
    _isolationController.close();
  }
}

/// Razlog izolacije čvora
class IsolationReason {
  final String description;
  final int severity;
  final SecurityEventType eventType;

  const IsolationReason({
    required this.description,
    required this.severity,
    required this.eventType,
  });
}

/// Bazna klasa za događaje izolacije
abstract class IsolationEventBase {
  final String nodeId;
  final DateTime timestamp;

  const IsolationEventBase({
    required this.nodeId,
    required this.timestamp,
  });
}

/// Događaj izolacije čvora
class IsolationEvent extends IsolationEventBase {
  final IsolationReason reason;
  final Duration duration;

  const IsolationEvent({
    required String nodeId,
    required this.reason,
    required DateTime timestamp,
    required this.duration,
  }) : super(nodeId: nodeId, timestamp: timestamp);
}

/// Događaj reintegracije čvora
class ReintegrationEvent extends IsolationEventBase {
  final bool success;

  const ReintegrationEvent({
    required String nodeId,
    required DateTime timestamp,
    required this.success,
  }) : super(nodeId: nodeId, timestamp: timestamp);
}

/// Događaj ažuriranja razloga izolacije
class IsolationUpdateEvent extends IsolationEventBase {
  final IsolationReason oldReason;
  final IsolationReason newReason;

  const IsolationUpdateEvent({
    required String nodeId,
    required this.oldReason,
    required this.newReason,
    required DateTime timestamp,
  }) : super(nodeId: nodeId, timestamp: timestamp);
}
