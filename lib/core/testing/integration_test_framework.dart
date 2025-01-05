@isTest
class IntegrationTestFramework extends TestFramework {
  final ServiceLocator _serviceLocator;
  final List<ServiceMock> _mocks = [];

  IntegrationTestFramework(
    LoggerService logger,
    this._serviceLocator,
  ) : super(logger);

  Future<void> runIntegrationTests() async {
    await _setupTestEnvironment();
    await runAllTests();
    await _tearDownTestEnvironment();
  }

  Future<void> _setupTestEnvironment() async {
    await _serviceLocator.reset();
    await _initializeMocks();
    await _serviceLocator.initialize();
  }

  Future<void> _initializeMocks() async {
    for (final mock in _mocks) {
      _serviceLocator.instance.registerSingleton(mock);
    }
  }

  Future<void> _tearDownTestEnvironment() async {
    await _serviceLocator.dispose();
    _mocks.clear();
  }

  void registerMock<T extends Object>(ServiceMock<T> mock) {
    _mocks.add(mock);
  }
}

abstract class ServiceMock<T> {
  String get serviceName;
  T get instance;
}
