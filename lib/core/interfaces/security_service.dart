import 'dart:typed_data';
import 'base_service.dart';

/// Interfejs za enkripcijski servis
abstract class IEncryptionService implements ISecureService {
  /// Enkriptuje podatke
  Future<Uint8List> encrypt(Uint8List data, {String? keyId});

  /// Dekriptuje podatke
  Future<Uint8List> decrypt(Uint8List data, {String? keyId});

  /// Generiše novi ključ
  Future<String> generateKey();

  /// Rotira ključeve
  Future<void> rotateKeys();

  /// Briše ključ
  Future<void> deleteKey(String keyId);

  /// Proverava validnost ključa
  Future<bool> isKeyValid(String keyId);
}

/// Interfejs za sesijski servis
abstract class ISessionService implements ISecureService {
  /// Kreira novu sesiju
  Future<Session> createSession(String userId);

  /// Validira sesiju
  Future<bool> validateSession(String sessionId);

  /// Osvežava sesiju
  Future<Session> refreshSession(String sessionId);

  /// Poništava sesiju
  Future<void> invalidateSession(String sessionId);

  /// Vraća informacije o sesiji
  Future<Session?> getSession(String sessionId);

  /// Stream za praćenje isteklih sesija
  Stream<String> get expiredSessions;
}

/// Interfejs za upravljanje ključevima
abstract class IKeyRotationManager implements ISecureService {
  /// Inicira rotaciju ključeva
  Future<void> initiateRotation();

  /// Proverava status rotacije
  Future<RotationStatus> checkRotationStatus();

  /// Potvrđuje rotaciju
  Future<void> confirmRotation();

  /// Poništava rotaciju
  Future<void> cancelRotation();

  /// Stream za praćenje statusa rotacije
  Stream<RotationStatus> get rotationStatusStream;
}

/// Sesija korisnika
class Session {
  /// ID sesije
  final String id;

  /// ID korisnika
  final String userId;

  /// Vreme kreiranja
  final DateTime createdAt;

  /// Vreme isteka
  final DateTime expiresAt;

  /// Metadata sesije
  final Map<String, dynamic> metadata;

  /// Kreira novu sesiju
  Session({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.expiresAt,
    this.metadata = const {},
  });

  /// Da li je sesija istekla
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Status rotacije ključeva
enum RotationStatus {
  /// Nije u toku
  idle,

  /// U procesu
  inProgress,

  /// Uspešno završena
  completed,

  /// Neuspešna
  failed,

  /// Poništena
  cancelled
}
