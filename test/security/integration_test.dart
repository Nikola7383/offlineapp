import 'package:test/test.dart';

void main() {
  group('Security System Integration Tests', () {
    late SecurityDependencyContainer container;
    late SecurityEventCoordinator eventCoordinator;
    late SecurityErrorHandler errorHandler;

    setUp(() async {
      container = SecurityDependencyContainer();
      await container.waitForInitialization();

      eventCoordinator = container.eventCoordinator;
      errorHandler = container.errorHandler;
    });

    test('System Initialization Test', () {
      expect(container.isInitialized, isTrue);
      expect(container.securityController, isNotNull);
      expect(container.encryptionManager, isNotNull);
      expect(container.auditManager, isNotNull);
      expect(container.securityVault, isNotNull);
      expect(container.integrityManager, isNotNull);
      expect(container.threatManager, isNotNull);
    });

    test('Dependency Injection Test', () {
      // Provera međuzavisnosti
      expect(container.securityController.encryptionManager,
          same(container.encryptionManager));
      expect(container.securityController.auditManager,
          same(container.auditManager));
    });

    test('Event Coordination Test', () async {
      // Test handler
      final testHandler = TestEventHandler();
      eventCoordinator.registerHandler('TEST_EVENT', testHandler);

      // Test event
      final testEvent = SecurityEvent(
          type: 'TEST_EVENT',
          priority: Priority.normal,
          data: {'test': 'data'});

      await eventCoordinator.handleEvent(testEvent);

      expect(testHandler.eventReceived, isTrue);
      expect(testHandler.lastEvent, equals(testEvent));
    });

    test('Error Handling Test', () async {
      // Test error
      final testError = SecurityError(
          type: ErrorType.systemError,
          severity: ErrorSeverity.high,
          message: 'Test error');

      // Listen for error
      bool errorReceived = false;
      errorHandler.highErrors.listen((error) {
        errorReceived = true;
        expect(error, equals(testError));
      });

      await errorHandler.handleError(testError);

      expect(errorReceived, isTrue);
    });

    test('Encryption Flow Test', () async {
      final testData = 'Test Data';
      final encryptedData = await container.encryptionManager
          .encryptData(testData, EncryptionLevel.maximum);

      expect(encryptedData, isNotNull);

      final decryptedData =
          await container.encryptionManager.decryptData(encryptedData);

      expect(decryptedData, equals(testData));
    });

    test('Threat Detection Test', () async {
      final threat = await container.threatManager
          .assessThreat(MockThreat(), AssessmentLevel.full);

      expect(threat.isDetected, isTrue);
      expect(threat.severity, isNotNull);
    });

    test('Audit Logging Test', () async {
      final testEvent = SecurityEvent(
          type: 'AUDIT_TEST',
          priority: Priority.normal,
          data: {'test': 'audit'});

      await container.auditManager.logSecurityEvent(testEvent);

      final logs = await container.auditManager.getRecentLogs();
      expect(logs, contains(testEvent));
    });

    test('System Recovery Test', () async {
      // Simulate system failure
      await container.securityController.simulateFailure();

      // Check recovery
      final recoveryStatus = await container.securityController.getStatus();
      expect(recoveryStatus.isRecovered, isTrue);
      expect(recoveryStatus.isStable, isTrue);
    });

    test('Security Logging Test', () async {
      final logger = container.securityLogger;

      // Test error logging
      final testError = SecurityError(
          type: ErrorType.systemError,
          severity: ErrorSeverity.high,
          message: 'Test error');

      await logger.logError(testError);

      // Test warning logging
      await logger.logWarning('Test warning');

      // Test info logging
      await logger.logInfo('Test info');

      final recentLogs = logger.getRecentLogs();

      expect(recentLogs.length, equals(3));
      expect(recentLogs[0].level, equals(LogLevel.info));
      expect(recentLogs[1].level, equals(LogLevel.warning));
      expect(recentLogs[2].level, equals(LogLevel.error));
    });

    test('Log Stream Test', () async {
      final logger = container.securityLogger;
      final logs = <LogEntry>[];

      logger.logStream.listen((entry) {
        logs.add(entry);
      });

      await logger.logInfo('Test stream');

      expect(logs.length, equals(1));
      expect(logs.first.message, equals('Test stream'));
    });
  });
}

class TestEventHandler extends SecurityEventHandler {
  bool eventReceived = false;
  SecurityEvent? lastEvent;

  @override
  Future<void> handle(SecurityEvent event) async {
    eventReceived = true;
    lastEvent = event;
  }
}

class MockThreat implements SecurityThreat {
  @override
  bool get isDetected => true;

  @override
  ThreatSeverity get severity => ThreatSeverity.medium;
}
