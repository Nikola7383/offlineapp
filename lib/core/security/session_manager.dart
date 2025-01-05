@injectable
class SessionManager extends InjectableService implements Disposable {
  final _activeSessions = <String, Session>{};
  final _secureStorage = FlutterSecureStorage();

  static const SESSION_TIMEOUT = Duration(hours: 24);

  Future<Session> createSession(User user) async {
    final session = Session(
      id: Uuid().v4(),
      userId: user.id,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(SESSION_TIMEOUT),
    );

    _activeSessions[session.id] = session;
    await _persistSession(session);

    return session;
  }

  Future<bool> validateSession(String sessionId) async {
    final session = _activeSessions[sessionId];
    if (session == null) return false;

    if (session.isExpired) {
      await invalidateSession(sessionId);
      return false;
    }

    return true;
  }

  Future<void> invalidateSession(String sessionId) async {
    _activeSessions.remove(sessionId);
    await _secureStorage.delete(key: 'session_$sessionId');
  }
}

class Session {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DateTime expiresAt;

  Session({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
