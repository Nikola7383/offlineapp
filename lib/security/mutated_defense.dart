import 'dart:async';
import 'dart:math';
import 'models/attack_type.dart';
import 'models/counter_measure.dart';
import 'models/defense_enums.dart';
import 'adaptive_defense.dart';
import 'secure_logger.dart';

class MutatedDefense {
  final AdaptiveDefense _adaptive;
  final SecureLogger _logger = SecureLogger();
  final Random _random = Random.secure();

  DefenseMode _currentMode = DefenseMode.normal;
  SystemStatus _systemStatus = SystemStatus.normal;
  final Map<String, int> _mutationHistory = {};
  int _attackCount = 0;
  DateTime? _lastAttackTime;

  MutatedDefense(this._adaptive);

  Future<void> detectAttack(AttackType type,
      [String source = "Unknown"]) async {
    await handleAttack(type, source);
  }

  Future<void> handleAttack(AttackType type, String source) async {
    try {
      final startTime = DateTime.now();
      _attackCount++;
      _lastAttackTime = startTime;

      await _logger.structuredLog(
        event: 'attack_handling',
        level: LogLevel.warning,
        data: {
          'status': 'started',
          'type': type.toString(),
          'source': source,
          'attack_count': _attackCount,
        },
      );

      // Prvo pustimo adaptivnu odbranu
      await _adaptive.detectAttack(type, source);

      // Zatim primenjujemo mutirane strategije
      await _applyMutatedStrategy(type, source);

      final endTime = DateTime.now();
      await _logger.structuredLog(
        event: 'attack_handling',
        level: LogLevel.info,
        data: {
          'status': 'completed',
          'duration_ms': endTime.difference(startTime).inMilliseconds,
          'final_mode': _currentMode.toString(),
          'measures_applied': _mutationHistory[source],
        },
      );
    } catch (e, stack) {
      await _logger.structuredLog(
        event: 'attack_handling_error',
        level: LogLevel.error,
        data: {
          'error': e.toString(),
          'attack_count': _attackCount,
          'last_attack': _lastAttackTime?.toIso8601String(),
        },
        stackTrace: stack,
      );
    }
  }

