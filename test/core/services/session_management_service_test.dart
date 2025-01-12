import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/interfaces/session_management_interface.dart';
import 'package:secure_event_app/core/services/session_management_service.dart';
import '../../test_helper.dart';
import '../../test_helper.mocks.dart';

void main() {
  group('SessionManagementService', () {
    late SessionManagementService service;
    late MockSecureStorage mockStorage;
    late MockILoggerService mockLogger;

    setUp(() {
      mockStorage = MockSecureStorage();
      mockLogger = MockILoggerService();
      service = SessionManagementService(mockStorage, mockLogger);
    });

    test('should create new session', () async {
      // Arrange
      const userId = 'test_user';
      when(mockStorage.write(any, any)).thenAnswer((_) => Future.value());

      // Act
      final session = await service.createSession(userId: userId);

      // Assert
      expect(session.userId, equals(userId));
      expect(session.status, equals(SessionStatus.active));
      expect(session.isActive, isTrue);
      verify(mockStorage.write(any, any)).called(1);
      verify(mockLogger.info(any)).called(1);
    });

    test('should validate active session', () async {
      // Arrange
      const sessionId = 'test_session';
      final session = Session(
        id: sessionId,
        userId: 'test_user',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        status: SessionStatus.active,
      );
      when(mockStorage.read(any)).thenAnswer(
        (_) => Future.value(jsonEncode({
          'id': session.id,
          'userId': session.userId,
          'createdAt': session.createdAt.toIso8601String(),
          'expiresAt': session.expiresAt.toIso8601String(),
          'status': session.status.index,
          'metadata': {},
        })),
      );

      // Act
      final isValid = await service.validateSession(sessionId);

      // Assert
      expect(isValid, isTrue);
      verify(mockStorage.read(any)).called(1);
    });

    test('should not validate expired session', () async {
      // Arrange
      const sessionId = 'test_session';
      final session = Session(
        id: sessionId,
        userId: 'test_user',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: SessionStatus.active,
      );
      when(mockStorage.read(any)).thenAnswer(
        (_) => Future.value(jsonEncode({
          'id': session.id,
          'userId': session.userId,
          'createdAt': session.createdAt.toIso8601String(),
          'expiresAt': session.expiresAt.toIso8601String(),
          'status': session.status.index,
          'metadata': {},
        })),
      );

      // Act
      final isValid = await service.validateSession(sessionId);

      // Assert
      expect(isValid, isFalse);
      verify(mockStorage.read(any)).called(1);
    });

    test('should renew session', () async {
      // Arrange
      const sessionId = 'test_session';
      final session = Session(
        id: sessionId,
        userId: 'test_user',
        createdAt: DateTime.now().subtract(const Duration(hours: 20)),
        expiresAt: DateTime.now().add(const Duration(hours: 4)),
        status: SessionStatus.active,
      );
      when(mockStorage.read(any)).thenAnswer(
        (_) => Future.value(jsonEncode({
          'id': session.id,
          'userId': session.userId,
          'createdAt': session.createdAt.toIso8601String(),
          'expiresAt': session.expiresAt.toIso8601String(),
          'status': session.status.index,
          'metadata': {},
        })),
      );
      when(mockStorage.write(any, any)).thenAnswer((_) => Future.value());

      // Act
      final renewedSession = await service.renewSession(sessionId);

      // Assert
      expect(renewedSession.id, equals(sessionId));
      expect(renewedSession.expiresAt.isAfter(session.expiresAt), isTrue);
      verify(mockStorage.read(any)).called(1);
      verify(mockStorage.write(any, any)).called(1);
    });

    test('should throw when renewing non-existent session', () async {
      // Arrange
      const sessionId = 'non_existent_session';
      when(mockStorage.read(any)).thenAnswer((_) => Future.value(null));

      // Act & Assert
      expect(
        () => service.renewSession(sessionId),
        throwsA(isA<Exception>()),
      );
      verify(mockStorage.read(any)).called(1);
    });

    test('should suspend session', () async {
      // Arrange
      const sessionId = 'test_session';
      final session = Session(
        id: sessionId,
        userId: 'test_user',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        status: SessionStatus.active,
      );
      when(mockStorage.read(any)).thenAnswer(
        (_) => Future.value(jsonEncode({
          'id': session.id,
          'userId': session.userId,
          'createdAt': session.createdAt.toIso8601String(),
          'expiresAt': session.expiresAt.toIso8601String(),
          'status': session.status.index,
          'metadata': {},
        })),
      );
      when(mockStorage.write(any, any)).thenAnswer((_) => Future.value());

      // Act
      await service.suspendSession(sessionId);

      // Assert
      verify(mockStorage.read(any)).called(1);
      verify(mockStorage.write(any, any)).called(1);
      verify(mockLogger.info(any)).called(1);
    });

    test('should delete session', () async {
      // Arrange
      const sessionId = 'test_session';
      when(mockStorage.delete(any)).thenAnswer((_) => Future.value());

      // Act
      await service.deleteSession(sessionId);

      // Assert
      verify(mockStorage.delete(any)).called(1);
      verify(mockLogger.info(any)).called(1);
    });

    test('should get active session', () async {
      // Arrange
      const userId = 'test_user';
      const sessionId = 'test_session';
      when(mockStorage.getAllKeys())
          .thenAnswer((_) => Future.value({'session_$sessionId'}));
      final session = Session(
        id: sessionId,
        userId: userId,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        status: SessionStatus.active,
      );
      when(mockStorage.read(any)).thenAnswer(
        (_) => Future.value(jsonEncode({
          'id': session.id,
          'userId': session.userId,
          'createdAt': session.createdAt.toIso8601String(),
          'expiresAt': session.expiresAt.toIso8601String(),
          'status': session.status.index,
          'metadata': {},
        })),
      );

      // Act
      final activeSession = await service.getActiveSession(userId);

      // Assert
      expect(activeSession, isNotNull);
      expect(activeSession!.id, equals(sessionId));
      expect(activeSession.userId, equals(userId));
      verify(mockStorage.getAllKeys()).called(1);
      verify(mockStorage.read(any)).called(1);
    });
  });
}
