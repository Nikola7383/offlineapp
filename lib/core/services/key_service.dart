import 'package:injectable/injectable.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import '../interfaces/base_service.dart';
import 'package:shared_preferences.dart';
import 'network_service.dart';
import 'dart:convert';
import 'dart:typed_data';

/// Servis za upravljanje ključevima
@LazySingleton()
class KeyService implements IService {
  final SharedPreferences _prefs;
  final NetworkService _networkService;
  final Map<String, RSAPublicKey> _publicKeyCache = {};
  RSAPrivateKey? _privateKey;

  static const String _privateKeyKey = 'private_key';
  static const String _publicKeyKey = 'public_key';

  KeyService(this._prefs, this._networkService);

  @override
  Future<void> initialize() async {
    await _loadKeys();
  }

  @override
  Future<void> dispose() async {
    _publicKeyCache.clear();
    _privateKey = null;
  }

  /// Vraća privatni ključ
  Future<RSAPrivateKey> getPrivateKey() async {
    if (_privateKey != null) {
      return _privateKey!;
    }

    final privateKeyStr = _prefs.getString(_privateKeyKey);
    if (privateKeyStr == null) {
      final keyPair = await generateKeyPair();
      return keyPair.privateKey;
    }

    _privateKey = _decodeKey(privateKeyStr) as RSAPrivateKey;
    return _privateKey!;
  }

  /// Vraća javni ključ za dati ID
  Future<RSAPublicKey?> getPublicKey(String userId) async {
    if (_publicKeyCache.containsKey(userId)) {
      return _publicKeyCache[userId];
    }

    final publicKeyStr = await _networkService.getPublicKey(userId);
    if (publicKeyStr == null) {
      return null;
    }

    final publicKey = _decodeKey(publicKeyStr) as RSAPublicKey;
    _publicKeyCache[userId] = publicKey;
    return publicKey;
  }

  /// Čuva javni ključ za dati ID
  Future<void> savePublicKey(String userId, RSAPublicKey publicKey) async {
    _publicKeyCache[userId] = publicKey;
    final publicKeyStr = _encodeKey(publicKey);
    await _networkService.savePublicKey(userId, publicKeyStr);
  }

  /// Generiše novi par ključeva
  Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>>
      generateKeyPair() async {
    final keyGen = KeyGenerator('RSA');
    final pair = await keyGen.generateKeyPair();

    final publicKey = pair.publicKey as RSAPublicKey;
    final privateKey = pair.privateKey as RSAPrivateKey;

    await _saveKeyPair(publicKey, privateKey);
    return pair as AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>;
  }

  /// Čuva par ključeva
  Future<void> _saveKeyPair(
      RSAPublicKey publicKey, RSAPrivateKey privateKey) async {
    final publicKeyStr = _encodeKey(publicKey);
    final privateKeyStr = _encodeKey(privateKey);

    await _prefs.setString(_publicKeyKey, publicKeyStr);
    await _prefs.setString(_privateKeyKey, privateKeyStr);
    _privateKey = privateKey;
  }

  /// Učitava ključeve iz storage-a
  Future<void> _loadKeys() async {
    final publicKeyStr = _prefs.getString(_publicKeyKey);
    final privateKeyStr = _prefs.getString(_privateKeyKey);

    if (publicKeyStr != null && privateKeyStr != null) {
      try {
        final publicKey = _decodeKey(publicKeyStr) as RSAPublicKey;
        final privateKey = _decodeKey(privateKeyStr) as RSAPrivateKey;

        _privateKey = privateKey;
        _publicKeyCache['current_user'] = publicKey;
      } catch (e) {
        // Ako je došlo do greške pri učitavanju, generišemo nove ključeve
        await generateKeyPair();
      }
    }
  }

  /// Enkodira ključ u string
  String _encodeKey(dynamic key) {
    if (key is RSAPrivateKey) {
      return json.encode({
        'type': 'private',
        'modulus': key.modulus?.toString(),
        'privateExponent': key.privateExponent?.toString(),
        'p': key.p?.toString(),
        'q': key.q?.toString(),
      });
    } else if (key is RSAPublicKey) {
      return json.encode({
        'type': 'public',
        'modulus': key.modulus?.toString(),
        'publicExponent': key.publicExponent?.toString(),
      });
    }
    throw UnsupportedError('Nepodržani tip ključa');
  }

  /// Dekodira ključ iz stringa
  dynamic _decodeKey(String keyStr) {
    final keyMap = json.decode(keyStr) as Map<String, dynamic>;
    final type = keyMap['type'] as String;

    if (type == 'private') {
      return RSAPrivateKey(
        BigInt.parse(keyMap['modulus'] as String),
        BigInt.parse(keyMap['privateExponent'] as String),
        BigInt.parse(keyMap['p'] as String),
        BigInt.parse(keyMap['q'] as String),
      );
    } else if (type == 'public') {
      return RSAPublicKey(
        BigInt.parse(keyMap['modulus'] as String),
        BigInt.parse(keyMap['publicExponent'] as String),
      );
    }
    throw UnsupportedError('Nepodržani tip ključa');
  }
}
