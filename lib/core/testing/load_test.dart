@isTest
class LoadTest {
  final int concurrentUsers;
  final Duration testDuration;
  final LoggerService _logger;

  LoadTest({
    required this.concurrentUsers,
    required this.testDuration,
    required LoggerService logger,
  }) : _logger = logger;

  Future<void> runTest(Future<void> Function() userAction) async {
    final startTime = DateTime.now();
    int completedActions = 0;
    int failedActions = 0;

    final futures = List.generate(concurrentUsers, (index) async {
      while (DateTime.now().difference(startTime) < testDuration) {
        try {
          await userAction();
          completedActions++;
        } catch (e) {
          failedActions++;
          _logger.error('Action failed', e);
        }
      }
    });

    await Future.wait(futures);

    _generateReport(
      completedActions: completedActions,
      failedActions: failedActions,
      duration: DateTime.now().difference(startTime),
    );
  }

  void _generateReport({
    required int completedActions,
    required int failedActions,
    required Duration duration,
  }) {
    final report = StringBuffer();
    report.writeln('Load Test Report:');
    report.writeln('================');
    report.writeln('Duration: ${duration.inSeconds}s');
    report.writeln('Concurrent Users: $concurrentUsers');
    report.writeln('Completed Actions: $completedActions');
    report.writeln('Failed Actions: $failedActions');
    report.writeln('Actions/Second: ${completedActions ~/ duration.inSeconds}');
    report.writeln(
        'Error Rate: ${(failedActions / completedActions * 100).toStringAsFixed(2)}%');

    _logger.info(report.toString());
  }
}
