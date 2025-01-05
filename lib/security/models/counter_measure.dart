import 'package:flutter/foundation.dart';

enum CounterMeasureType { encryption, deception, blocking, backup, mutation }

@immutable
class CounterMeasure {
  final CounterMeasureType type;
  final String name;
  final double effectiveness;
  final int resourceCost;
  final DateTime created;
  final int timesUsed;
  final int successfulUses;

  CounterMeasure({
    required this.type,
    required this.name,
    required this.effectiveness,
    required this.resourceCost,
    DateTime? created,
    this.timesUsed = 0,
    this.successfulUses = 0,
  }) : created = created ?? DateTime.now();

  CounterMeasure copyWith({
    CounterMeasureType? type,
    String? name,
    double? effectiveness,
    int? resourceCost,
    DateTime? created,
    int? timesUsed,
    int? successfulUses,
  }) {
    return CounterMeasure(
      type: type ?? this.type,
      name: name ?? this.name,
      effectiveness: effectiveness ?? this.effectiveness,
      resourceCost: resourceCost ?? this.resourceCost,
      created: created ?? this.created,
      timesUsed: timesUsed ?? this.timesUsed,
      successfulUses: successfulUses ?? this.successfulUses,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'name': name,
      'effectiveness': effectiveness,
      'resource_cost': resourceCost,
      'created': created.toIso8601String(),
      'times_used': timesUsed,
      'successful_uses': successfulUses,
    };
  }

  factory CounterMeasure.fromMap(Map<String, dynamic> map) {
    return CounterMeasure(
      type: CounterMeasureType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      name: map['name'] as String,
      effectiveness: map['effectiveness'] as double,
      resourceCost: map['resource_cost'] as int,
      created: DateTime.parse(map['created'] as String),
      timesUsed: map['times_used'] as int,
      successfulUses: map['successful_uses'] as int,
    );
  }

  double getCurrentEffectiveness() {
    if (timesUsed == 0) return effectiveness;
    return successfulUses / timesUsed;
  }

  @override
  String toString() {
    return 'CounterMeasure(type: $type, name: $name, effectiveness: $effectiveness, cost: $resourceCost)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CounterMeasure && other.type == type && other.name == name;
  }

  @override
  int get hashCode => type.hashCode ^ name.hashCode;
}

class DefaultCounterMeasures {
  static final List<CounterMeasure> _defaultMeasures = [
    CounterMeasure(
      type: CounterMeasureType.encryption,
      name: 'Enhanced Encryption',
      effectiveness: 0.8,
      resourceCost: 3,
    ),
    CounterMeasure(
      type: CounterMeasureType.deception,
      name: 'Honeypot Deployment',
      effectiveness: 0.7,
      resourceCost: 4,
    ),
    CounterMeasure(
      type: CounterMeasureType.blocking,
      name: 'IP Blocking',
      effectiveness: 0.9,
      resourceCost: 2,
    ),
    CounterMeasure(
      type: CounterMeasureType.backup,
      name: 'Secure Backup',
      effectiveness: 0.6,
      resourceCost: 5,
    ),
    CounterMeasure(
      type: CounterMeasureType.mutation,
      name: 'System Mutation',
      effectiveness: 0.95,
      resourceCost: 8,
    ),
  ];

  static List<CounterMeasure> getAll() {
    return List.from(_defaultMeasures);
  }

  static CounterMeasure getDefault(CounterMeasureType type) {
    return getAll().firstWhere(
      (measure) => measure.type == type,
      orElse: () => CounterMeasure(
        type: CounterMeasureType.blocking,
        name: 'Default Blocking',
        effectiveness: 0.5,
        resourceCost: 1,
      ),
    );
  }
}
