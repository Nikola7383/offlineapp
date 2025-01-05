import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import '../base/base_service.dart';
import '../models/message.dart';
import '../services/logger_service.dart';
import '../interfaces/encryption_interface.dart';
import 'package:meta/meta.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';

@injectable
class EncryptionService extends InjectableService {
  late SecureRandom _random;
  late KeyPair _currentKeyPair;
  final Map<String, PublicKey> _peerKeys = {};
  final _keyRotationInterval = const Duration(days: 1);
  Timer? _keyRotationTimer;

  static const KEY_SIZE = 2048;
  static const CIPHER_ALGORITHM = 'AES-256-GCM';

  @override
  Future<void> initialize() async {
    await super.initialize();
    _random = SecureRandom();
    await _generateNewKeyPair();
    _startKeyRotation();
  }

  Future<void> _generateNewKeyPair() async {
    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), KEY_SIZE, 64),
        _random,
      ));

    _currentKeyPair = keyGen.generateKeyPair();
    await _notifyPeersOfNewKey();
  }

  void _startKeyRotation() {
    _keyRotationTimer = Timer.periodic(
      _keyRotationInterval,
      (_) => _rotateKeys(),
    );
  }

  Future<void> _rotateKeys() async {
    try {
      await _generateNewKeyPair();
      logger.info('Key rotation completed successfully');
    } catch (e, stack) {
      logger.error('Key rotation failed', e, stack);
    }
  }

  Future<EncryptedData> encrypt(
    List<int> data,
    String recipientId,
  ) async {
    final recipientKey = _peerKeys[recipientId];
    if (recipientKey == null) {
      throw SecurityException('No public key found for $recipientId');
    }

    final sessionKey = _generateSessionKey();
    final encryptedSessionKey = _encryptSessionKey(
      sessionKey,
      recipientKey,
    );

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
          true,
          AEADParameters(
            KeyParameter(sessionKey),
            128,
            _generateIV(),
            Uint8List(0),
          ));

    final encrypted = cipher.process(Uint8List.fromList(data));

    return EncryptedData(
      data: encrypted,
      sessionKey: encryptedSessionKey,
      iv: cipher.nonce,
    );
  }

  Future<List<int>> decrypt(EncryptedData encryptedData) async {
    final sessionKey = _decryptSessionKey(encryptedData.sessionKey);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
          false,
          AEADParameters(
            KeyParameter(sessionKey),
            128,
            encryptedData.iv,
            Uint8List(0),
          ));

    return cipher.process(encryptedData.data);
  }

  @override
  Future<void> dispose() async {
    _keyRotationTimer?.cancel();
    await super.dispose();
  }
}

class EncryptedMessage {
  final String id;
  final String content;
  final String signature;
  final DateTime timestamp;

  EncryptedMessage({
    required this.id,
    required this.content,
    required this.signature,
    required this.timestamp,
  });
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
