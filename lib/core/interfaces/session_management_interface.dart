import 'dart:async';
import 'base_service.dart';

/// Status sesije
enum SessionStatus {
  /// Aktivna sesija
  active,

  /// Istekla sesija
  expired,

  /// Suspendovana sesija
  suspended,

  /// Zaključana sesija
  locked,

  /// Odjavljeno
  loggedOut
}

/// Model sesije
class Session {
  /// ID sesije
  final String id;

  /// ID korisnika
  final String userId;

  /// Vreme kreiranja
  final DateTime createdAt;

  /// Vreme isteka
  final DateTime expiresAt;

  /// Status sesije
  final SessionStatus status;

  /// Metadata podaci
  final Map<String, dynamic> metadata;

  Session({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    this.metadata = const {},
  });

  /// Proverava da li je sesija istekla
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Proverava da li je sesija aktivna
  bool get isActive => status == SessionStatus.active && !isExpired;
}

/// Event za promenu sesije
class SessionEvent {
  /// ID sesije
  final String sessionId;

  /// Tip promene
  final SessionEventType type;

  /// Vreme promene
  final DateTime timestamp;

  /// Metadata podaci
  final Map<String, dynamic> metadata;

  SessionEvent({
    required this.sessionId,
    required this.type,
    required this.timestamp,
    this.metadata = const {},
  });
}

/// Tip promene sesije
enum SessionEventType {
  /// Kreirana nova sesija
  created,

  /// Sesija istekla
  expired,

  /// Sesija suspendovana
  suspended,

  /// Sesija zaključana
  locked,

  /// Korisnik se odjavio
  loggedOut,

  /// Sesija obnovljena
  renewed,

  /// Sesija validirana
  validated
}

/// Interfejs za upravljanje sesijama
abstract class ISessionManagementService implements IService {
  /// Kreira novu sesiju
  Future<Session> createSession({
    required String userId,
    Duration? duration,
    Map<String, dynamic>? metadata,
  });

  /// Validira sesiju
  Future<bool> validateSession(String sessionId);

  /// Obnavlja sesiju
  Future<Session> renewSession(String sessionId, {Duration? duration});

  /// Suspenduje sesiju
  Future<void> suspendSession(String sessionId);

  /// Zaključava sesiju
  Future<void> lockSession(String sessionId);

  /// Odjavljuje korisnika
  Future<void> logout(String sessionId);

  /// Briše sesiju
  Future<void> deleteSession(String sessionId);

  /// Vraća aktivnu sesiju za korisnika
  Future<Session?> getActiveSession(String userId);

  /// Vraća sve aktivne sesije za korisnika
  Future<List<Session>> getAllActiveSessions(String userId);

  /// Stream za praćenje promena sesija
  Stream<SessionEvent> get sessionStream;
}
