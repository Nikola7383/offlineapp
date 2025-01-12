import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/security/security_container.dart';
import 'package:secure_event_app/core/security/security_types.dart';
import 'package:secure_event_app/core/interfaces/logger_service_interface.dart';
import 'package:secure_event_app/core/services/logger_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('System Safety Tests', () {
    late SecurityContainer container;
    late ILoggerService logger;

    setUp(() async {
      logger = LoggerService();
      await logger.initialize();
      container = SecurityContainer(logger);
      await container.initialize();
    });

    test('Dependency Validation Test', () {
      expect(container.validate(), isTrue);
    });

    test('Thread Safety Test', () async {
      final securityLogger = container.logger;

      // Simulacija konkurentnih operacija
      final futures = List.generate(100, (i) async {
        securityLogger.info('Concurrent log $i');
      });

      await Future.wait(futures);

      final logs = await securityLogger.getLogs();
      expect(logs.length, greaterThanOrEqualTo(100));
    });

    test('Memory Management Test', () async {
      final memoryManager = container.memoryManager;

      // Test object lifecycle
      final testObject = Object();
      await memoryManager.register('test', testObject);

      var storedObject = await memoryManager.get('test');
      expect(storedObject, equals(testObject));

      await memoryManager.unregister('test');
      storedObject = await memoryManager.get('test');
      expect(storedObject, isNull);
    });

    test('Performance Monitoring Test', () async {
      final monitor = container.performanceMonitor;

      // Simulate performance alert
      final alert = PerformanceAlert(
        severity: AlertSeverity.medium,
        message: 'Slow operation detected',
        metric: 'operationDuration',
        value: const Duration(milliseconds: 1500),
      );

      monitor.addAlert(alert);

      final alerts = monitor.getAlerts();
      expect(alerts.length, equals(1));
      expect(alerts.first.severity, equals(AlertSeverity.medium));
    });

    tearDown(() async {
      await container.dispose();
      await logger.dispose();
    });
  });
}
