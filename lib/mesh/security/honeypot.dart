import 'dart:async';
import 'dart:math';
import 'security_types.dart';

class HoneypotSystem {
  final Map<String, _HoneypotNode> _honeypots = {};
  final StreamController<SecurityEvent> _eventController =
      StreamController.broadcast();
  final Random _random = Random.secure();

  // Parametri za detekciju napada
  static const int MAX_ATTEMPTS = 3;
  static const Duration RESET_INTERVAL = Duration(minutes: 30);
  static const int MIN_HONEYPOTS = 2;
  static const int MAX_HONEYPOTS = 5;

  HoneypotSystem() {
    _initializeHoneypots();
    _startResetTimer();
  }

  /// Inicijalizuje honeypot čvorove
  void _initializeHoneypots() {
    final count =
        MIN_HONEYPOTS + _random.nextInt(MAX_HONEYPOTS - MIN_HONEYPOTS);

    for (var i = 0; i < count; i++) {
      final id = _generateHoneypotId();
      _honeypots[id] = _HoneypotNode(
        id: id,
        createdAt: DateTime.now(),
        attractiveness: _random.nextDouble(),
      );
    }
  }

  /// Generiše ID koji izgleda primamljivo za napadače
  String _generateHoneypotId() {
    final types = ['admin', 'root', 'system', 'backup', 'master'];
    final suffix = _random.nextInt(999).toString().padLeft(3, '0');
    return '${types[_random.nextInt(types.length)]}_$suffix';
  }

  /// Proverava da li je čvor honeypot
  bool isHoneypot(String nodeId) {
    return _honeypots.containsKey(nodeId);
  }

  /// Beleži pokušaj pristupa honeypot čvoru
  void recordAttempt(String nodeId, String sourceId, List<int> data) {
    final honeypot = _honeypots[nodeId];
    if (honeypot == null) return;

    honeypot.recordAttempt(sourceId, data);

    if (honeypot.isCompromised) {
      _handleCompromise(honeypot, sourceId);
    }
  }

  /// Obrađuje kompromitovanje honeypot-a
  void _handleCompromise(
    _HoneypotNode honeypot,
    String attackerId,
  ) {
    final event = SecurityEvent.attackDetected;
    _eventController.add(event);

    // Analiziraj obrazac napada
    final pattern = _analyzeAttackPattern(honeypot.attempts);

    // Generiši lažne podatke koji će zbuniti napadača
    final deceptionData = _generateDeceptionData(pattern);

    // Ažuriraj honeypot sa lažnim podacima
    honeypot.updateDeceptionData(deceptionData);
  }

  /// Analizira obrazac napada
  _AttackPattern _analyzeAttackPattern(List<_AttackAttempt> attempts) {
    final commandPatterns = <String, int>{};
    final timePatterns = <Duration, int>{};

    for (var i = 1; i < attempts.length; i++) {
      final current = attempts[i];
      final previous = attempts[i - 1];

      // Analiziraj komande
      final command = String.fromCharCodes(current.data.take(10));
      commandPatterns[command] = (commandPatterns[command] ?? 0) + 1;

      // Analiziraj vremenske razmake
      final timeDiff = current.timestamp.difference(previous.timestamp);
      timePatterns[timeDiff] = (timePatterns[timeDiff] ?? 0) + 1;
    }

    return _AttackPattern(
      commonCommands: commandPatterns,
      timeIntervals: timePatterns,
    );
  }

  /// Generiše lažne podatke na osnovu obrasca napada
  List<int> _generateDeceptionData(_AttackPattern pattern) {
    // Generiši podatke koji izgledaju legitimno ali su lažni
    final mostCommonCommand = pattern.commonCommands.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return [
      ...mostCommonCommand.codeUnits,
      ...List.generate(32, (_) => _random.nextInt(256)),
    ];
  }

  /// Periodično resetuje honeypot-ove
  void _startResetTimer() {
    Timer.periodic(RESET_INTERVAL, (_) {
      _honeypots.removeWhere((_, pot) => pot.isExpired);
      if (_honeypots.length < MIN_HONEYPOTS) {
        _initializeHoneypots();
      }
    });
  }

  /// Stream bezbednosnih događaja
  Stream<SecurityEvent> get securityEvents => _eventController.stream;

  void dispose() {
    _eventController.close();
  }
}

class _HoneypotNode {
  final String id;
  final DateTime createdAt;
  final double attractiveness;
  final List<_AttackAttempt> attempts = [];
  List<int>? deceptionData;

  _HoneypotNode({
    required this.id,
    required this.createdAt,
    required this.attractiveness,
  });

  void recordAttempt(String sourceId, List<int> data) {
    attempts.add(_AttackAttempt(
      sourceId: sourceId,
      data: data,
      timestamp: DateTime.now(),
    ));
  }

  void updateDeceptionData(List<int> data) {
    deceptionData = data;
  }

  bool get isCompromised => attempts.length >= HoneypotSystem.MAX_ATTEMPTS;

  bool get isExpired =>
      DateTime.now().difference(createdAt) > HoneypotSystem.RESET_INTERVAL;
}

class _AttackAttempt {
  final String sourceId;
  final List<int> data;
  final DateTime timestamp;

  _AttackAttempt({
    required this.sourceId,
    required this.data,
    required this.timestamp,
  });
}

class _AttackPattern {
  final Map<String, int> commonCommands;
  final Map<Duration, int> timeIntervals;

  _AttackPattern({
    required this.commonCommands,
    required this.timeIntervals,
  });
}
