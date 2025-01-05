import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/performance/performance_monitor.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late PerformanceMonitor monitor;
  late MockLoggerService mockLogger;

  setUp(() {
    mockLogger = MockLoggerService();
    monitor = PerformanceMonitor(logger: mockLogger);
  });

  group('PerformanceMonitor Tests', () {
    test('measures operation duration correctly', () async {
      // Arrange
      const operationName = 'test_operation';

      // Act
      monitor.startOperation(operationName);
      await Future.delayed(const Duration(milliseconds: 100));
      monitor.endOperation(operationName);

      // Assert
      final reports = monitor.getReports();
      expect(reports.containsKey(operationName), true);

      final report = reports[operationName]!;
      expect(report.sampleCount, 1);
      expect(report.minMs, greaterThan(0));
      expect(report.maxMs, greaterThan(0));
    });

    test('handles multiple operations', () {
      // Arrange
      const op1 = 'operation1';
      const op2 = 'operation2';

      // Act
      monitor.startOperation(op1);
      monitor.startOperation(op2);
      monitor.endOperation(op2);
      monitor.endOperation(op1);

      // Assert
      final reports = monitor.getReports();
      expect(reports.length, 2);
      expect(reports.containsKey(op1), true);
      expect(reports.containsKey(op2), true);
    });

    test('clears metrics correctly', () {
      // Arrange
      monitor.startOperation('test');
      monitor.endOperation('test');

      // Act
      monitor.clearMetrics();

      // Assert
      final reports = monitor.getReports();
      expect(reports.isEmpty, true);
    });

    test('logs warning for slow operations', () async {
      // Arrange
      const operationName = 'slow_operation';

      // Act
      monitor.startOperation(operationName);
      await Future.delayed(const Duration(milliseconds: 20));
      monitor.endOperation(operationName);

      // Assert
      verify(mockLogger.warning(any)).called(1);
    });
  });
}
