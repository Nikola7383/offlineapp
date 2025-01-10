import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:uuid/uuid.dart';
import '../interfaces/base_service.dart';

/// Servis za enkripciju i dekripciju podataka
class EncryptionService extends BaseService {
  late final Key _key;
  late final IV _iv;
  late final Encrypter _encrypter;

  // Trenutni algoritam i parametri
  String _currentAlgorithm = 'AES-256-GCM';
  Map<String, dynamic> _currentParameters = {
    'keySize': 256,
    'mode': 'GCM',
  };

  EncryptionService() {
    _initializeEncryption();
  }

  /// Inicijalizuje enkripcijske komponente
  void _initializeEncryption() {
    // Generisanje ključa iz random podataka
    final keyBytes = SecureRandom(32).bytes;
    _key = Key(keyBytes);

    // Generisanje IV
    _iv = IV.fromSecureRandom(16);

    // Kreiranje encrypter instance
    _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
  }

  /// Generiše sigurnosni ključ
  Future<String> generateSecureKey() async {
    final keyBytes = SecureRandom(32).bytes;
    return base64Encode(keyBytes);
  }

  /// Enkriptuje podatke sa specifičnim algoritmom
  Future<String> encrypt(
    String data, {
    String? key,
    String algorithm = 'AES-256-CBC',
  }) async {
    try {
      final encryptionKey = key != null ? Key(base64Decode(key)) : _key;
      final encrypter = _getEncrypter(algorithm, encryptionKey);

      // Dodaj salt i timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final salt = SecureRandom(16).base64;
      final dataToEncrypt = '$salt:$timestamp:$data';

      // Enkriptuj podatke
      final encrypted = encrypter.encrypt(dataToEncrypt, iv: _iv);

      // Dodaj HMAC za integritet
      final hmac = await _generateHMAC(encrypted.bytes);

      // Kombinuj sve u finalni string
      return '${base64Encode(encrypted.bytes)}.$hmac.${base64Encode(_iv.bytes)}';
    } catch (e) {
      throw Exception('Enkripcija nije uspela: $e');
    }
  }

  /// Dekriptuje podatke sa specifičnim algoritmom
  Future<String> decrypt(
    String encryptedData, {
    String? key,
    String algorithm = 'AES-256-CBC',
  }) async {
    try {
      final decryptionKey = key != null ? Key(base64Decode(key)) : _key;
      final encrypter = _getEncrypter(algorithm, decryptionKey);

      // Razdvoji komponente
      final parts = encryptedData.split('.');
      if (parts.length != 3) {
        throw FormatException('Neispravan format enkriptovanih podataka');
      }

      final encryptedBytes = base64Decode(parts[0]);
      final hmac = parts[1];
      final ivBytes = base64Decode(parts[2]);

      // Verifikuj HMAC
      final calculatedHmac =
          await _generateHMAC(Uint8List.fromList(encryptedBytes));
      if (hmac != calculatedHmac) {
        throw SecurityException('Integritet podataka je narušen');
      }

      // Dekriptuj podatke
      final iv = IV(ivBytes);
      final decrypted = encrypter.decrypt64(parts[0], iv: iv);

      // Izvuci originalne podatke
      final dataParts = decrypted.split(':');
      if (dataParts.length != 3) {
        throw FormatException('Neispravan format dekriptovanih podataka');
      }

      // Proveri timestamp
      final timestamp = int.parse(dataParts[1]);
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > const Duration(minutes: 5).inMilliseconds) {
        throw SecurityException('Podaci su istekli');
      }

      return dataParts[2];
    } catch (e) {
      throw Exception('Dekripcija nije uspela: $e');
    }
  }

  /// Kreira encrypter za specifični algoritam
  Encrypter _getEncrypter(String algorithm, Key key) {
    switch (algorithm) {
      case 'AES-256-GCM':
        return Encrypter(AES(key, mode: AESMode.gcm));
      case 'AES-256-CBC':
        return Encrypter(AES(key, mode: AESMode.cbc));
      default:
        throw UnsupportedError('Nepodržani algoritam: $algorithm');
    }
  }

  /// Generiše HMAC za verifikaciju integriteta
  Future<String> _generateHMAC(Uint8List data) async {
    final hmacSha256 = Hmac(sha256, _key.bytes);
    final digest = hmacSha256.convert(data);
    return digest.toString();
  }

  /// Ažurira algoritam enkripcije sa novim parametrima
  Future<void> updateAlgorithm(
      String algorithm, Map<String, dynamic> parameters) async {
    _currentAlgorithm = algorithm;
    _currentParameters = Map<String, dynamic>.from(parameters);

    // Generiši novi ključ i IV
    final keySize = parameters['keySize'] as int? ?? 256;
    final keyBytes = SecureRandom(keySize ~/ 8).bytes;
    _key = Key(keyBytes);
    _iv = IV.fromSecureRandom(16);

    // Kreiraj novu instancu encrypter-a
    switch (algorithm) {
      case 'AES-256-GCM':
        _encrypter = Encrypter(AES(_key, mode: AESMode.gcm));
        break;
      case 'AES-256-CBC':
        _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
        break;
      default:
        throw UnsupportedError('Nepodržani algoritam: $algorithm');
    }
  }

  /// Vraća trenutni algoritam
  String get currentAlgorithm => _currentAlgorithm;

  /// Vraća trenutne parametre
  Map<String, dynamic> get currentParameters =>
      Map<String, dynamic>.from(_currentParameters);
}

/// Izuzetak za sigurnosne probleme
class SecurityException implements Exception {
  final String message;

  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
