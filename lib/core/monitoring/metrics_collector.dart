@injectable
class MetricsCollector extends InjectableService {
  final _metrics = <String, Metric>{};
  final _exporters = <MetricExporter>[];
  Timer? _exportTimer;

  @override
  Future<void> initialize() async {
    await super.initialize();
    _startExporting();
  }

  void track(String name, double value, {Map<String, String>? tags}) {
    final metric = _metrics.putIfAbsent(
      name,
      () => Metric(name),
    );

    metric.addValue(value, tags: tags);
  }

  void addExporter(MetricExporter exporter) {
    _exporters.add(exporter);
  }

  void _startExporting() {
    _exportTimer = Timer.periodic(
      Duration(minutes: 1),
      (_) => _exportMetrics(),
    );
  }

  Future<void> _exportMetrics() async {
    final snapshot = _metrics.map(
      (key, metric) => MapEntry(key, metric.getSnapshot()),
    );

    for (final exporter in _exporters) {
      try {
        await exporter.export(snapshot);
      } catch (e) {
        logger.error('Failed to export metrics', e);
      }
    }
  }

  @override
  Future<void> dispose() async {
    _exportTimer?.cancel();
    await super.dispose();
  }
}

class Metric {
  final String name;
  final List<MetricValue> _values = [];

  Metric(this.name);

  void addValue(double value, {Map<String, String>? tags}) {
    _values.add(MetricValue(value, tags: tags));
  }

  MetricSnapshot getSnapshot() {
    return MetricSnapshot(
      name: name,
      values: List.from(_values),
    );
  }
}
