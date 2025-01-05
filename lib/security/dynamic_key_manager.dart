import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'secure_logger.dart';

class DynamicKeyManager {
  static final DynamicKeyManager _instance = DynamicKeyManager._internal();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SecureLogger _logger = SecureLogger();
  final Uuid _uuid = Uuid();

  // Tajmeri za rotaciju ključeva
  late Timer _primaryKeyTimer;
  late Timer _backupKeyTimer;

  // Trenutni ključevi
  String? _currentPrimaryKey;
  String? _currentBackupKey;

  // Vreme poslednje rotacije
  DateTime? _lastPrimaryRotation;
  DateTime? _lastBackupRotation;

  // Konstante
  static const String _primaryKeyId = 'primary_key';
  static const String _backupKeyId = 'backup_key';
  static const int _primaryKeyRotationMinutes = 15;
  static const int _backupKeyRotationHours = 1;

  // Singleton pattern
  factory DynamicKeyManager() {
    return _instance;
  }

  DynamicKeyManager._internal() {
    _initializeKeys();
  }

  Future<void> _initializeKeys() async {
    try {
      // Učitavanje postojećih ključeva
      _currentPrimaryKey = await _secureStorage.read(key: _primaryKeyId);
      _currentBackupKey = await _secureStorage.read(key: _backupKeyId);

      // Generisanje novih ključeva ako ne postoje
      if (_currentPrimaryKey == null) {
        await _generateAndStorePrimaryKey();
      }
      if (_currentBackupKey == null) {
        await _generateAndStoreBackupKey();
      }

      // Pokretanje tajmera za rotaciju
      _startKeyRotation();

      await _logger.log('Dynamic Key Manager inicijalizovan', LogLevel.info,
          source: 'DynamicKeyManager');
    } catch (e) {
      await _logger.log(
          'Greška pri inicijalizaciji ključeva: $e', LogLevel.error,
          source: 'DynamicKeyManager');
    }
  }

  Future<void> _generateAndStorePrimaryKey() async {
    _currentPrimaryKey = _generateSecureKey();
    await _secureStorage.write(key: _primaryKeyId, value: _currentPrimaryKey);
    _lastPrimaryRotation = DateTime.now();
  }

  Future<void> _generateAndStoreBackupKey() async {
    _currentBackupKey = _generateSecureKey();
    await _secureStorage.write(key: _backupKeyId, value: _currentBackupKey);
    _lastBackupRotation = DateTime.now();
  }

  String _generateSecureKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    final hash = sha256.convert(values);
    return base64Url.encode(hash.bytes) + _uuid.v4();
  }

  void _startKeyRotation() {
    // Rotacija primarnog ključa svakih 15 minuta
    _primaryKeyTimer = Timer.periodic(
        Duration(minutes: _primaryKeyRotationMinutes),
        (_) => _rotatePrimaryKey());

    // Rotacija backup ključa svakih sat vremena
    _backupKeyTimer = Timer.periodic(
        Duration(hours: _backupKeyRotationHours), (_) => _rotateBackupKey());
  }

  Future<void> _rotatePrimaryKey() async {
    try {
      final oldKey = _currentPrimaryKey;
      await _generateAndStorePrimaryKey();
      await _logger.log('Primarni ključ rotiran', LogLevel.info,
          source: 'DynamicKeyManager');
      await _notifyKeyRotation(true, oldKey);
    } catch (e) {
      await _logger.log(
          'Greška pri rotaciji primarnog ključa: $e', LogLevel.error,
          source: 'DynamicKeyManager');
    }
  }

  Future<void> _rotateBackupKey() async {
    try {
      final oldKey = _currentBackupKey;
      await _generateAndStoreBackupKey();
      await _logger.log('Backup ključ rotiran', LogLevel.info,
          source: 'DynamicKeyManager');
      await _notifyKeyRotation(false, oldKey);
    } catch (e) {
      await _logger.log('Greška pri rotaciji backup ključa: $e', LogLevel.error,
          source: 'DynamicKeyManager');
    }
  }

  Future<void> _notifyKeyRotation(bool isPrimary, String? oldKey) async {
    // TODO: Implementirati notifikaciju seed uređajima o promeni ključa
  }

  // Javne metode za pristup ključevima
  Future<String?> getCurrentPrimaryKey() async {
    return _currentPrimaryKey;
  }

  Future<String?> getCurrentBackupKey() async {
    return _currentBackupKey;
  }

  // Provera validnosti ključa
  Future<bool> isKeyValid(String key) async {
    return key == _currentPrimaryKey || key == _currentBackupKey;
  }

  // Forsiraj rotaciju ključeva (za hitne slučajeve)
  Future<void> forceKeyRotation() async {
    await _rotatePrimaryKey();
    await _rotateBackupKey();
  }

  // Čišćenje resursa
  void dispose() {
    _primaryKeyTimer.cancel();
    _backupKeyTimer.cancel();
  }

  // Dobijanje informacija o ključevima
  Map<String, dynamic> getKeyInfo() {
    return {
      'primaryKeyLastRotation': _lastPrimaryRotation?.toIso8601String(),
      'backupKeyLastRotation': _lastBackupRotation?.toIso8601String(),
      'primaryKeyNextRotation': _lastPrimaryRotation
          ?.add(Duration(minutes: _primaryKeyRotationMinutes))
          .toIso8601String(),
      'backupKeyNextRotation': _lastBackupRotation
          ?.add(Duration(hours: _backupKeyRotationHours))
          .toIso8601String(),
    };
  }
}
