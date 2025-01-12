import 'package:pointycastle/asymmetric/api.dart';
import 'base_service.dart';

/// Interfejs za upravljanje ključevima
abstract class IKeyManagementService implements IService {
  /// Generiše novi par ključeva za korisnika
  Future<void> generateKeyPair(String userId);

  /// Vraća javni ključ korisnika
  Future<RSAPublicKey?> getPublicKey(String userId);

  /// Vraća privatni ključ trenutnog korisnika
  Future<RSAPrivateKey?> getCurrentUserPrivateKey();

  /// Rotira ključeve za korisnika
  Future<void> rotateKeys(String userId);

  /// Briše ključeve korisnika
  Future<void> deleteKeys(String userId);

  /// Eksportuje javni ključ u PEM format
  Future<String> exportPublicKey(String userId);

  /// Importuje javni ključ iz PEM formata
  Future<void> importPublicKey(String userId, String pemKey);

  /// Verifikuje validnost ključa
  Future<bool> verifyKeyPair(String userId);

  /// Stream za praćenje promena ključeva
  Stream<KeyChangeEvent> get keyChangeStream;
}

/// Event za promenu ključa
class KeyChangeEvent {
  final String userId;
  final KeyChangeType type;
  final DateTime timestamp;

  KeyChangeEvent({
    required this.userId,
    required this.type,
    required this.timestamp,
  });
}

/// Tip promene ključa
enum KeyChangeType {
  /// Generisan novi ključ
  generated,

  /// Rotiran ključ
  rotated,

  /// Obrisan ključ
  deleted,

  /// Importovan ključ
  imported,

  /// Istekao ključ
  expired
}
