import 'dart:async';
import 'package:injectable/injectable.dart';
import '../core/interfaces/logger_service_interface.dart';
import '../core/interfaces/encryption_interface.dart';
import '../models/encryption_types.dart';

@singleton
class EncryptionManager implements IEncryptionManager {
  final ILoggerService _logger;
  final _encryptionEventsController =
      StreamController<EncryptionEvent>.broadcast();
  final _keyStatusController = StreamController<KeyStatus>.broadcast();

  bool _isInitialized = false;
  final Map<String, KeyPair> _keyPairs = {};
  final Map<String, KeyStatus> _keyStatuses = {};
  EncryptionConfig? _config;

  EncryptionManager(this._logger);

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      await _logger.warning('EncryptionManager je već inicijalizovan');
      return;
    }

    await _logger.info('Inicijalizacija EncryptionManager-a');
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) {
      await _logger.warning('EncryptionManager nije inicijalizovan');
      return;
    }

    await _logger.info('Gašenje EncryptionManager-a');
    await _encryptionEventsController.close();
    await _keyStatusController.close();
    _isInitialized = false;
  }

  @override
  Future<EncryptedData> encrypt(List<int> data, EncryptionConfig config) async {
    if (!_isInitialized) {
      throw StateError('EncryptionManager nije inicijalizovan');
    }

    await _logger.info('Enkripcija podataka');

    // Simuliramo enkripciju podataka
    final encryptedData = EncryptedData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: List.from(data.reversed), // Simulirana enkripcija
      algorithm: config.type.toString(),
      timestamp: DateTime.now(),
      keyId: _getActiveKeyId(),
      iv: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    _emitEncryptionEvent(
      description: 'Podaci uspešno enkriptovani',
      severity: config.level,
      relatedKeyId: encryptedData.keyId,
    );

    return encryptedData;
  }

  @override
  Future<List<int>> decrypt(EncryptedData data) async {
    if (!_isInitialized) {
      throw StateError('EncryptionManager nije inicijalizovan');
    }

    await _logger.info('Dekripcija podataka');

    // Proveravamo da li ključ postoji i da li je aktivan
    if (!_isKeyValid(data.keyId)) {
      throw SecurityException('Ključ nije validan ili je istekao');
    }

    // Simuliramo dekripciju
    final decryptedData = List.from(data.data.reversed);

    _emitEncryptionEvent(
      description: 'Podaci uspešno dekriptovani',
      severity: EncryptionLevel.medium,
      relatedKeyId: data.keyId,
    );

    return List<int>.from(decryptedData);
  }

  @override
  Future<KeyPair> generateKeyPair([DateTime? expiresAt]) async {
    if (!_isInitialized) {
      throw StateError('EncryptionManager nije inicijalizovan');
    }

    await _logger.info('Generisanje para ključeva');

    // Simuliramo generisanje para ključeva
    final keyId = DateTime.now().millisecondsSinceEpoch.toString();
    final keyPair = KeyPair(
      id: keyId,
      publicKey: 'public_$keyId',
      privateKey: 'private_$keyId',
      createdAt: DateTime.now(),
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 30)),
      state: KeyState.active,
    );

    _keyPairs[keyId] = keyPair;

    _emitEncryptionEvent(
      description: 'Generisan novi par ključeva',
      severity: EncryptionLevel.high,
      relatedKeyId: keyId,
    );

    return keyPair;
  }

  @override
  Future<void> rotateKeys() async {
    if (!_isInitialized) {
      throw StateError('EncryptionManager nije inicijalizovan');
    }

    await _logger.info('Rotacija ključeva');

    // Deaktiviramo stare ključeve
    for (final keyId in _keyPairs.keys) {
      _updateKeyStatus(keyId, KeyState.inactive);
    }

    // Generišemo novi par ključeva
    await generateKeyPair();

    _emitEncryptionEvent(
      description: 'Ključevi uspešno rotirani',
      severity: EncryptionLevel.high,
    );
  }

  @override
  Future<bool> verifyIntegrity(EncryptedData data) async {
    if (!_isInitialized) {
      throw StateError('EncryptionManager nije inicijalizovan');
    }

    await _logger.info('Verifikacija integriteta podataka');

    // Simuliramo proveru integriteta
    final isValid = data.keyId.isNotEmpty && _isKeyValid(data.keyId);

    if (!isValid) {
      _emitEncryptionEvent(
        description: 'Neuspešna verifikacija integriteta',
        severity: EncryptionLevel.high,
        relatedKeyId: data.keyId,
      );
    }

    return isValid;
  }

  @override
  Future<void> manageKeys(KeyOperation operation) async {
    if (!_isInitialized) {
      throw StateError('EncryptionManager nije inicijalizovan');
    }

    await _logger.info('Upravljanje ključevima: ${operation.type}');

    switch (operation.type) {
      case KeyOperationType.revoke:
        _updateKeyStatus(operation.keyId, KeyState.revoked);
        break;
      case KeyOperationType.backup:
        // Simuliramo backup ključa
        break;
      case KeyOperationType.restore:
        if (_keyPairs.containsKey(operation.keyId)) {
          _updateKeyStatus(operation.keyId, KeyState.active);
        }
        break;
      default:
        throw ArgumentError('Nepodržana operacija: ${operation.type}');
    }

    _emitEncryptionEvent(
      description: 'Izvršena operacija nad ključem: ${operation.type}',
      severity: EncryptionLevel.high,
      relatedKeyId: operation.keyId,
    );
  }

  @override
  Future<EncryptionReport> generateReport() async {
    if (!_isInitialized) {
      throw StateError('EncryptionManager nije inicijalizovan');
    }

    await _logger.info('Generisanje izveštaja o enkripciji');

    final warnings = <String>[];
    final recommendations = <String>[];

    // Proveravamo stare ključeve
    for (final status in _keyStatuses.values) {
      if (status.state == KeyState.expired) {
        warnings.add('Ključ ${status.keyId} je istekao');
        recommendations.add('Rotirajte ključ ${status.keyId}');
      }
      if (status.state == KeyState.compromised) {
        warnings.add('Ključ ${status.keyId} je kompromitovan');
        recommendations.add('Hitno zamenite ključ ${status.keyId}');
      }
    }

    return EncryptionReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      generatedAt: DateTime.now(),
      totalOperations:
          _keyStatuses.values.fold(0, (sum, status) => sum + status.usageCount),
      activeKeys:
          _keyStatuses.values.where((s) => s.state == KeyState.active).length,
      operationStats: _generateOperationStats(),
      warnings: warnings,
      recommendations: recommendations,
    );
  }

  Map<String, int> _generateOperationStats() {
    return {
      'active_keys':
          _keyStatuses.values.where((s) => s.state == KeyState.active).length,
      'revoked_keys':
          _keyStatuses.values.where((s) => s.state == KeyState.revoked).length,
      'expired_keys':
          _keyStatuses.values.where((s) => s.state == KeyState.expired).length,
      'compromised_keys': _keyStatuses.values
          .where((s) => s.state == KeyState.compromised)
          .length,
    };
  }

  @override
  Future<void> configure(EncryptionConfig config) async {
    if (!_isInitialized) {
      throw StateError('EncryptionManager nije inicijalizovan');
    }

    await _logger.info('Konfiguracija enkripcije');
    _config = config;

    _emitEncryptionEvent(
      description: 'Ažurirana konfiguracija enkripcije',
      severity: EncryptionLevel.medium,
    );
  }

  @override
  Future<EncryptionStatus> checkStatus() async {
    if (!_isInitialized) {
      throw StateError('EncryptionManager nije inicijalizovan');
    }

    await _logger.info('Provera statusa enkripcije');

    final warnings = <String>[];

    // Proveravamo status ključeva
    for (final status in _keyStatuses.values) {
      if (status.isCompromised) {
        warnings.add('Kompromitovan ključ: ${status.keyId}');
      }
    }

    return EncryptionStatus(
      isInitialized: _isInitialized,
      currentType: _config?.type ?? EncryptionType.none,
      currentLevel: _config?.level ?? EncryptionLevel.none,
      activeKeys:
          _keyStatuses.values.where((s) => s.state == KeyState.active).length,
      lastKeyRotation: _getLastKeyRotation(),
      warnings: warnings.isEmpty ? null : warnings,
    );
  }

  DateTime _getLastKeyRotation() {
    if (_keyPairs.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return _keyPairs.values
        .map((k) => k.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  String _getActiveKeyId() {
    final activeKey = _keyPairs.values.firstWhere(
      (key) =>
          key.state == KeyState.active && key.expiresAt.isAfter(DateTime.now()),
      orElse: () => throw SecurityException('Nema aktivnih ključeva'),
    );
    return activeKey.id;
  }

  bool _isKeyValid(String keyId) {
    final key = _keyPairs[keyId];
    if (key == null) return false;

    // Dozvoljavamo dekripciju sa neaktivnim ključevima, ali ne i sa opozvanim
    if (key.state == KeyState.revoked) return false;

    return key.expiresAt.isAfter(DateTime.now());
  }

  void _updateKeyStatus(String keyId, KeyState newState) {
    final key = _keyPairs[keyId];
    if (key == null) return;

    final status = KeyStatus(
      keyId: keyId,
      state: newState,
      lastUsed: DateTime.now(),
      usageCount: (_keyStatuses[keyId]?.usageCount ?? 0) + 1,
      isCompromised: newState == KeyState.compromised,
    );

    _keyStatuses[keyId] = status;
    _keyStatusController.add(status);
  }

  void _emitEncryptionEvent({
    required String description,
    required EncryptionLevel severity,
    String? relatedKeyId,
    Map<String, dynamic>? metadata,
  }) {
    final event = EncryptionEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
      timestamp: DateTime.now(),
      severity: severity,
      relatedKeyId: relatedKeyId,
      metadata: metadata,
    );
    _encryptionEventsController.add(event);
  }

  @override
  Stream<EncryptionEvent> get encryptionEvents =>
      _encryptionEventsController.stream;

  @override
  Stream<KeyStatus> get keyStatus => _keyStatusController.stream;
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => message;
}
