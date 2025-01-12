import 'base_service.dart';

/// Tip metrike u sistemu
enum MetricType { counter, gauge, histogram, summary }

/// Predstavlja pojedinačnu metriku
class Metric {
  final String name;
  final MetricType type;
  final double value;
  final Map<String, String>? labels;
  final DateTime timestamp;

  const Metric({
    required this.name,
    required this.type,
    required this.value,
    this.labels,
    required this.timestamp,
  });
}

/// Interfejs za prikupljanje metrika
abstract class IMetricsCollector implements IService {
  /// Beleži vrednost metrike
  Future<void> recordMetric(String name, double value,
      {MetricType type = MetricType.gauge, Map<String, String>? labels});

  /// Inkrementira brojač
  Future<void> incrementCounter(String name,
      {double increment = 1, Map<String, String>? labels});

  /// Postavlja vrednost pokazivača
  Future<void> setGauge(String name, double value,
      {Map<String, String>? labels});

  /// Beleži vrednost u histogram
  Future<void> observeHistogram(String name, double value,
      {Map<String, String>? labels});

  /// Vraća sve metrike
  Future<List<Metric>> getMetrics();

  /// Vraća vrednost specifične metrike
  Future<double?> getMetricValue(String name, {Map<String, String>? labels});

  /// Briše metriku
  Future<void> deleteMetric(String name);

  /// Briše sve metrike
  Future<void> clearMetrics();
}
