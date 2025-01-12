import 'package:injectable/injectable.dart';
import '../services/injectable_service.dart';
import '../services/logger_service.dart';
import '../di/service_locator.dart';
import 'test_reporter.dart';
import 'test_framework.dart';

@injectable
class IntegrationTestFramework extends TestFramework {
  final ServiceLocator _serviceLocator;
  final List<ServiceMock> _mocks = [];

  IntegrationTestFramework(LoggerService logger, this._serviceLocator)
      : super(logger);

  @override
  Future<void> setUp() async {
    await super.setUp();
    await _serviceLocator.dispose();
  }

  @override
  Future<void> tearDown() async {
    for (final mock in _mocks) {
      await _serviceLocator.dispose();
      final service = ServiceLocator.get<Object>();
      if (service.runtimeType == mock.implementation.runtimeType) {
        // Original service restored
      }
    }
    _mocks.clear();
    await super.tearDown();
  }

  void registerMock<T extends Object>(T mock) {
    _mocks.add(ServiceMock<T>(mock));
  }
}

class ServiceMock<T extends Object> {
  final T implementation;
  ServiceMock(this.implementation);
}
