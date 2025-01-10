import 'dart:typed_data';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Upravlja enkripcijom i dekripcijom verifikacionih tokena
class TokenEncryption {
  // Konstante za enkripciju
  static const int KEY_SIZE = 32; // 256 bit
  static const int TOKEN_SIZE = 32;
  static const int NONCE_SIZE = 12;
  static const int VERSION = 1;

  // Konstante za QR kod
  static const String QR_PREFIX = 'SEC:';
  static const int MAX_QR_VERSION = 4;
  static const String QR_ERROR_CORRECTION = 'M';

  // Ključevi za enkripciju
  late final Key _masterKey;
  late final IV _iv;
  late final Encrypter _encrypter;

  // Keš za derivirane ključeve
  final Map<String, Key> _derivedKeys = {};

  TokenEncryption() {
    _initializeEncryption();
  }

  /// Inicijalizuje enkripciju
  void _initializeEncryption() {
    // Generiši master ključ
    final random = Random.secure();
    final keyBytes = List<int>.generate(KEY_SIZE, (_) => random.nextInt(256));
    _masterKey = Key(Uint8List.fromList(keyBytes));

    // Inicijalizuj IV i encrypter
    _iv = IV.fromSecureRandom(16);
    _encrypter = Encrypter(AES(_masterKey, mode: AESMode.gcm));
  }

  /// Generiše novi token sa enkripcijom
  Future<VerificationToken> generateToken({
    String? context,
    Duration validity = const Duration(minutes: 5),
  }) async {
    // Generiši random token
    final random = Random.secure();
    final tokenBytes =
        List<int>.generate(TOKEN_SIZE, (_) => random.nextInt(256));

    // Dodaj metadata
    final metadata = _generateMetadata(validity);
    final combinedData = _combineTokenAndMetadata(tokenBytes, metadata);

    // Deriviraj ključ za kontekst
    final encryptionKey = await _deriveKeyForContext(context);

    // Enkriptuj token
    final encrypted = _encryptToken(combinedData, encryptionKey);

    // Generiši QR podatke
    final qrData = _generateQRData(encrypted, metadata);

    return VerificationToken(
      token: base64Encode(tokenBytes),
      encryptedToken: base64Encode(encrypted),
      qrData: qrData,
      metadata: metadata,
      validUntil: DateTime.now().add(validity),
    );
  }

  /// Validira token
  Future<bool> validateToken(
    String encryptedToken,
    String originalToken, {
    String? context,
  }) async {
    try {
      // Dekoduj enkriptovani token
      final encryptedBytes = base64Decode(encryptedToken);

      // Izdvoji metadata
      final metadata = _extractMetadata(encryptedBytes);
      if (!_isMetadataValid(metadata)) return false;

      // Deriviraj ključ za kontekst
      final decryptionKey = await _deriveKeyForContext(context);

      // Dekriptuj token
      final decryptedBytes = _decryptToken(encryptedBytes, decryptionKey);
      if (decryptedBytes == null) return false;

      // Izdvoji token iz dekriptovanih podataka
      final decryptedToken = _extractToken(decryptedBytes);

      // Uporedi sa originalom
      return base64Encode(decryptedToken) == originalToken;
    } catch (e) {
      print('Greška pri validaciji tokena: $e');
      return false;
    }
  }

  /// Derivira ključ za specifični kontekst
  Future<Key> _deriveKeyForContext(String? context) async {
    if (context == null) return _masterKey;

    // Proveri keš
    if (_derivedKeys.containsKey(context)) {
      return _derivedKeys[context]!;
    }

    // HKDF derivacija ključa
    final keyBytes = List<int>.generate(KEY_SIZE, (i) {
      final hmac = Hmac(sha256, _masterKey.bytes);
      final message = utf8.encode('${context}_$i');
      return hmac.convert(message).bytes[0];
    });

    final derivedKey = Key(Uint8List.fromList(keyBytes));
    _derivedKeys[context] = derivedKey;
    return derivedKey;
  }

