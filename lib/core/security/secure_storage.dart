import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorage {
  final FlutterSecureStorage _storage;
  final LoggerService _logger;

  SecureStorage({required LoggerService logger})
      : _storage = const FlutterSecureStorage(),
        _logger = logger;

  Future<void> write({
    required String key,
    required String value,
  }) async {
    try {
      await _storage.write(
        key: key,
        value: value,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } catch (e) {
      _logger.error('Greška pri upisu u secure storage: $e');
      rethrow;
    }
  }

  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(
        key: key,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } catch (e) {
      _logger.error('Greška pri čitanju iz secure storage: $e');
      return null;
    }
  }

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  IOSOptions _getIOSOptions() => const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      );
}
