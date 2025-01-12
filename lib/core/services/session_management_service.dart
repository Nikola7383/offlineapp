import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../interfaces/session_management_interface.dart';
import '../interfaces/logger_service.dart';
import '../storage/secure_storage.dart';

@LazySingleton(as: ISessionManagementService)
class SessionManagementService implements ISessionManagementService {
  final SecureStorage _storage;
  final ILoggerService _logger;
  final _sessionController = StreamController<SessionEvent>.broadcast();
  final _uuid = Uuid();

  static const String _sessionPrefix = 'session_';
  static const Duration _defaultSessionDuration = Duration(hours: 24);

  SessionManagementService(this._storage, this._logger);

  @override
  Stream<SessionEvent> get sessionStream => _sessionController.stream;

  @override
  Future<void> initialize() async {
    _logger.info('Initializing SessionManagementService');
    try {
      // Proveri i očisti istekle sesije pri inicijalizaciji
      final keys = await _storage.getAllKeys();
      for (final key in keys) {
        if (key.startsWith(_sessionPrefix)) {
          final sessionId = key.substring(_sessionPrefix.length);
          final session = await _getSession(sessionId);
          if (session != null && session.isExpired) {
            await deleteSession(sessionId);
          }
        }
      }
    } catch (e) {
      _logger.error('Error during session cleanup', e);
    }
  }

  @override
  Future<void> dispose() async {
    await _sessionController.close();
  }

  @override
  Future<Session> createSession({
    required String userId,
    Duration? duration,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final sessionId = _uuid.v4();
      final now = DateTime.now();
      final session = Session(
        id: sessionId,
        userId: userId,
        createdAt: now,
        expiresAt: now.add(duration ?? _defaultSessionDuration),
        status: SessionStatus.active,
        metadata: metadata ?? {},
      );

      await _saveSession(session);
      _notifySessionEvent(SessionEvent(
        sessionId: sessionId,
        type: SessionEventType.created,
        timestamp: now,
        metadata: {'userId': userId},
      ));

      _logger.info('Created new session: $sessionId for user: $userId');
      return session;
    } catch (e) {
      _logger.error('Failed to create session', e);
      rethrow;
    }
  }

  @override
  Future<bool> validateSession(String sessionId) async {
    try {
      final session = await _getSession(sessionId);
      if (session == null) return false;

      final isValid = session.isActive;
      if (isValid) {
        _notifySessionEvent(SessionEvent(
          sessionId: sessionId,
          type: SessionEventType.validated,
          timestamp: DateTime.now(),
        ));
      }

      return isValid;
    } catch (e) {
      _logger.error('Failed to validate session', e);
      return false;
    }
  }

  @override
  Future<Session> renewSession(String sessionId, {Duration? duration}) async {
    try {
      final session = await _getSession(sessionId);
      if (session == null) {
        throw Exception('Session not found');
      }

      if (!session.isActive) {
        throw Exception('Cannot renew inactive session');
      }

      final now = DateTime.now();
      final renewedSession = Session(
        id: session.id,
        userId: session.userId,
        createdAt: session.createdAt,
        expiresAt: now.add(duration ?? _defaultSessionDuration),
        status: session.status,
        metadata: session.metadata,
      );

      await _saveSession(renewedSession);
      _notifySessionEvent(SessionEvent(
        sessionId: sessionId,
        type: SessionEventType.renewed,
        timestamp: now,
      ));

      _logger.info('Renewed session: $sessionId');
      return renewedSession;
    } catch (e) {
      _logger.error('Failed to renew session', e);
      rethrow;
    }
  }

  @override
  Future<void> suspendSession(String sessionId) async {
    try {
      final session = await _getSession(sessionId);
      if (session == null) {
        throw Exception('Session not found');
      }

      final suspendedSession = Session(
        id: session.id,
        userId: session.userId,
        createdAt: session.createdAt,
        expiresAt: session.expiresAt,
        status: SessionStatus.suspended,
        metadata: session.metadata,
      );

      await _saveSession(suspendedSession);
      _notifySessionEvent(SessionEvent(
        sessionId: sessionId,
        type: SessionEventType.suspended,
        timestamp: DateTime.now(),
      ));

      _logger.info('Suspended session: $sessionId');
    } catch (e) {
      _logger.error('Failed to suspend session', e);
      rethrow;
    }
  }

