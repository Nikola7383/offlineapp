void main() {
  group('System Safety Tests', () {
    late SecurityDependencyContainer container;
    
    setUp(() async {
      container = SecurityDependencyContainer();
      await container.waitForInitialization();
    });

    test('Dependency Validation Test', () {
      expect(
        () => DependencyValidator.validateDependencies(container),
        returnsNormally
      );
    });

    test('Thread Safety Test', () async {
      final logger = container.securityLogger;
      
      // Simulacija konkurentnih operacija
      final futures = List.generate(100, (i) => 
        logger.logInfo('Concurrent log $i')
      );
      
      await Future.wait(futures);
      
      final logs = logger.getRecentLogs(100);
      expect(logs.length, equals(100));
    });

    test('Memory Management Test', () {
      final memoryManager = SecurityMemoryManager();
      
      // Test object lifecycle
      final testObject = Object();
      memoryManager.registerObject('test', testObject);
      
      expect(memoryManager.getObject('test'), equals(testObject));
      
      // Force garbage collection
      testObject = null;
      // Wait for weak reference to be cleared
      await Future.delayed(Duration(seconds: 1));
      
      expect(memoryManager.getObject('test'), isNull);
    });

    test('Performance Monitoring Test', () async {
      final monitor = container.performanceMonitor;
      
      // Simulate slow operation
      monitor.recordMetric('slowOperation', Duration(milliseconds: 1500));
      
      final alerts = await monitor.alerts.first;
      expect(alerts.severity, equals(AlertSeverity.medium));
    });
  });
} 