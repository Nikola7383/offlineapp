class PerformanceReport {
  final DateTime timestamp;
  final Map<String, MetricAnalysis> metrics;

  PerformanceReport({
    required this.timestamp,
    required this.metrics,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Report from: $timestamp');
    metrics.forEach((key, value) {
      buffer.writeln('$key:');
      buffer.writeln(value);
    });
    return buffer.toString();
  }
}

class MetricAnalysis {
  final double min;
  final double max;
  final double mean;
  final double median;
  final double stdDev;
  final double p95;
  final double p99;
  final int sampleSize;

  MetricAnalysis({
    required this.min,
    required this.max,
    required this.mean,
    required this.median,
    required this.stdDev,
    required this.p95,
    required this.p99,
    required this.sampleSize,
  });

  factory MetricAnalysis.empty() {
    return MetricAnalysis(
      min: 0,
      max: 0,
      mean: 0,
      median: 0,
      stdDev: 0,
      p95: 0,
      p99: 0,
      sampleSize: 0,
    );
  }

  @override
  String toString() {
    return '''
      Sample Size: $sampleSize
      Min: ${min.toStringAsFixed(2)}
      Max: ${max.toStringAsFixed(2)}
      Mean: ${mean.toStringAsFixed(2)}
      Median: ${median.toStringAsFixed(2)}
      Std Dev: ${stdDev.toStringAsFixed(2)}
      P95: ${p95.toStringAsFixed(2)}
      P99: ${p99.toStringAsFixed(2)}
    ''';
  }
}
