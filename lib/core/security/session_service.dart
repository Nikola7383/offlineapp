import 'package:injectable/injectable.dart';

@injectable
class SecureSessionService extends InjectableService {
  final EncryptionService _encryption;
  final Map<String, SecureSession> _activeSessions = {};
  final _sessionUpdates = StreamController<SessionEvent>.broadcast();

  static const SESSION_TIMEOUT = Duration(hours: 12);
  static const SESSION_REFRESH_INTERVAL = Duration(hours: 1);

  SecureSessionService(
    LoggerService logger,
    this._encryption,
  ) : super(logger);

  Future<SecureSession> establishSession(String peerId) async {
    final sessionId = _generateSessionId();
    final sessionKey = await _generateSessionKey();

    final session = SecureSession(
      id: sessionId,
      peerId: peerId,
      key: sessionKey,
      established: DateTime.now(),
    );

    await _sendSessionProposal(peerId, session);
    _activeSessions[sessionId] = session;

    _sessionUpdates.add(SessionEvent(
      type: SessionEventType.established,
      sessionId: sessionId,
      peerId: peerId,
    ));

    _scheduleSessionRefresh(session);
    return session;
  }

  Future<void> _refreshSession(SecureSession session) async {
    try {
      final newKey = await _generateSessionKey();
      final encryptedKey = await _encryption.encrypt(
        newKey,
        session.peerId,
      );

      await _sendSessionRefresh(
        session.peerId,
        session.id,
        encryptedKey,
      );

      session.updateKey(newKey);

      _sessionUpdates.add(SessionEvent(
        type: SessionEventType.refreshed,
        sessionId: session.id,
        peerId: session.peerId,
      ));
    } catch (e, stack) {
      logger.error('Session refresh failed', e, stack);
      await invalidateSession(session.id);
    }
  }

  void _scheduleSessionRefresh(SecureSession session) {
    Timer(SESSION_REFRESH_INTERVAL, () => _refreshSession(session));
  }

  Future<void> invalidateSession(String sessionId) async {
    final session = _activeSessions.remove(sessionId);
    if (session != null) {
      await _notifySessionInvalidation(session.peerId, sessionId);
      _sessionUpdates.add(SessionEvent(
        type: SessionEventType.invalidated,
        sessionId: sessionId,
        peerId: session.peerId,
      ));
    }
  }

  @override
  Future<void> dispose() async {
    for (final sessionId in _activeSessions.keys.toList()) {
      await invalidateSession(sessionId);
    }
    await _sessionUpdates.close();
    await super.dispose();
  }
}

class SecureSession {
  final String id;
  final String peerId;
  List<int> _key;
  final DateTime established;
  DateTime lastRefreshed;

  SecureSession({
    required this.id,
    required this.peerId,
    required List<int> key,
    required this.established,
  })  : _key = key,
        lastRefreshed = established;

  void updateKey(List<int> newKey) {
    _key = newKey;
    lastRefreshed = DateTime.now();
  }

  bool get isExpired =>
      DateTime.now().difference(established) > SESSION_TIMEOUT;
}
