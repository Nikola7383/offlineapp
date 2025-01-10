class FixResult {
  final String fixId;
  final bool successful;
  final String? error;
  final DateTime appliedAt;
  final Map<String, dynamic> metrics;

  FixResult({
    required this.fixId,
    required this.successful,
    this.error,
    required this.appliedAt,
    Map<String, dynamic>? metrics,
  }) : metrics = metrics ?? {};

  bool get needsRevert => !successful && error != null;

  Map<String, dynamic> toMap() => {
        'fixId': fixId,
        'successful': successful,
        'error': error,
        'appliedAt': appliedAt.toIso8601String(),
        'metrics': metrics,
      };
}

class FixDiagnostics {
  final List<FixResult> results;

  FixDiagnostics(this.results);

  bool get allFixesSuccessful => results.every((result) => result.successful);

  List<FixResult> get failedFixes =>
      results.where((result) => !result.successful).toList();

  Map<String, dynamic> toReport() => {
        'successful': allFixesSuccessful,
        'totalFixes': results.length,
        'failedFixes': failedFixes.length,
        'details': results.map((r) => r.toMap()).toList(),
      };
}
