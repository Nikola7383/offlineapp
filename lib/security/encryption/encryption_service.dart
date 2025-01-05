import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  late final Key _key;
  late final IV _iv;
  late final Encrypter _encrypter;

  factory EncryptionService() {
    return _instance;
  }

  EncryptionService._internal() {
    _initializeEncryption();
  }

  void _initializeEncryption() {
    // Generišemo sigurni ključ
    final keyBytes = SecureRandom(32).nextBytes();
    _key = Key(keyBytes);
    _iv = IV.fromSecureRandom(16);
    _encrypter = Encrypter(AES(_key));

    print('Encryption Service Initialized');
  }

  String encrypt(String data) {
    try {
      final encrypted = _encrypter.encrypt(data, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      print('Encryption error: $e');
      return '';
    }
  }

  String decrypt(String encryptedData) {
    try {
      final encrypted = Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      print('Decryption error: $e');
      return '';
    }
  }

  String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
