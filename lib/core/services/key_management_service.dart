import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/api.dart' show ParametersWithRandom;
import '../interfaces/key_management_interface.dart';
import '../interfaces/logger_service.dart';
import '../storage/secure_storage.dart';

@LazySingleton(as: IKeyManagementService)
class KeyManagementService implements IKeyManagementService {
  final SecureStorage _storage;
  final ILoggerService _logger;
  final _keyChangeController = StreamController<KeyChangeEvent>.broadcast();

  static const int _keySize = 2048;
  static const String _publicKeyPrefix = 'public_key_';
  static const String _privateKeyPrefix = 'private_key_';

  KeyManagementService(this._storage, this._logger);

  @override
  Stream<KeyChangeEvent> get keyChangeStream => _keyChangeController.stream;

  @override
  Future<void> initialize() async {
    _logger.info('Initializing KeyManagementService');
    try {
      final keys = await _storage.getAllKeys();
      for (final key in keys) {
        if (key.startsWith(_publicKeyPrefix)) {
          final userId = key.substring(_publicKeyPrefix.length);
          if (!await verifyKeyPair(userId)) {
            _logger.warning('Invalid key pair detected for user: $userId');
          }
        }
      }
    } catch (e) {
      _logger.error('Error during key verification', e);
    }
  }

  @override
  Future<void> dispose() async {
    await _keyChangeController.close();
  }

  @override
  Future<void> generateKeyPair(String userId) async {
    try {
      final secureRandom = FortunaRandom();
      final keyGen = RSAKeyGenerator();
      keyGen.init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), _keySize, 64),
        secureRandom,
      ));

      final pair = keyGen.generateKeyPair();
      final publicKey = pair.publicKey as RSAPublicKey;
      final privateKey = pair.privateKey as RSAPrivateKey;

      await _storage.write(
          '$_publicKeyPrefix$userId', _encodePublicKey(publicKey));
      await _storage.write(
          '$_privateKeyPrefix$userId', _encodePrivateKey(privateKey));

      _notifyKeyChange(userId, KeyChangeType.generated);
      _logger.info('Generated new key pair for user: $userId');
    } catch (e) {
      _logger.error('Failed to generate key pair', e);
      rethrow;
    }
  }

  @override
  Future<RSAPublicKey?> getPublicKey(String userId) async {
    try {
      final encoded = await _storage.read('$_publicKeyPrefix$userId');
      if (encoded == null) return null;
      return _decodePublicKey(encoded);
    } catch (e) {
      _logger.error('Failed to get public key', e);
      return null;
    }
  }

  @override
  Future<RSAPrivateKey?> getCurrentUserPrivateKey() async {
    try {
      // TODO: Implementirati getCurrentUserId
      final userId = 'current_user';
      final encoded = await _storage.read('$_privateKeyPrefix$userId');
      if (encoded == null) return null;
      return _decodePrivateKey(encoded);
    } catch (e) {
      _logger.error('Failed to get private key', e);
      return null;
    }
  }

  @override
  Future<void> rotateKeys(String userId) async {
    try {
      await generateKeyPair(userId);
      _notifyKeyChange(userId, KeyChangeType.rotated);
    } catch (e) {
      _logger.error('Failed to rotate keys', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteKeys(String userId) async {
    try {
      await _storage.delete('$_publicKeyPrefix$userId');
      await _storage.delete('$_privateKeyPrefix$userId');
      _notifyKeyChange(userId, KeyChangeType.deleted);
    } catch (e) {
      _logger.error('Failed to delete keys', e);
      rethrow;
    }
  }

  @override
  Future<String> exportPublicKey(String userId) async {
    final key = await getPublicKey(userId);
    if (key == null) throw Exception('Public key not found');
    return _encodePEM(key);
  }

  @override
  Future<void> importPublicKey(String userId, String pemKey) async {
    try {
      final key = _decodePEM(pemKey);
      await _storage.write('$_publicKeyPrefix$userId', _encodePublicKey(key));
      _notifyKeyChange(userId, KeyChangeType.imported);
    } catch (e) {
      _logger.error('Failed to import public key', e);
      rethrow;
    }
  }

  @override
  Future<bool> verifyKeyPair(String userId) async {
    try {
      final publicKey = await getPublicKey(userId);
      final privateKey = await getCurrentUserPrivateKey();
      if (publicKey == null || privateKey == null) return false;

      return publicKey.modulus == privateKey.modulus &&
          publicKey.exponent == privateKey.publicExponent;
    } catch (e) {
      _logger.error('Failed to verify key pair', e);
      return false;
    }
  }

  void _notifyKeyChange(String userId, KeyChangeType type) {
    _keyChangeController.add(KeyChangeEvent(
      userId: userId,
      type: type,
      timestamp: DateTime.now(),
    ));
  }

  String _encodePublicKey(RSAPublicKey key) {
    return json.encode({
      'modulus': key.modulus.toString(),
      'exponent': key.exponent.toString(),
    });
  }

  String _encodePrivateKey(RSAPrivateKey key) {
    return json.encode({
      'modulus': key.modulus.toString(),
      'privateExponent': key.privateExponent.toString(),
      'p': key.p.toString(),
      'q': key.q.toString(),
    });
  }

  RSAPublicKey _decodePublicKey(String encoded) {
    final map = json.decode(encoded) as Map<String, dynamic>;
    return RSAPublicKey(
      BigInt.parse(map['modulus'] as String),
      BigInt.parse(map['exponent'] as String),
    );
  }

  RSAPrivateKey _decodePrivateKey(String encoded) {
    final map = json.decode(encoded) as Map<String, dynamic>;
    return RSAPrivateKey(
      BigInt.parse(map['modulus'] as String),
      BigInt.parse(map['privateExponent'] as String),
      BigInt.parse(map['p'] as String),
      BigInt.parse(map['q'] as String),
    );
  }

  String _encodePEM(RSAPublicKey key) {
    final encoded = _encodePublicKey(key);
    final base64 = base64Encode(utf8.encode(encoded));
    return '''-----BEGIN PUBLIC KEY-----
$base64
-----END PUBLIC KEY-----''';
  }

  RSAPublicKey _decodePEM(String pem) {
    final lines = pem.split('\n');
    final base64 = lines
        .where((line) =>
            !line.startsWith('-----BEGIN') && !line.startsWith('-----END'))
        .join('');
    final decoded = utf8.decode(base64Decode(base64));
    return _decodePublicKey(decoded);
  }
}
