import 'dart:async';
import 'dart:math';
import '../encryption/encryption_service.dart';
import '../../mesh/models/node.dart';

/// Upravlja generisanjem i distribucijom lažnog saobraćaja u mreži
class DecoyTrafficManager {
  final EncryptionService _encryptionService;
  final _trafficController = StreamController<DecoyTrafficEvent>.broadcast();

  // Aktivni lažni saobraćaj
  final Map<String, DecoyTrafficConfig> _activeTraffic = {};

  // Generator slučajnih brojeva
  final _random = Random.secure();

  // Konstante
  static const int MAX_ACTIVE_STREAMS = 10;
  static const Duration MIN_INTERVAL = Duration(seconds: 5);
  static const Duration MAX_INTERVAL = Duration(seconds: 30);

  Stream<DecoyTrafficEvent> get trafficStream => _trafficController.stream;

  DecoyTrafficManager({
    required EncryptionService encryptionService,
  }) : _encryptionService = encryptionService;

  /// Pokreće generisanje lažnog saobraćaja
  Future<void> startDecoyTraffic({
    required String sourceNodeId,
    required Set<String> targetNodeIds,
    required DecoyTrafficType type,
    Duration? customInterval,
  }) async {
    if (_activeTraffic.length >= MAX_ACTIVE_STREAMS) {
      _stopLeastImportantTraffic();
    }

    final config = DecoyTrafficConfig(
      type: type,
      sourceNodeId: sourceNodeId,
      targetNodeIds: targetNodeIds,
      interval: customInterval ?? _calculateInterval(type),
      startTime: DateTime.now(),
    );

    final streamId = _generateStreamId();
    _activeTraffic[streamId] = config;

    // Pokreni periodično generisanje saobraćaja
    _startTrafficGeneration(streamId, config);
  }

  /// Zaustavlja generisanje lažnog saobraćaja
  void stopDecoyTraffic(String streamId) {
    _activeTraffic.remove(streamId);
  }

  /// Generiše ID za novi stream
  String _generateStreamId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(10000);
    return 'decoy${timestamp}_$random';
  }

  /// Računa interval za generisanje saobraćaja
  Duration _calculateInterval(DecoyTrafficType type) {
    switch (type) {
      case DecoyTrafficType.criticalMessage:
        return MIN_INTERVAL;
      case DecoyTrafficType.routineSync:
        return Duration(
          seconds: MIN_INTERVAL.inSeconds +
              _random.nextInt(MAX_INTERVAL.inSeconds - MIN_INTERVAL.inSeconds),
        );
      case DecoyTrafficType.backgroundNoise:
        return MAX_INTERVAL;
    }
  }

  /// Zaustavlja najmanje važan saobraćaj
  void _stopLeastImportantTraffic() {
    if (_activeTraffic.isEmpty) return;

    // Pronađi stream sa najmanjim prioritetom
    final leastImportant = _activeTraffic.entries.reduce((a, b) =>
        _getTypePriority(a.value.type) <= _getTypePriority(b.value.type)
            ? a
            : b);

    stopDecoyTraffic(leastImportant.key);
  }

  /// Vraća prioritet tipa saobraćaja
  int _getTypePriority(DecoyTrafficType type) {
    switch (type) {
      case DecoyTrafficType.criticalMessage:
        return 3;
      case DecoyTrafficType.routineSync:
        return 2;
      case DecoyTrafficType.backgroundNoise:
        return 1;
    }
  }

  /// Pokreće periodično generisanje saobraćaja
  void _startTrafficGeneration(String streamId, DecoyTrafficConfig config) {
    Timer.periodic(config.interval, (timer) async {
      if (!_activeTraffic.containsKey(streamId)) {
        timer.cancel();
        return;
      }

      await _generateAndSendTraffic(streamId, config);
    });
  }

  /// Generiše i šalje lažni saobraćaj
  Future<void> _generateAndSendTraffic(
    String streamId,
    DecoyTrafficConfig config,
  ) async {
    try {
      final payload = await _generateDecoyPayload(config.type);
      final encryptedPayload = await _encryptionService.encrypt(payload);

      // Odaberi nasumičnog primaoca iz seta ciljanih čvorova
      final targetNodeId = config.targetNodeIds
          .elementAt(_random.nextInt(config.targetNodeIds.length));

      final event = DecoyTrafficEvent(
        streamId: streamId,
        sourceNodeId: config.sourceNodeId,
        targetNodeId: targetNodeId,
        type: config.type,
        timestamp: DateTime.now(),
        payload: encryptedPayload,
      );

      _trafficController.add(event);
    } catch (e) {
      print('Greška pri generisanju lažnog saobraćaja: $e');
    }
  }

  /// Generiše lažni payload na osnovu tipa saobraćaja
  Future<String> _generateDecoyPayload(DecoyTrafficType type) async {
    switch (type) {
      case DecoyTrafficType.criticalMessage:
        return _generateCriticalMessage();
      case DecoyTrafficType.routineSync:
        return _generateRoutineSync();
      case DecoyTrafficType.backgroundNoise:
        return _generateBackgroundNoise();
    }
  }

  /// Generiše lažnu kritičnu poruku
  String _generateCriticalMessage() {
    final actions = ['ALERT', 'WARNING', 'CRITICAL', 'EMERGENCY'];
    final subjects = ['SYSTEM', 'NETWORK', 'SECURITY', 'RESOURCE'];

    final action = actions[_random.nextInt(actions.length)];
    final subject = subjects[_random.nextInt(subjects.length)];
    final timestamp = DateTime.now().toIso8601String();

    return '$action:$subject:$timestamp';
  }

  /// Generiše lažnu rutinsku sinhronizaciju
  String _generateRoutineSync() {
    final types = ['HEARTBEAT', 'STATUS', 'SYNC', 'UPDATE'];
    final type = types[_random.nextInt(types.length)];
    final status = _random.nextInt(100);

    return '$type:STATUS=$status';
  }

  /// Generiše lažni pozadinski šum
  String _generateBackgroundNoise() {
    final length = _random.nextInt(100) + 50; // 50-150 karaktera
    final buffer = StringBuffer();

    for (var i = 0; i < length; i++) {
      buffer.write(String.fromCharCode(_random.nextInt(26) + 65));
    }

    return buffer.toString();
  }

  /// Čisti resurse
  void dispose() {
    _trafficController.close();
  }
}

/// Tip lažnog saobraćaja
enum DecoyTrafficType {
  criticalMessage, // Lažne kritične poruke
  routineSync, // Rutinske sinhronizacije
  backgroundNoise, // Pozadinski šum
}

/// Konfiguracija lažnog saobraćaja
class DecoyTrafficConfig {
  final DecoyTrafficType type;
  final String sourceNodeId;
  final Set<String> targetNodeIds;
  final Duration interval;
  final DateTime startTime;

  const DecoyTrafficConfig({
    required this.type,
    required this.sourceNodeId,
    required this.targetNodeIds,
    required this.interval,
    required this.startTime,
  });
}

/// Događaj lažnog saobraćaja
class DecoyTrafficEvent {
  final String streamId;
  final String sourceNodeId;
  final String targetNodeId;
  final DecoyTrafficType type;
  final DateTime timestamp;
  final String payload;

  const DecoyTrafficEvent({
    required this.streamId,
    required this.sourceNodeId,
    required this.targetNodeId,
    required this.type,
    required this.timestamp,
    required this.payload,
  });
}
