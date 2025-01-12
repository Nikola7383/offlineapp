import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/interfaces/logger_service_interface.dart';
import 'package:secure_event_app/models/audit_types.dart';
import 'package:secure_event_app/security/audit_manager.dart';
import '../mocks/security_mocks.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late AuditManager auditManager;

  setUp(() {
    mockLogger = MockILoggerService();
    auditManager = AuditManager(mockLogger);
    when(mockLogger.info(any)).thenAnswer((_) async {});
    when(mockLogger.warning(any)).thenAnswer((_) async {});
  });

  group('AuditManager Tests', () {
    test('initialize() postavlja isInitialized na true', () async {
      expect(auditManager.isInitialized, isFalse);
      await auditManager.initialize();
      expect(auditManager.isInitialized, isTrue);
      verify(mockLogger.info(any)).called(1);
    });

    test('initialize() ne inicijalizuje već inicijalizovan menadžer', () async {
      await auditManager.initialize();
      await auditManager.initialize();
      verify(mockLogger.warning(any)).called(1);
    });

    test('dispose() čisti resurse i postavlja isInitialized na false',
        () async {
      await auditManager.initialize();
      await auditManager.dispose();
      expect(auditManager.isInitialized, isFalse);
      verify(mockLogger.info(any)).called(2); // 1 za initialize + 1 za dispose
    });

    test('dispose() ne gasi neinicijalizovan menadžer', () async {
      await auditManager.dispose();
      verify(mockLogger.warning(any)).called(1);
    });

    test('logAuditEvent() kreira događaj i emituje ga', () async {
      // Arrange
      await auditManager.initialize();

      final event = AuditEvent(
        id: 'test-event-1',
        userId: 'test-user',
        eventType: AuditEventType.login,
        resourceId: 'test-resource',
        timestamp: DateTime.now(),
        severity: AuditSeverity.info,
      );

      // Act
      await auditManager.logAuditEvent(
        userId: event.userId,
        eventType: event.eventType,
        resourceId: event.resourceId,
        severity: event.severity,
      );

      // Assert
      verify(mockLogger.info(any))
          .called(2); // 1 za initialize + 1 za logAuditEvent
      expect(auditManager.isInitialized, isTrue);
    });

    test('logAuditEvent() baca grešku ako nije inicijalizovan', () async {
      final event = AuditEvent(
        id: 'test-event-1',
        userId: 'test-user',
        eventType: AuditEventType.login,
        resourceId: 'test-resource',
        timestamp: DateTime.now(),
        severity: AuditSeverity.info,
      );

      expect(
        () => auditManager.logAuditEvent(
          userId: event.userId,
          eventType: event.eventType,
          resourceId: event.resourceId,
          severity: event.severity,
        ),
        throwsStateError,
      );
    });

    test('logAuditEvent() kreira upozorenje za događaje visokog prioriteta',
        () async {
      await auditManager.initialize();

      final event = AuditEvent(
        id: 'test-event-1',
        userId: 'test-user',
        eventType: AuditEventType.login,
        resourceId: 'test-resource',
        timestamp: DateTime.now(),
        severity: AuditSeverity.warning,
      );

      expectLater(
        auditManager.auditAlerts,
        emits(predicate<AuditAlert>(
          (alert) =>
              alert.severity == AuditSeverity.warning &&
              alert.affectedEventIds.length == 1,
        )),
      );

      await auditManager.logAuditEvent(
        userId: event.userId,
        eventType: event.eventType,
        resourceId: event.resourceId,
        severity: event.severity,
      );
    });

    test('getAuditEvents() vraća sve događaje bez filtera', () async {
      await auditManager.initialize();

      await auditManager.logAuditEvent(
        userId: 'user1',
        eventType: AuditEventType.login,
        resourceId: 'resource1',
      );

      await auditManager.logAuditEvent(
        userId: 'user1',
        eventType: AuditEventType.dataAccess,
        resourceId: 'resource2',
      );

      final events = await auditManager.getAuditEvents();
      expect(events, hasLength(2));
    });

    test('getAuditEvents() filtrira po userId', () async {
      await auditManager.initialize();

      await auditManager.logAuditEvent(
        userId: 'user1',
        eventType: AuditEventType.login,
        resourceId: 'resource1',
      );

      await auditManager.logAuditEvent(
        userId: 'user2',
        eventType: AuditEventType.login,
        resourceId: 'resource1',
      );

      final events = await auditManager.getAuditEvents(userId: 'user1');
      expect(events, hasLength(1));
      expect(events.first.userId, equals('user1'));
    });

    test('getAuditEvents() filtrira po eventType', () async {
      await auditManager.initialize();

      await auditManager.logAuditEvent(
        userId: 'user1',
        eventType: AuditEventType.login,
        resourceId: 'resource1',
      );

      await auditManager.logAuditEvent(
        userId: 'user1',
        eventType: AuditEventType.dataAccess,
        resourceId: 'resource1',
      );

      final events = await auditManager.getAuditEvents(
        eventTypes: {AuditEventType.login},
      );
      expect(events, hasLength(1));
      expect(events.first.eventType, equals(AuditEventType.login));
    });

    test('getAuditEvents() poštuje limit', () async {
      await auditManager.initialize();

      await auditManager.logAuditEvent(
        userId: 'user1',
        eventType: AuditEventType.login,
        resourceId: 'resource1',
      );

      await auditManager.logAuditEvent(
        userId: 'user1',
        eventType: AuditEventType.dataAccess,
        resourceId: 'resource1',
      );

      final events = await auditManager.getAuditEvents(limit: 1);
      expect(events, hasLength(1));
    });
  });
}
