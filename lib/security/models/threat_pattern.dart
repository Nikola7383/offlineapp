import 'security_event.dart';

/// Model koji predstavlja obrazac pretnje u sistemu
class ThreatPattern {
  final String name;
  final String description;
  final double severity;
  final List<SecurityEventType> sequence;
  final Duration timeWindow;
  final Map<String, dynamic>? conditions;

  const ThreatPattern({
    required this.name,
    required this.description,
    required this.severity,
    required this.sequence,
    required this.timeWindow,
    this.conditions,
  });

  /// Proverava da li se istorija događaja poklapa sa obrascem
  bool matches(List<SecurityEvent> history) {
    if (history.length < sequence.length) return false;

    // Uzmi poslednje događaje koji odgovaraju dužini sekvence
    final recentEvents =
        history.skip(history.length - sequence.length).toList();

    // Proveri vremenski okvir
    final timeSpan =
        recentEvents.last.timestamp.difference(recentEvents.first.timestamp);
    if (timeSpan > timeWindow) return false;

    // Proveri da li se sekvenca poklapa
    for (var i = 0; i < sequence.length; i++) {
      if (recentEvents[i].type != sequence[i]) return false;
    }

    // Proveri dodatne uslove ako postoje
    if (conditions != null) {
      return _checkConditions(recentEvents);
    }

    return true;
  }

  /// Proverava dodatne uslove za obrazac
  bool _checkConditions(List<SecurityEvent> events) {
    if (conditions == null) return true;

    // Proveri specifične uslove
    for (var condition in conditions!.entries) {
      switch (condition.key) {
        case 'minSeverity':
          if (!_checkSeverityCondition(events, condition.value as double)) {
            return false;
          }
          break;
        case 'sourceCount':
          if (!_checkSourceCountCondition(events, condition.value as int)) {
            return false;
          }
          break;
        case 'requireDetails':
          if (!_checkDetailsCondition(
              events, condition.value as List<String>)) {
            return false;
          }
          break;
      }
    }

    return true;
  }

  /// Proverava uslov minimalne ozbiljnosti događaja
  bool _checkSeverityCondition(List<SecurityEvent> events, double minSeverity) {
    return events.every((e) => e.severity >= minSeverity);
  }

  /// Proverava uslov broja različitih izvora
  bool _checkSourceCountCondition(List<SecurityEvent> events, int count) {
    final sources = events.map((e) => e.sourceId).toSet();
    return sources.length >= count;
  }

  /// Proverava uslov postojanja određenih detalja
  bool _checkDetailsCondition(
      List<SecurityEvent> events, List<String> requiredDetails) {
    return events.every((e) {
      if (e.details == null) return false;
      return requiredDetails.every((key) => e.details!.containsKey(key));
    });
  }

  /// Kreira kopiju obrasca sa novim vrednostima
  ThreatPattern copyWith({
    String? name,
    String? description,
    double? severity,
    List<SecurityEventType>? sequence,
    Duration? timeWindow,
    Map<String, dynamic>? conditions,
  }) {
    return ThreatPattern(
      name: name ?? this.name,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      sequence: sequence ?? this.sequence,
      timeWindow: timeWindow ?? this.timeWindow,
      conditions: conditions ?? this.conditions,
    );
  }

  /// Kreira obrazac iz JSON mape
  factory ThreatPattern.fromJson(Map<String, dynamic> json) {
    return ThreatPattern(
      name: json['name'] as String,
      description: json['description'] as String,
      severity: (json['severity'] as num).toDouble(),
      sequence: (json['sequence'] as List<dynamic>)
          .map(
            (e) => SecurityEventType.values.firstWhere(
              (type) => type.toString() == 'SecurityEventType.$e',
            ),
          )
          .toList(),
      timeWindow: Duration(milliseconds: json['timeWindow'] as int),
      conditions: json['conditions'] as Map<String, dynamic>?,
    );
  }

  /// Konvertuje obrazac u JSON mapu
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'severity': severity,
      'sequence': sequence.map((e) => e.toString().split('.').last).toList(),
      'timeWindow': timeWindow.inMilliseconds,
      if (conditions != null) 'conditions': conditions,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThreatPattern &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          severity == other.severity;

  @override
  int get hashCode => name.hashCode ^ description.hashCode ^ severity.hashCode;

  @override
  String toString() {
    return 'ThreatPattern(name: $name, severity: ${severity.toStringAsFixed(2)}, '
        'sequence: ${sequence.length} events)';
  }
}