  Future<void> simulateMultipleAttacks() async {
    try {
      _systemStatus = SystemStatus.mutating;
      final startTime = DateTime.now();

      await _logger.structuredLog(
        event: 'multiple_attacks_simulation',
        level: LogLevel.warning,
        data: {
          'status': 'started',
          'timestamp': startTime.toIso8601String(),
        },
      );

      final attacks = [
        AttackType.bruteForce,
        AttackType.injection,
        AttackType.mitm,
        AttackType.dos,
        AttackType.replay,
        AttackType.multiple,
      ];

      for (var type in attacks) {
        await handleAttack(type, "SimulatedSource");
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final endTime = DateTime.now();
      _systemStatus = SystemStatus.normal;

      await _logger.structuredLog(
        event: 'multiple_attacks_simulation',
        level: LogLevel.info,
        data: {
          'status': 'completed',
          'total_attacks': attacks.length,
          'duration_ms': endTime.difference(startTime).inMilliseconds,
          'final_mode': _currentMode.toString(),
          'total_mutations': _mutationHistory.length,
        },
      );
    } catch (e, stack) {
      _systemStatus = SystemStatus.normal;
      await _logger.structuredLog(
        event: 'simulation_error',
        level: LogLevel.error,
        data: {'error': e.toString()},
        stackTrace: stack,
      );
    }
  }

  Future<void> _applyMutatedStrategy(AttackType type, String source) async {
    try {
      final startTime = DateTime.now();
      final risk = await _calculateRisk(type, source);

      await _logger.structuredLog(
        event: 'strategy_execution',
        level: LogLevel.info,
        data: {
          'status': 'started',
          'type': type.toString(),
          'source': source,
          'risk_level': risk,
          'current_mode': _currentMode.toString(),
        },
      );

      if (risk > 0.8) {
        await _executeHighRiskStrategy(type, source);
      } else if (risk > 0.5) {
        await _executeMediumRiskStrategy(type, source);
      } else {
        await _executeLowRiskStrategy(type, source);
      }

      final endTime = DateTime.now();
      await _logger.structuredLog(
        event: 'strategy_execution',
        level: LogLevel.info,
        data: {
          'status': 'completed',
          'duration_ms': endTime.difference(startTime).inMilliseconds,
          'final_mode': _currentMode.toString(),
          'measures_applied': _mutationHistory[source],
        },
      );
    } catch (e, stack) {
      await _logger.structuredLog(
        event: 'strategy_execution_error',
        level: LogLevel.error,
        data: {'error': e.toString()},
        stackTrace: stack,
      );
    }
  }

  Future<double> _calculateRisk(AttackType type, String source) async {
    try {
      double risk = 0.0;

      double baseRisk = type.baseRisk;
      risk += baseRisk * 0.4;

      final pattern = await _adaptive.getAttackPatterns();
      final historyRisk = (pattern[source] ?? 0) / 100.0;
      risk += historyRisk * 0.3;

      final modeRisk = _calculateModeRisk();
      risk += modeRisk * 0.3;

      return risk.clamp(0.0, 1.0);
    } catch (e, stack) {
      await _logger.structuredLog(
        event: 'risk_calculation_error',
        level: LogLevel.error,
        data: {'error': e.toString()},
        stackTrace: stack,
      );
      return 0.5;
    }
  }

  double _calculateModeRisk() {
    switch (_currentMode) {
      case DefenseMode.normal:
        return 0.2;
      case DefenseMode.suspicious:
        return 0.4;
      case DefenseMode.defensive:
        return 0.6;
      case DefenseMode.aggressive:
        return 0.8;
      case DefenseMode.deceptive:
        return 0.7;
      case DefenseMode.mutated:
        return 0.9;
    }
  }

  Future<void> _executeHighRiskStrategy(AttackType type, String source) async {
    try {
      final measures = await _adaptive.suggestCounterMeasures(type);
      int appliedCount = 0;

      for (var measure in measures) {
        if (measure.effectiveness > 0.7) {
          await _applyMutatedCounterMeasure(measure, source);
          appliedCount++;
        }
      }

      _currentMode = DefenseMode.aggressive;

      await _logger.structuredLog(
        event: 'high_risk_strategy',
        level: LogLevel.warning,
        data: {
          'measures_applied': appliedCount,
          'total_measures': measures.length,
          'final_mode': _currentMode.toString(),
        },
      );
    } catch (e, stack) {
      await _logger.structuredLog(
        event: 'high_risk_strategy_error',
        level: LogLevel.error,
        data: {'error': e.toString()},
        stackTrace: stack,
      );
    }
  }

  Future<void> _executeMediumRiskStrategy(
      AttackType type, String source) async {
    try {
      final measures = await _adaptive.suggestCounterMeasures(type);
      int appliedCount = 0;

      for (var measure in measures) {
        if (measure.effectiveness > 0.5) {
          await _applyMutatedCounterMeasure(measure, source);
          appliedCount++;
        }
      }

      _currentMode = DefenseMode.defensive;

      await _logger.structuredLog(
        event: 'medium_risk_strategy',
        level: LogLevel.info,
        data: {
          'measures_applied': appliedCount,
          'total_measures': measures.length,
          'final_mode': _currentMode.toString(),
        },
      );
    } catch (e, stack) {
      await _logger.structuredLog(
        event: 'medium_risk_strategy_error',
        level: LogLevel.error,
        data: {'error': e.toString()},
        stackTrace: stack,
      );
    }
  }

  Future<void> _executeLowRiskStrategy(AttackType type, String source) async {
    try {
      final measures = await _adaptive.suggestCounterMeasures(type);
      if (measures.isNotEmpty) {
        await _applyMutatedCounterMeasure(measures.first, source);
      }

      _currentMode = DefenseMode.suspicious;

      await _logger.structuredLog(
        event: 'low_risk_strategy',
        level: LogLevel.info,
        data: {
          'measures_applied': 1,
          'total_measures': measures.length,
          'final_mode': _currentMode.toString(),
        },
      );
    } catch (e, stack) {
      await _logger.structuredLog(
        event: 'low_risk_strategy_error',
        level: LogLevel.error,
        data: {'error': e.toString()},
        stackTrace: stack,
      );
    }
  }

  Future<void> _applyMutatedCounterMeasure(
      CounterMeasure measure, String source) async {
    try {
      _systemStatus = SystemStatus.mutating;
      final startTime = DateTime.now();

      final mutatedMeasure = _mutateMeasure(measure);
      await _adaptive.detectAttack(AttackType.multiple, source);

      final endTime = DateTime.now();
      await _logger.structuredLog(
        event: 'counter_measure_mutation',
        level: LogLevel.info,
        data: {
          'original_measure': measure.name,
          'original_effectiveness': measure.effectiveness,
          'mutated_effectiveness': mutatedMeasure.effectiveness,
          'duration_ms': endTime.difference(startTime).inMilliseconds,
        },
      );

      _systemStatus = SystemStatus.normal;
    } catch (e, stack) {
      await _logger.structuredLog(
        event: 'counter_measure_mutation_error',
        level: LogLevel.error,
        data: {'error': e.toString()},
        stackTrace: stack,
      );
    }
  }

  CounterMeasure _mutateMeasure(CounterMeasure original) {
    final effectivenessVariation = _random.nextDouble() * 0.2 - 0.1;
    final newEffectiveness =
        (original.effectiveness + effectivenessVariation).clamp(0.0, 1.0);

    return CounterMeasure(
      type: original.type,
      name: original.name,
      effectiveness: newEffectiveness,
      resourceCost: original.resourceCost + 1,
      timesUsed: original.timesUsed + 1,
    );
  }

  void _updateMutationHistory(String source) {
    _mutationHistory[source] = (_mutationHistory[source] ?? 0) + 1;
  }

  Future<void> dispose() async {
    try {
      final stats = {
        'total_attacks': _attackCount,
        'total_mutations': _mutationHistory.length,
        'final_mode': _currentMode.toString(),
        'final_status': _systemStatus.toString(),
      };

      // Očisti resurse
      _mutationHistory.clear();
      _currentMode = DefenseMode.normal;
      _systemStatus = SystemStatus.normal;
      _attackCount = 0;
      _lastAttackTime = null;

      // Logiraj finalno stanje
      await _logger.structuredLog(
        event: 'defense_system_disposed',
        level: LogLevel.info,
        data: stats,
      );

      // Očisti logger
      await _logger.dispose();
    } catch (e, stack) {
      print('Error disposing MutatedDefense: $e');
      print('Stack trace: $stack');
    }
  }

  // Getteri
  DefenseMode get currentMode => _currentMode;
  SystemStatus get systemStatus => _systemStatus;
  Map<String, int> get mutationHistory => Map.unmodifiable(_mutationHistory);
  int get attackCount => _attackCount;
  DateTime? get lastAttackTime => _lastAttackTime;
}
