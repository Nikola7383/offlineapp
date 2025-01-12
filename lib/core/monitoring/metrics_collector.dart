import 'dart:async';
import 'package:injectable/injectable.dart';
import '../interfaces/metrics_collector_interface.dart';
import '../interfaces/logger_service.dart';
import 'metric_exporter.dart';

@LazySingleton(as: IMetricsCollector)
class MetricsCollector implements IMetricsCollector {
  final ILoggerService _logger;
  final Map<String, Metric> _metrics = {};
  final List<MetricExporter> _exporters = [];
  Timer? _exportTimer;

  MetricsCollector(this._logger);

  @override
  Future<void> initialize() async {
    _logger.info('Initializing MetricsCollector');
    _startExporting();
  }

  @override
  Future<void> dispose() async {
    _exportTimer?.cancel();
    _logger.info('MetricsCollector disposed');
  }

  @override
  void track(String name, double value, {Map<String, String>? tags}) {
    final metric = _metrics.putIfAbsent(
      name,
      () => Metric(name),
    );

    metric.addValue(value, tags: tags);
    _logger.debug('Tracked metric: $name = $value');
  }

  @override
  void addExporter(MetricExporter exporter) {
    _exporters.add(exporter);
    _logger.info('Added new metric exporter');
  }

  @override
  Map<String, MetricSnapshot> getSnapshot() {
    return _metrics.map(
      (key, metric) => MapEntry(key, metric.getSnapshot()),
    );
  }

  void _startExporting() {
    _exportTimer = Timer.periodic(
      Duration(minutes: 1),
      (_) => _exportMetrics(),
    );
    _logger.info('Started metrics export timer');
  }

  Future<void> _exportMetrics() async {
    try {
      final snapshot = getSnapshot();

      for (final exporter in _exporters) {
        try {
          await exporter.export(snapshot);
        } catch (e, stackTrace) {
          _logger.error('Failed to export metrics', e, stackTrace);
        }
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to export metrics', e, stackTrace);
    }
  }
}

class Metric {
  final String name;
  final List<MetricValue> _values = [];

  Metric(this.name);

  void addValue(double value, {Map<String, String>? tags}) {
    _values.add(MetricValue(value, tags: tags));

    // Ograniči broj vrednosti na poslednjih 1000
    if (_values.length > 1000) {
      _values.removeRange(0, _values.length - 1000);
    }
  }

  MetricSnapshot getSnapshot() {
    return MetricSnapshot(
      name: name,
      values: List.from(_values),
    );
  }
}
