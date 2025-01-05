import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:typed_data';

class KeyManager {
  static final KeyManager _instance = KeyManager._internal();
  final Map<String, String> _keyStore = {};
  final Map<String, String> _backupKeyStore = {};
  final Map<String, DateTime> _keyCreationTime = {};
  final Duration _keyRotationPeriod = Duration(hours: 24);

  // Istorija ključeva za recovery
  final Map<String, List<String>> _keyHistory = {};

  factory KeyManager() {
    return _instance;
  }

  KeyManager._internal() {
    // Pokrenite periodičnu proveru za rotaciju ključeva
    _startKeyRotationCheck();
  }

  void _startKeyRotationCheck() {
    Future.delayed(Duration(minutes: 30), () {
      _checkAndRotateKeys();
      _startKeyRotationCheck(); // Rekurzivno zakazivanje
    });
  }

  void _checkAndRotateKeys() {
    final now = DateTime.now();
    _keyCreationTime.forEach((purpose, creationTime) {
      if (now.difference(creationTime) > _keyRotationPeriod) {
        rotateKey(purpose);
      }
    });
  }

  String generateKey(String purpose) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomData = DateTime.now().toString() + purpose;
    final key = _hashData(randomData + timestamp);

    // Backup starog ključa pre zamene
    if (_keyStore.containsKey(purpose)) {
      _backupKey(purpose, _keyStore[purpose]!);
    }

    _keyStore[purpose] = key;
    _keyCreationTime[purpose] = DateTime.now();

    // Dodaj u istoriju
    _keyHistory.putIfAbsent(purpose, () => []).add(key);

    return key;
  }

  void _backupKey(String purpose, String key) {
    _backupKeyStore[purpose] = key;
    // Ograničite istoriju na poslednjih 5 ključeva
    if (_keyHistory[purpose]?.length ?? 0 > 5) {
      _keyHistory[purpose]?.removeAt(0);
    }
  }

  void rotateKey(String purpose) {
    if (_keyStore.containsKey(purpose)) {
      final newKey = generateKey(purpose);
      print('Ključ rotiran za: $purpose');
    }
  }

  // Recovery funkcije
  String? recoverKey(String purpose) {
    return _backupKeyStore[purpose];
  }

  List<String> getKeyHistory(String purpose) {
    return _keyHistory[purpose] ?? [];
  }

  bool isKeyExpired(String purpose) {
    final creationTime = _keyCreationTime[purpose];
    if (creationTime == null) return true;

    return DateTime.now().difference(creationTime) > _keyRotationPeriod;
  }

  // Postojeće metode...
  String? getKey(String purpose) {
    if (isKeyExpired(purpose)) {
      rotateKey(purpose);
    }
    return _keyStore[purpose];
  }

  void revokeKey(String purpose) {
    _keyStore.remove(purpose);
    _keyCreationTime.remove(purpose);
    // Čuvamo backup za mogući recovery
    _backupKeyStore.remove(purpose);
  }

  String _hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool validateKey(String purpose, String key) {
    // Provera aktivnog ključa
    if (_keyStore[purpose] == key) return true;
    // Provera backup ključa
    if (_backupKeyStore[purpose] == key) return true;
    // Provera istorije ključeva
    return _keyHistory[purpose]?.contains(key) ?? false;
  }
}
