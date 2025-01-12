/// Vrednost metrike sa opcionalnim tagovima
class MetricValue {
  final double value;
  final Map<String, String>? tags;
  final DateTime timestamp;

  MetricValue(this.value, {this.tags}) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
        'value': value,
        'tags': tags,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Snapshot metrike sa svim vrednostima
class MetricSnapshot {
  final String name;
  final List<MetricValue> values;

  MetricSnapshot({
    required this.name,
    required this.values,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'values': values.map((v) => v.toJson()).toList(),
      };
}

/// Apstraktna klasa za eksportovanje metrika
abstract class MetricExporter {
  /// Eksportuje snapshot metrika
  Future<void> export(Map<String, MetricSnapshot> metrics);
}
