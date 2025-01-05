void main() {
  group('Enhanced System Tests', () {
    late EnhancedDependencyContainer container;

    setUp(() async {
      container = EnhancedDependencyContainer();
      await container.waitForInitialization();
    });

    test('Component Memory Management', () async {
      final memoryManager = SecurityMemoryManager();

      // Test component registration
      expect(memoryManager.getObject('securityController'), isNotNull);
      expect(memoryManager.getObject('encryptionManager'), isNotNull);
      expect(memoryManager.getObject('auditManager'), isNotNull);

      // Test memory alerts
      final alerts = <MemoryAlert>[];
      memoryManager.memoryAlerts.listen((alert) {
        alerts.add(alert);
      });

      // Simulate high memory usage
      for (var i = 0; i < 2000; i++) {
        memoryManager.registerObject('test_$i', Object());
      }

      await Future.delayed(Duration(seconds: 2));
      expect(alerts, isNotEmpty);
      expect(alerts.first.type, equals(MemoryAlertType.highUsage));
    });

    test('Thread Safe Operations', () async {
      final encryptionManager = container.encryptionManager;

      // Test concurrent operations
      final futures =
          List.generate(100, (i) => encryptionManager.encryptData('test_$i'));

      final results = await Future.wait(futures);
      expect(results.length, equals(100));

      // Verify no data corruption
      for (var i = 0; i < 100; i++) {
        final decrypted = await encryptionManager.decryptData(results[i]);
        expect(decrypted, equals('test_$i'));
      }
    });

    test('Component Lifecycle', () async {
      final testComponent = TestSecurityComponent();

      // Test initialization
      expect(testComponent.componentId, isNotNull);

      // Test safe operation
      final result = await testComponent.testOperation();
      expect(result, isTrue);

      // Test disposal
      testComponent.dispose();
      expect(
          SecurityMemoryManager().getObject(testComponent.componentId), isNull);
    });

    test('Performance Monitoring', () async {
      final performanceMonitor = container.performanceMonitor;

      // Test normal operation
      performanceMonitor.recordMetric(
          'fastOperation', Duration(milliseconds: 50));

      // Test slow operation
      performanceMonitor.recordMetric(
          'slowOperation', Duration(milliseconds: 2500));

      final metrics = performanceMonitor.getMetrics('slowOperation');
      expect(metrics.length, equals(1));
      expect(metrics.first.duration.inMilliseconds, greaterThan(2000));
    });
  });
}

class TestSecurityComponent extends SecurityBaseComponent {
  Future<bool> testOperation() async {
    return await safeOperation(() async {
      await Future.delayed(Duration(milliseconds: 100));
      return true;
    });
  }
}
