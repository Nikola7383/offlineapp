class TestMetrics {
  final String testName;
  final DateTime startTime;
  final Map<String, dynamic> performanceData = {};
  final List<String> errors = [];

  bool? success;
  String? failureReason;

  TestMetrics(this.testName) : startTime = DateTime.now();

  void addPerformanceData(Map<String, dynamic> data) {
    performanceData.addAll(data);
  }

  void addTiming(String key, int milliseconds) {
    performanceData[key] = milliseconds;
  }

  void setSuccess(bool isSuccess) {
    success = isSuccess;
  }

  void setFailure(String reason) {
    success = false;
    failureReason = reason;
    errors.add(reason);
  }

  Duration get duration => DateTime.now().difference(startTime);

  Map<String, dynamic> toJson() => {
        'testName': testName,
        'duration': duration.inMilliseconds,
        'success': success,
        'failureReason': failureReason,
        'performanceData': performanceData,
        'errors': errors,
      };
}

class TestReport {
  final Map<String, TestResult> results = {};
  final DateTime startTime = DateTime.now();
  bool failed = false;
  String? failureReason;

  void addResult(String testName, TestResult result) {
    results[testName] = result;
  }

  void markAsFailed(String reason) {
    failed = true;
    failureReason = reason;
  }

  Map<String, dynamic> generateReport() => {
        'startTime': startTime.toIso8601String(),
        'duration': DateTime.now().difference(startTime).inMilliseconds,
        'failed': failed,
        'failureReason': failureReason,
        'results': results.map((k, v) => MapEntry(k, v.toJson())),
      };
}
