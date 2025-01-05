@injectable
class TestReporter extends InjectableService {
  final StringBuffer _report = StringBuffer();
  int _passedTests = 0;
  int _failedTests = 0;
  DateTime? _startTime;

  void startTesting() {
    _startTime = DateTime.now();
    _report.writeln('\nStarting Test Run');
    _report.writeln('================\n');
  }

  void startSuite(String suiteName) {
    _report.writeln('Test Suite: $suiteName');
    _report.writeln('-------------------');
  }

  void startTest(String testName) {
    _report.write('Running test: $testName... ');
  }

  void testPassed(String testName) {
    _passedTests++;
    _report.writeln('✓ PASSED');
  }

  void testFailed(String testName, dynamic error, StackTrace stack) {
    _failedTests++;
    _report.writeln('✗ FAILED');
    _report.writeln('Error: $error');
    _report.writeln('Stack Trace:');
    _report.writeln(stack);
    _report.writeln();
  }

  void finishSuite(String suiteName) {
    _report.writeln();
  }

  void finishTesting() {
    final duration = DateTime.now().difference(_startTime!);

    _report.writeln('\nTest Run Summary');
    _report.writeln('================');
    _report.writeln('Total Tests: ${_passedTests + _failedTests}');
    _report.writeln('Passed: $_passedTests');
    _report.writeln('Failed: $_failedTests');
    _report.writeln('Duration: ${duration.inSeconds}s');

    logger.info(_report.toString());
  }
}
