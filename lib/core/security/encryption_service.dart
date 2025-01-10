import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../interfaces/base_service.dart';

class EncryptionService extends BaseService {
  final _uuid = const Uuid();
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    // Inicijalizacija enkripcijskih ključeva i drugih resursa
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) return;
    // Čišćenje resursa
    _isInitialized = false;
  }

  String generateUuid() {
    return _uuid.v4();
  }

  Future<String> generateSecureDeviceId() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = _uuid.v4();
    final combined = '$timestamp:$random';
    return sha256.convert(utf8.encode(combined)).toString();
  }

  Future<String> encrypt(String data, String key) async {
    // TODO: Implementirati AES enkripciju
    return data;
  }

  Future<String> decrypt(String encryptedData, String key) async {
    // TODO: Implementirati AES dekripciju
    return encryptedData;
  }

  Future<String> hash(String data) async {
    return sha256.convert(utf8.encode(data)).toString();
  }

  Future<bool> verify(String data, String hash) async {
    final computedHash = await this.hash(data);
    return computedHash == hash;
  }
}

// Provider
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});