  /// Generiše metadata za token
  Map<String, dynamic> _generateMetadata(Duration validity) {
    return {
      'version': VERSION,
      'created': DateTime.now().toIso8601String(),
      'validUntil': DateTime.now().add(validity).toIso8601String(),
      'nonce': base64Encode(IV.fromSecureRandom(NONCE_SIZE).bytes),
    };
  }

  /// Kombinuje token i metadata
  Uint8List _combineTokenAndMetadata(
    List<int> tokenBytes,
    Map<String, dynamic> metadata,
  ) {
    final metadataJson = jsonEncode(metadata);
    final metadataBytes = utf8.encode(metadataJson);

    // Format: [token_size(2)][token(n)][metadata_size(2)][metadata(n)]
    final combined = ByteData(2 + tokenBytes.length + 2 + metadataBytes.length);

    combined.setUint16(0, tokenBytes.length, Endian.big);
    combined.buffer.asUint8List(2, tokenBytes.length).setAll(0, tokenBytes);

    combined.setUint16(
      2 + tokenBytes.length,
      metadataBytes.length,
      Endian.big,
    );
    combined.buffer
        .asUint8List(4 + tokenBytes.length, metadataBytes.length)
        .setAll(0, metadataBytes);

    return combined.buffer.asUint8List();
  }

  /// Enkriptuje token
  Uint8List _encryptToken(Uint8List data, Key key) {
    final encrypted = _encrypter.encryptBytes(data, iv: _iv);
    return encrypted.bytes;
  }

  /// Dekriptuje token
  Uint8List? _decryptToken(Uint8List encryptedData, Key key) {
    try {
      final decrypted = _encrypter.decryptBytes(
        Encrypted(encryptedData),
        iv: _iv,
      );
      return Uint8List.fromList(decrypted);
    } catch (e) {
      print('Greška pri dekripciji: $e');
      return null;
    }
  }

  /// Izdvaja metadata iz enkriptovanih podataka
  Map<String, dynamic> _extractMetadata(Uint8List encryptedData) {
    final data = ByteData.view(encryptedData.buffer);
    final tokenSize = data.getUint16(0, Endian.big);
    final metadataSize = data.getUint16(2 + tokenSize, Endian.big);
    final metadataBytes = encryptedData.sublist(
      4 + tokenSize,
      4 + tokenSize + metadataSize,
    );
    return jsonDecode(utf8.decode(metadataBytes));
  }

  /// Izdvaja token iz dekriptovanih podataka
  Uint8List _extractToken(Uint8List decryptedData) {
    final data = ByteData.view(decryptedData.buffer);
    final tokenSize = data.getUint16(0, Endian.big);
    return decryptedData.sublist(2, 2 + tokenSize);
  }

  /// Generiše podatke za QR kod
  String _generateQRData(
      Uint8List encryptedToken, Map<String, dynamic> metadata) {
    final qrData = {
      'v': VERSION,
      't': base64Encode(encryptedToken),
      'm': metadata,
    };
    return '$QR_PREFIX${jsonEncode(qrData)}';
  }

  /// Validira metadata
  bool _isMetadataValid(Map<String, dynamic> metadata) {
    try {
      final version = metadata['version'] as int;
      if (version != VERSION) return false;

      final validUntil = DateTime.parse(metadata['validUntil'] as String);
      if (validUntil.isBefore(DateTime.now())) return false;

      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Model za verifikacioni token
class VerificationToken {
  final String token;
  final String encryptedToken;
  final String qrData;
  final Map<String, dynamic> metadata;
  final DateTime validUntil;

  VerificationToken({
    required this.token,
    required this.encryptedToken,
    required this.qrData,
    required this.metadata,
    required this.validUntil,
  });

  bool get isValid => validUntil.isAfter(DateTime.now());
}