  @override
  Future<void> lockSession(String sessionId) async {
    try {
      final session = await _getSession(sessionId);
      if (session == null) {
        throw Exception('Session not found');
      }

      final lockedSession = Session(
        id: session.id,
        userId: session.userId,
        createdAt: session.createdAt,
        expiresAt: session.expiresAt,
        status: SessionStatus.locked,
        metadata: session.metadata,
      );

      await _saveSession(lockedSession);
      _notifySessionEvent(SessionEvent(
        sessionId: sessionId,
        type: SessionEventType.locked,
        timestamp: DateTime.now(),
      ));

      _logger.info('Locked session: $sessionId');
    } catch (e) {
      _logger.error('Failed to lock session', e);
      rethrow;
    }
  }

  @override
  Future<void> logout(String sessionId) async {
    try {
      final session = await _getSession(sessionId);
      if (session == null) {
        throw Exception('Session not found');
      }

      final loggedOutSession = Session(
        id: session.id,
        userId: session.userId,
        createdAt: session.createdAt,
        expiresAt: DateTime.now(),
        status: SessionStatus.loggedOut,
        metadata: session.metadata,
      );

      await _saveSession(loggedOutSession);
      _notifySessionEvent(SessionEvent(
        sessionId: sessionId,
        type: SessionEventType.loggedOut,
        timestamp: DateTime.now(),
      ));

      _logger.info('Logged out session: $sessionId');
    } catch (e) {
      _logger.error('Failed to logout session', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      await _storage.delete('$_sessionPrefix$sessionId');
      _logger.info('Deleted session: $sessionId');
    } catch (e) {
      _logger.error('Failed to delete session', e);
      rethrow;
    }
  }

  @override
  Future<Session?> getActiveSession(String userId) async {
    try {
      final sessions = await getAllActiveSessions(userId);
      return sessions.isEmpty ? null : sessions.first;
    } catch (e) {
      _logger.error('Failed to get active session', e);
      return null;
    }
  }

  @override
  Future<List<Session>> getAllActiveSessions(String userId) async {
    try {
      final keys = await _storage.getAllKeys();
      final sessions = <Session>[];

      for (final key in keys) {
        if (key.startsWith(_sessionPrefix)) {
          final sessionId = key.substring(_sessionPrefix.length);
          final session = await _getSession(sessionId);
          if (session != null && session.userId == userId && session.isActive) {
            sessions.add(session);
          }
        }
      }

      return sessions;
    } catch (e) {
      _logger.error('Failed to get all active sessions', e);
      return [];
    }
  }

  Future<Session?> _getSession(String sessionId) async {
    try {
      final data = await _storage.read('$_sessionPrefix$sessionId');
      if (data == null) return null;

      final map = Map<String, dynamic>.from(
        Map<String, dynamic>.from(
          const JsonDecoder().convert(data),
        ),
      );

      return Session(
        id: map['id'] as String,
        userId: map['userId'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        expiresAt: DateTime.parse(map['expiresAt'] as String),
        status: SessionStatus.values[map['status'] as int],
        metadata: map['metadata'] as Map<String, dynamic>,
      );
    } catch (e) {
      _logger.error('Failed to get session', e);
      return null;
    }
  }

  Future<void> _saveSession(Session session) async {
    try {
      final data = {
        'id': session.id,
        'userId': session.userId,
        'createdAt': session.createdAt.toIso8601String(),
        'expiresAt': session.expiresAt.toIso8601String(),
        'status': session.status.index,
        'metadata': session.metadata,
      };

      await _storage.write(
        '$_sessionPrefix${session.id}',
        const JsonEncoder().convert(data),
      );
    } catch (e) {
      _logger.error('Failed to save session', e);
      rethrow;
    }
  }

  void _notifySessionEvent(SessionEvent event) {
    _sessionController.add(event);
  }
}
