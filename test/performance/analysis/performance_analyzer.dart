import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:path/path.dart' as path;

class PerformanceAnalyzer {
  final String _reportsPath = 'test_results';

  Future<PerformanceReport> analyzeLatestReport() async {
    final directory = Directory(_reportsPath);
    final files = await directory
        .list()
        .where((f) => f.path.endsWith('performance_report.json'))
        .toList();

    if (files.isEmpty) {
      throw Exception('No performance reports found');
    }

    // Get latest report
    final latestReport = files.reduce((a, b) {
      return File(a.path)
              .lastModifiedSync()
              .isAfter(File(b.path).lastModifiedSync())
          ? a
          : b;
    });

    final jsonContent = await File(latestReport.path).readAsString();
    final data = json.decode(jsonContent);

    return _analyzeReport(data);
  }

  Future<List<PerformanceReport>> analyzeHistoricalTrend() async {
    final directory = Directory(_reportsPath);
    final files = await directory
        .list()
        .where((f) => f.path.endsWith('performance_report.json'))
        .toList();

    final reports = <PerformanceReport>[];

    for (final file in files) {
      final jsonContent = await File(file.path).readAsString();
      final data = json.decode(jsonContent);
      reports.add(_analyzeReport(data));
    }

    return reports;
  }

  PerformanceReport _analyzeReport(Map<String, dynamic> data) {
    final metrics = <String, MetricAnalysis>{};

    final metricsData = data['metrics'] as Map<String, dynamic>;

    for (final entry in metricsData.entries) {
      final values =
          (entry.value as List).map((e) => e['value'] as double).toList();

      metrics[entry.key] = _analyzeMetric(values);
    }

    return PerformanceReport(
      timestamp: DateTime.parse(data['timestamp']),
      metrics: metrics,
    );
  }

  MetricAnalysis _analyzeMetric(List<double> values) {
    if (values.isEmpty) return MetricAnalysis.empty();

    final sorted = List<double>.from(values)..sort();
    final mean = values.reduce((a, b) => a + b) / values.length;

    // Calculate standard deviation
    final variance =
        values.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
            values.length;
    final stdDev = math.sqrt(variance);

    return MetricAnalysis(
      min: sorted.first,
      max: sorted.last,
      mean: mean,
      median: _calculateMedian(sorted),
      stdDev: stdDev,
      p95: _calculatePercentile(sorted, 0.95),
      p99: _calculatePercentile(sorted, 0.99),
      sampleSize: values.length,
    );
  }

  double _calculateMedian(List<double> sorted) {
    if (sorted.isEmpty) return 0;
    if (sorted.length.isOdd) {
      return sorted[sorted.length ~/ 2];
    }
    return (sorted[sorted.length ~/ 2 - 1] + sorted[sorted.length ~/ 2]) / 2;
  }

  double _calculatePercentile(List<double> sorted, double percentile) {
    if (sorted.isEmpty) return 0;
    final index = (sorted.length * percentile).ceil() - 1;
    return sorted[index.clamp(0, sorted.length - 1)];
  }

  Future<void> generateReport({bool includeHistorical = true}) async {
    final report = await analyzeLatestReport();
    final historical =
        includeHistorical ? await analyzeHistoricalTrend() : null;

    final reportBuffer = StringBuffer();
    reportBuffer.writeln('Performance Analysis Report');
    reportBuffer.writeln('Generated: ${DateTime.now()}\n');

    report.metrics.forEach((name, analysis) {
      reportBuffer.writeln('Metric: $name');
      reportBuffer.writeln(analysis.toString());
      reportBuffer.writeln();
    });

    if (historical != null && historical.length > 1) {
      reportBuffer.writeln('\nHistorical Trend Analysis:');
      _analyzeHistoricalTrend(historical, reportBuffer);
    }

    final reportFile = File(path.join(_reportsPath, 'analysis_report.txt'));
    await reportFile.writeAsString(reportBuffer.toString());
  }

  void _analyzeHistoricalTrend(
    List<PerformanceReport> reports,
    StringBuffer buffer,
  ) {
    final metrics = reports.first.metrics.keys.toList();

    for (final metric in metrics) {
      buffer.writeln('\nMetric: $metric');

      final values = reports.map((r) => r.metrics[metric]?.mean ?? 0).toList();

      final trend = _calculateTrend(values);
      buffer.writeln('Trend: ${_describeTrend(trend)}');

      final improvement = _calculateImprovement(values.first, values.last);
      buffer.writeln('Overall change: ${improvement.toStringAsFixed(2)}%');
    }
  }

  double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0;

    final x = List.generate(values.length, (i) => i.toDouble());
    final y = values;

    final n = values.length;
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumX2 = x.map((x) => x * x).reduce((a, b) => a + b);

    return (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
  }

  String _describeTrend(double trend) {
    if (trend > 0.1) return 'Improving ↑';
    if (trend < -0.1) return 'Degrading ↓';
    return 'Stable →';
  }

  double _calculateImprovement(double first, double last) {
    return ((last - first) / first) * 100;
  }
}
