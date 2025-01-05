import 'dart:async';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'models/attack_type.dart';
import 'models/counter_measure.dart';
import 'models/defense_enums.dart';
import 'secure_logger.dart';

class AdaptiveDefense {
  static final AdaptiveDefense _instance = AdaptiveDefense._internal();
  final SecureLogger _logger = SecureLogger();
  final Random _random = Random.secure();

  // In-memory storage
  final Map<AttackType, List<CounterMeasure>> _effectiveCounterMeasures = {};
  final Map<AttackType, double> _attackSuccessRates = {};
  final Map<String, int> _attackPatterns = {};
  final Map<String, DateTime> _blockedSources = {};

  DefenseMode _currentMode = DefenseMode.normal;
  SystemStatus _systemStatus = SystemStatus.normal;
  bool _initialized = false;
  int _attackCount = 0;
  DateTime? _lastAttackTime;

  factory AdaptiveDefense() {
    return _instance;
  }

  AdaptiveDefense._internal() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_initialized) return;

    try {
      await _logger.initialize();
      _initializeDefaultCounterMeasures();
      _initialized = true;

      await _logger.structuredLog(
        event: 'adaptive_defense_initialized',
        level: LogLevel.info,
        data: {
          'mode': _currentMode.toString(),
          'status': _systemStatus.toString(),
        },
      );
    } catch (e, stack) {
      await _logger.structuredLog(
        event: 'initialization_error',
        level: LogLevel.error,
        data: {'error': e.toString()},
        stackTrace: stack,
      );
    }
  }

  void _initializeDefaultCounterMeasures() {
    for (var type in AttackType.values) {
      _effectiveCounterMeasures[type] = DefaultCounterMeasures.getAll();
      _attackSuccessRates[type] = 0.0;
    }
  }

  Future<void> detectAttack(AttackType type, String source,
      {Map<String, dynamic>? additionalData}) async {
    if (!_initialized) await _initialize();

    try {
      _attackCount++;
      _lastAttackTime = DateTime.now();

      await _logger.structuredLog(
        event: 'attack_detected',
        level: LogLevel.warning,
        data: {
          'type': type.toString(),
          'source': source,
          'count': _attackCount,
          'additional_data': additionalData,
        },
      );

      // Primeni kontra-mere
      final measures = _selectCounterMeasures(type);
      for (var measure in measures) {
        await _applyCounterMeasure(measure, source);
      }

      // Ažuriraj mod odbrane
      await _updateDefenseMode(type);

      // Uči iz napada
      await _learnFromAttack(type, source);
    } catch (e, stack) {
      await _logger.structuredLog(
        event: 'attack_handling_error',
        level: LogLevel.error,
        data: {'error': e.toString()},
        stackTrace: stack,
      );
    }
  }

  List<CounterMeasure> _selectCounterMeasures(AttackType type) {
    var measures = _effectiveCounterMeasures[type] ?? [];
    if (measures.isEmpty) {
      return DefaultCounterMeasures.getAll();
    }

    measures.sort((a, b) => b.effectiveness.compareTo(a.effectiveness));
    return measures.take(3).toList();
  }

  Future<void> _applyCounterMeasure(
      CounterMeasure measure, String source) async {
    try {
      switch (measure.type) {
        case CounterMeasureType.encryption:
          await _enhanceEncryption();
          break;
        case CounterMeasureType.deception:
          await _deployDeception();
          break;
        case CounterMeasureType.blocking:
          await _blockSource(source);
          break;
        case CounterMeasureType.backup:
          await _createHiddenBackup();
          break;
        case CounterMeasureType.mutation:
          await _mutateSystem();
          break;
      }

      await _logger.structuredLog(
        event: 'counter_measure_applied',
        level: LogLevel.info,
        data: {
          'measure': measure.name,
          'effectiveness': measure.effectiveness,
        },
      );
    } catch (e, stack) {
      await _logger.structuredLog(
        event: 'counter_measure_error',
        level: LogLevel.error,
        data: {'error': e.toString()},
        stackTrace: stack,
      );
    }
  }

  Future<void> _updateDefenseMode(AttackType type) async {
    var newMode = _currentMode;

    switch (type) {
      case AttackType.bruteForce:
        newMode = DefenseMode.suspicious;
        break;
      case AttackType.injection:
        newMode = DefenseMode.defensive;
        break;
      case AttackType.mitm:
        newMode = DefenseMode.aggressive;
        break;
      case AttackType.dos:
        newMode = DefenseMode.deceptive;
        break;
      case AttackType.multiple:
        newMode = DefenseMode.mutated;
        break;
      case AttackType.replay:
        newMode = DefenseMode.defensive;
        break;
    }

    if (newMode != _currentMode) {
      _currentMode = newMode;
      await _logger.structuredLog(
        event: 'defense_mode_changed',
        level: LogLevel.warning,
        data: {'new_mode': newMode.toString()},
      );
    }
  }

  Future<void> _learnFromAttack(AttackType type, String source) async {
    try {
      _systemStatus = SystemStatus.learning;

      // Ažuriraj obrasce napada
      final patternHash = _calculatePatternHash(type, source);
      _attackPatterns[patternHash] = (_attackPatterns[patternHash] ?? 0) + 1;

      // Ažuriraj stope uspešnosti
      _attackSuccessRates[type] = _calculateNewSuccessRate(type);

      _systemStatus = SystemStatus.normal;
    } catch (e, stack) {
      await _logger.structuredLog(
        event: 'learning_error',
        level: LogLevel.error,
        data: {'error': e.toString()},
        stackTrace: stack,
      );
    }
  }

  String _calculatePatternHash(AttackType type, String source) {
    final data = utf8.encode('$type:$source:${DateTime.now().day}');
    return sha256.convert(data).toString();
  }

  double _calculateNewSuccessRate(AttackType type) {
    final currentRate = _attackSuccessRates[type] ?? 0.0;
    final randomFactor = _random.nextDouble() * 0.1; // 10% varijacija
    return (currentRate + randomFactor).clamp(0.0, 1.0);
  }

  Future<void> _enhanceEncryption() async {
    await _logger.structuredLog(
      event: 'encryption_enhanced',
      level: LogLevel.info,
      data: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  Future<void> _deployDeception() async {
    await _logger.structuredLog(
      event: 'deception_deployed',
      level: LogLevel.info,
      data: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  Future<void> _blockSource(String source) async {
    _blockedSources[source] = DateTime.now();
    await _logger.structuredLog(
      event: 'source_blocked',
      level: LogLevel.warning,
      data: {'source': source},
    );
  }

  Future<void> _createHiddenBackup() async {
    await _logger.structuredLog(
      event: 'hidden_backup_created',
      level: LogLevel.info,
      data: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  Future<void> _mutateSystem() async {
    _systemStatus = SystemStatus.mutating;

    await _logger.structuredLog(
      event: 'system_mutation_started',
      level: LogLevel.warning,
      data: {'timestamp': DateTime.now().toIso8601String()},
    );

    // Simulacija mutacije
    await Future.delayed(const Duration(seconds: 2));

    _systemStatus = SystemStatus.normal;
    await _logger.structuredLog(
      event: 'system_mutation_completed',
      level: LogLevel.info,
      data: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  Future<void> simulateMultipleAttacks() async {
    await detectAttack(AttackType.bruteForce, "TestSource");
    await detectAttack(AttackType.injection, "TestSource");
    await detectAttack(AttackType.mitm, "TestSource");
    await detectAttack(AttackType.dos, "TestSource");
    await detectAttack(AttackType.replay, "TestSource");
    await detectAttack(AttackType.multiple, "TestSource");
  }

  bool isSourceBlocked(String source) {
    final blockTime = _blockedSources[source];
    if (blockTime == null) return false;

    // Blokiranje traje 24 sata
    return DateTime.now().difference(blockTime).inHours < 24;
  }

  // Public methods for MutatedDefense
  Future<List<CounterMeasure>> suggestCounterMeasures(AttackType type) async {
    return _selectCounterMeasures(type);
  }

  Future<Map<String, int>> getAttackPatterns() async {
    return Map.unmodifiable(_attackPatterns);
  }

  Future<void> learnFromAttack(AttackType type, String source) async {
    await _learnFromAttack(type, source);
  }

  // Getteri za trenutno stanje
  DefenseMode get currentMode => _currentMode;
  SystemStatus get systemStatus => _systemStatus;
  int get attackCount => _attackCount;
  DateTime? get lastAttackTime => _lastAttackTime;
  Map<String, int> get attackPatterns => Map.unmodifiable(_attackPatterns);

  Future<void> dispose() async {
    await _logger.dispose();
    _initialized = false;
  }
}
