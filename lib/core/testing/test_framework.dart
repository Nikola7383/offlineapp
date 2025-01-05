@isTest
class TestFramework extends InjectableService {
  final Map<String, TestSuite> _suites = {};
  final TestReporter _reporter;

  TestFramework(LoggerService logger)
      : _reporter = TestReporter(logger),
        super(logger);

  Future<void> runAllTests() async {
    _reporter.startTesting();

    for (final suite in _suites.values) {
      await _runSuite(suite);
    }

    _reporter.finishTesting();
  }

  Future<void> _runSuite(TestSuite suite) async {
    _reporter.startSuite(suite.name);

    for (final test in suite.tests) {
      await _runTest(test);
    }

    _reporter.finishSuite(suite.name);
  }

  Future<void> _runTest(TestCase test) async {
    _reporter.startTest(test.name);

    try {
      await test.setUp();
      await test.run();
      await test.tearDown();
      _reporter.testPassed(test.name);
    } catch (e, stack) {
      _reporter.testFailed(test.name, e, stack);
    }
  }

  void registerSuite(TestSuite suite) {
    _suites[suite.name] = suite;
  }
}

abstract class TestSuite {
  String get name;
  List<TestCase> get tests;
}

abstract class TestCase {
  String get name;

  Future<void> setUp() async {}
  Future<void> run();
  Future<void> tearDown() async {}
}
