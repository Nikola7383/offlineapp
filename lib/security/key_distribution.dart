import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'secure_logger.dart';

class KeyDistribution {
  static final KeyDistribution _instance = KeyDistribution._internal();
  final Random _random = Random.secure();
  final SecureLogger _logger = SecureLogger();

  // Mapa za čuvanje ključeva
  final Map<String, String> _keyStore = {};

  factory KeyDistribution() {
    return _instance;
  }

  KeyDistribution._internal();

  Future<String> generateKey(String identifier) async {
    try {
      final key = List<int>.generate(32, (i) => _random.nextInt(256));
      final keyHash = sha256.convert(key).toString();
      _keyStore[identifier] = keyHash;

      await _logger.structuredLog(
        event: 'key_generated',
        level: LogLevel.info,
        data: {
          'identifier': identifier,
          'key_length': key.length,
        },
      );

      return keyHash;
    } catch (e, stack) {
      await _logger.structuredLog(
        event: 'key_generation_error',
        level: LogLevel.error,
        data: {'error': e.toString()},
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<bool> validateKey(String identifier, String key) async {
    try {
      final storedKey = _keyStore[identifier];
      if (storedKey == null) {
        await _logger.structuredLog(
          event: 'key_validation_failed',
          level: LogLevel.warning,
          data: {
            'identifier': identifier,
            'reason': 'key_not_found',
          },
        );
        return false;
      }

      final isValid = storedKey == key;
      await _logger.structuredLog(
        event: 'key_validated',
        level: LogLevel.info,
        data: {
          'identifier': identifier,
          'is_valid': isValid,
        },
      );

      return isValid;
    } catch (e, stack) {
      await _logger.structuredLog(
        event: 'key_validation_error',
        level: LogLevel.error,
        data: {'error': e.toString()},
        stackTrace: stack,
      );
      return false;
    }
  }

  Future<void> revokeKey(String identifier) async {
    try {
      _keyStore.remove(identifier);
      await _logger.structuredLog(
        event: 'key_revoked',
        level: LogLevel.warning,
        data: {'identifier': identifier},
      );
    } catch (e, stack) {
      await _logger.structuredLog(
        event: 'key_revocation_error',
        level: LogLevel.error,
        data: {
          'identifier': identifier,
          'error': e.toString(),
        },
        stackTrace: stack,
      );
    }
  }

  Future<void> rotateKey(String identifier) async {
    try {
      final newKey = await generateKey(identifier);
      await _logger.structuredLog(
        event: 'key_rotated',
        level: LogLevel.info,
        data: {'identifier': identifier},
      );
    } catch (e, stack) {
      await _logger.structuredLog(
        event: 'key_rotation_error',
        level: LogLevel.error,
        data: {
          'identifier': identifier,
          'error': e.toString(),
        },
        stackTrace: stack,
      );
    }
  }

  // Čišćenje resursa
  Future<void> dispose() async {
    _keyStore.clear();
    await _logger.structuredLog(
      event: 'key_store_cleared',
      level: LogLevel.warning,
      data: {'timestamp': DateTime.now().toIso8601String()},
    );
  }
}
