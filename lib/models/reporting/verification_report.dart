class VerificationReport {
  final DateTime timestamp;
  final Map<String, VerificationResult> results;
  final Map<String, dynamic> metrics;
  final List<Recommendation> recommendations;

  VerificationReport({
    required this.timestamp,
    required this.results,
    required this.metrics,
    required this.recommendations,
  });

  bool get hasCriticalIssues =>
      results.values.any((r) => r.status == FixStatus.critical);

  String getCriticalIssuesSummary() {
    final criticalIssues = results.entries
        .where((e) => e.value.status == FixStatus.critical)
        .map((e) => '${e.key}: ${e.value.error ?? "Critical status"}')
        .join('\n');

    return '''
    Critical Issues Detected:
    $criticalIssues
    
    Recommendations:
    ${recommendations.where((r) => r.priority == Priority.high).join('\n')}
    ''';
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'results': results.map((k, v) => MapEntry(k, v.toJson())),
        'metrics': metrics,
        'recommendations': recommendations.map((r) => r.toJson()).toList(),
      };
}

enum FixStatus {
  healthy,
  warning,
  critical,
}

enum Priority {
  low,
  medium,
  high,
}
