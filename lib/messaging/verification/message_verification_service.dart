import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../core/interfaces/logger_service.dart';
import '../../core/storage/secure_storage.dart';
import '../interfaces/message_verification_interface.dart';

@LazySingleton(as: IMessageVerificationService)
class MessageVerificationService implements IMessageVerificationService {
  final ILoggerService _logger;
  final SecureStorage _storage;

  static const String _verificationCacheKey = 'message_verification_cache';
  static const Duration _cacheExpiry = Duration(hours: 1);

  MessageVerificationService(this._logger, this._storage);

  @override
  Future<void> initialize() async {
    try {
      _logger.info('Initializing MessageVerificationService');
      await _cleanupExpiredCache();
    } catch (e) {
      _logger.error('Failed to initialize MessageVerificationService', e);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    _logger.info('Disposing MessageVerificationService');
  }

  @override
  Future<bool> verifyMessageIntegrity(String messageId, String hash) async {
    try {
      _logger.info('Verifying message integrity: $messageId');

      // Proveri keš
      final cachedHash = await _getCachedHash(messageId);
      if (cachedHash != null && cachedHash == hash) {
        return true;
      }

      // TODO: Implementirati detaljnu proveru integriteta

      // Keširaj rezultat
      await _cacheHash(messageId, hash);

      return true;
    } catch (e) {
      _logger.error('Failed to verify message integrity', e);
      return false;
    }
  }

  @override
  Future<bool> verifyMessageSignature(
      String messageId, String signature) async {
    try {
      _logger.info('Verifying message signature: $messageId');

      // TODO: Implementirati proveru potpisa

      return true;
    } catch (e) {
      _logger.error('Failed to verify message signature', e);
      return false;
    }
  }

  @override
  Future<bool> verifyMessageTimestamp(
      String messageId, DateTime timestamp) async {
    try {
      _logger.info('Verifying message timestamp: $messageId');

      final now = DateTime.now();
      final difference = now.difference(timestamp);

      // Proveri da li je poruka iz budućnosti
      if (timestamp.isAfter(now)) {
        _logger.warning('Message timestamp is in the future: $messageId');
        return false;
      }

      // Proveri da li je poruka prestara
      if (difference > const Duration(days: 1)) {
        _logger.warning('Message is too old: $messageId');
        return false;
      }

      return true;
    } catch (e) {
      _logger.error('Failed to verify message timestamp', e);
      return false;
    }
  }

  @override
  Future<bool> verifyMessageOrigin(String messageId, String senderId) async {
    try {
      _logger.info('Verifying message origin: $messageId from $senderId');

      // TODO: Implementirati proveru porekla poruke

      return true;
    } catch (e) {
      _logger.error('Failed to verify message origin', e);
      return false;
    }
  }

  Future<String?> _getCachedHash(String messageId) async {
    try {
      final cacheData = await _storage.read(_verificationCacheKey);
      if (cacheData != null) {
        final cache = jsonDecode(cacheData) as Map<String, dynamic>;

        if (cache.containsKey(messageId)) {
          final entry = cache[messageId] as Map<String, dynamic>;
          final timestamp = DateTime.parse(entry['timestamp'] as String);

          if (DateTime.now().difference(timestamp) < _cacheExpiry) {
            return entry['hash'] as String;
          }
        }
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get cached hash', e);
      return null;
    }
  }

  Future<void> _cacheHash(String messageId, String hash) async {
    try {
      final cacheData = await _storage.read(_verificationCacheKey);
      final cache = cacheData != null
          ? jsonDecode(cacheData) as Map<String, dynamic>
          : <String, dynamic>{};

      cache[messageId] = {
        'hash': hash,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _storage.write(_verificationCacheKey, jsonEncode(cache));
    } catch (e) {
      _logger.error('Failed to cache hash', e);
    }
  }

  Future<void> _cleanupExpiredCache() async {
    try {
      final cacheData = await _storage.read(_verificationCacheKey);
      if (cacheData != null) {
        final cache = jsonDecode(cacheData) as Map<String, dynamic>;
        final now = DateTime.now();

        cache.removeWhere((key, value) {
          final entry = value as Map<String, dynamic>;
          final timestamp = DateTime.parse(entry['timestamp'] as String);
          return now.difference(timestamp) > _cacheExpiry;
        });

        await _storage.write(_verificationCacheKey, jsonEncode(cache));
      }
    } catch (e) {
      _logger.error('Failed to cleanup expired cache', e);
    }
  }
}
