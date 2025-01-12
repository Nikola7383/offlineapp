import 'package:injectable/injectable.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/interfaces/base_service.dart';
import 'dart:convert';
import 'dart:typed_data';

/// Servis za upravljanje kriptografskim ključevima
@LazySingleton()
class KeyService implements IService {
  static const _publicKeyPrefix = 'public_key_';
  static const _privateKeyPrefix = 'private_key_';

  late final SharedPreferences _prefs;
  final _keyCache = <String, RSAPublicKey>{};
  late final RSAPrivateKey _privateKey;
  late final RSAPublicKey _publicKey;

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _initializeKeyPair();
  }

  @override
  Future<void> dispose() async {
    _keyCache.clear();
  }

  /// Inicijalizuje par ključeva
  Future<void> _initializeKeyPair() async {
    final existingPrivateKey = _prefs.getString(_privateKeyPrefix);
    final existingPublicKey = _prefs.getString(_publicKeyPrefix);

    if (existingPrivateKey != null && existingPublicKey != null) {
      _privateKey = _decodePrivateKey(existingPrivateKey);
      _publicKey = _decodePublicKey(existingPublicKey);
    } else {
      final keyPair = await _generateKeyPair();
      _privateKey = keyPair.privateKey as RSAPrivateKey;
      _publicKey = keyPair.publicKey as RSAPublicKey;

      await _saveKeyPair();
    }
  }

  /// Generiše novi par ključeva
  Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>>
      _generateKeyPair() async {
    final secureRandom = FortunaRandom();
    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        secureRandom,
      ));

    return keyGen.generateKeyPair();
  }

  /// Čuva par ključeva
  Future<void> _saveKeyPair() async {
    final privateKeyStr = _encodePrivateKey(_privateKey);
    final publicKeyStr = _encodePublicKey(_publicKey);

    await _prefs.setString(_privateKeyPrefix, privateKeyStr);
    await _prefs.setString(_publicKeyPrefix, publicKeyStr);
  }

  /// Vraća privatni ključ
  RSAPrivateKey get privateKey => _privateKey;

  /// Vraća javni ključ
  RSAPublicKey get publicKey => _publicKey;

  /// Čuva javni ključ drugog korisnika
  Future<void> savePublicKey(String userId, RSAPublicKey key) async {
    final keyStr = _encodePublicKey(key);
    await _prefs.setString('$_publicKeyPrefix$userId', keyStr);
    _keyCache[userId] = key;
  }

  /// Vraća javni ključ drugog korisnika
  Future<RSAPublicKey?> getPublicKey(String userId) async {
    if (_keyCache.containsKey(userId)) {
      return _keyCache[userId];
    }

    final keyStr = _prefs.getString('$_publicKeyPrefix$userId');
    if (keyStr == null) return null;

    final key = _decodePublicKey(keyStr);
    _keyCache[userId] = key;
    return key;
  }

  /// Enkodira privatni ključ u string
  String _encodePrivateKey(RSAPrivateKey key) {
    final map = {
      'modulus': key.modulus.toString(),
      'exponent': key.privateExponent.toString(),
      'p': key.p.toString(),
      'q': key.q.toString()
    };
    return base64.encode(utf8.encode(json.encode(map)));
  }

  /// Dekodira privatni ključ iz stringa
  RSAPrivateKey _decodePrivateKey(String encoded) {
    final map = json.decode(utf8.decode(base64.decode(encoded)))
        as Map<String, dynamic>;
    return RSAPrivateKey(
      BigInt.parse(map['modulus'] as String),
      BigInt.parse(map['exponent'] as String),
      BigInt.parse(map['p'] as String),
      BigInt.parse(map['q'] as String),
    );
  }

  /// Enkodira javni ključ u string
  String _encodePublicKey(RSAPublicKey key) {
    final map = {
      'modulus': key.modulus.toString(),
      'exponent': key.publicExponent.toString(),
    };
    return base64.encode(utf8.encode(json.encode(map)));
  }

  /// Dekodira javni ključ iz stringa
  RSAPublicKey _decodePublicKey(String encoded) {
    final map = json.decode(utf8.decode(base64.decode(encoded)))
        as Map<String, dynamic>;
    return RSAPublicKey(
      BigInt.parse(map['modulus'] as String),
      BigInt.parse(map['exponent'] as String),
    );
  }
}
