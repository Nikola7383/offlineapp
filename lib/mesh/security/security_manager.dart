import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'security_types.dart';
import '../models/node.dart';

class SecurityManager {
  static const int KEY_SIZE = 32; // 256 bits
  static const int MAX_ANOMALY_THRESHOLD = 0.8;
  static const Duration KEY_ROTATION_INTERVAL = Duration(hours: 12);

  final Map<String, SecurityKey> _keys = {};
  final List<SecurityAnomaly> _anomalies = [];
  final Random _random = Random.secure();
  final StreamController<SecurityEvent> _eventController =
      StreamController.broadcast();

  EncryptionLevel _currentLevel = EncryptionLevel.basic;
  Timer? _keyRotationTimer;
  bool _isCompromised = false;

  SecurityManager() {
    _initializeKeys();
    _startKeyRotation();
  }

  /// Inicijalizuje početne ključeve
  Future<void> _initializeKeys() async {
    // Generišemo ključeve za sve nivoe
    for (var level in EncryptionLevel.values) {
      await _generateNewKey(level);
    }
  }

  /// Generiše novi ključ
  Future<SecurityKey> _generateNewKey(EncryptionLevel level) async {
    final key = SecurityKey(
      key: _generateRandomBytes(KEY_SIZE),
      level: level,
      keyId: _generateKeyId(),
    );
    _keys[key.keyId] = key;
    return key;
  }

  /// Enkriptuje podatke
  Future<EncryptedMessage> encrypt(List<int> data,
      {EncryptionLevel? level}) async {
    level ??= _currentLevel;

    // Ako je sistem kompromitovan, automatski prebaci na Phoenix nivo
    if (_isCompromised) {
      level = EncryptionLevel.phoenix;
    }

    final key = await _getActiveKey(level);
    if (key == null) throw Exception('No valid key available');

    final encrypted = await _encryptWithLevel(Uint8List.fromList(data), key);
    final signature = await _sign(encrypted, key);

    return EncryptedMessage(
      data: encrypted,
      keyId: key.keyId,
      level: level,
      signature: signature,
      metadata: {'iteration': _getPhoenixIteration()},
    );
  }

  /// Dekriptuje podatke
  Future<Uint8List> decrypt(EncryptedMessage message) async {
    final key = _keys[message.keyId];
    if (key == null) throw Exception('Key not found');
    if (!key.isValid) throw Exception('Key is not valid');

    // Verifikuj potpis
    final isValid = await _verify(message.data, message.signature, key);
    if (!isValid) {
      _reportAnomaly(SecurityEvent.attackDetected, 'Invalid signature');
      throw Exception('Invalid signature');
    }

    return _decryptWithLevel(message.data, key);
  }

  /// Enkriptuje podatke sa određenim nivoom zaštite
  Future<Uint8List> _encryptWithLevel(Uint8List data, SecurityKey key) async {
    switch (key.level) {
      case EncryptionLevel.basic:
        return _encryptAES(data, key.key);

      case EncryptionLevel.advanced:
        // Post-quantum enkripcija
        return _encryptPostQuantum(data, key.key);

      case EncryptionLevel.phoenix:
        // Višestruka enkripcija sa dinamičkim parametrima
        return _encryptPhoenix(data, key.key);
    }
  }

  /// AES-256 enkripcija
  Future<Uint8List> _encryptAES(Uint8List data, Uint8List key) async {
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(key);
    final nonce = _generateRandomBytes(12);

    final encrypted = await algorithm.encrypt(
      data,
      secretKey: secretKey,
      nonce: nonce,
    );

    return Uint8List.fromList([...nonce, ...encrypted.cipherText]);
  }

  /// Post-quantum enkripcija
  Future<Uint8List> _encryptPostQuantum(Uint8List data, Uint8List key) async {
    // TODO: Implementirati post-quantum algoritam
    // Za sada koristimo pojačani AES
    final firstPass = await _encryptAES(data, key);
    final secondKey = _deriveKey(key, 'secondary');
    return _encryptAES(firstPass, secondKey);
  }

  /// Phoenix enkripcija - dinamička višeslojna zaštita
  Future<Uint8List> _encryptPhoenix(Uint8List data, Uint8List key) async {
    final iteration = _getPhoenixIteration();
    var encrypted = data;

    // Broj slojeva enkripcije zavisi od trenutne iteracije
    for (var i = 0; i < iteration % 5 + 2; i++) {
      final derivedKey = _deriveKey(key, 'phoenix_$i');
      encrypted = await _encryptAES(encrypted, derivedKey);
    }

    return encrypted;
  }

  /// Prijavljuje bezbednosnu anomaliju
  void _reportAnomaly(SecurityEvent event, String details) {
    final anomaly = SecurityAnomaly(
      sourceId: 'system',
      eventType: event,
      details: {'description': details},
      severityScore: _calculateSeverity(event),
    );

    _anomalies.add(anomaly);
    _eventController.add(event);

    // Proveri da li treba aktivirati Phoenix protokol
    if (_shouldActivatePhoenix()) {
      _activatePhoenixProtocol();
    }
  }

  /// Aktivira Phoenix protokol
  void _activatePhoenixProtocol() {
    _isCompromised = true;
    _currentLevel = EncryptionLevel.phoenix;

    // Generiši nove ključeve
    _initializeKeys();

    // Obavesti sistem
    _eventController.add(SecurityEvent.phoenixRegeneration);
  }

  /// Pomoćne metode
  Uint8List _generateRandomBytes(int length) {
    return Uint8List.fromList(
        List<int>.generate(length, (i) => _random.nextInt(256)));
  }

  String _generateKeyId() {
    return base64Url.encode(_generateRandomBytes(16));
  }

  Uint8List _deriveKey(Uint8List baseKey, String purpose) {
    final hmac = Hmac(Sha256());
    return Uint8List.fromList(
        hmac.convert([...baseKey, ...purpose.codeUnits]).bytes);
  }

  int _getPhoenixIteration() {
    return DateTime.now().millisecondsSinceEpoch ~/
        1000 ~/
        300; // Menja se svakih 5 minuta
  }

  double _calculateSeverity(SecurityEvent event) {
    switch (event) {
      case SecurityEvent.attackDetected:
        return 0.8;
      case SecurityEvent.protocolCompromised:
        return 0.9;
      case SecurityEvent.keyCompromised:
        return 1.0;
      case SecurityEvent.anomalyDetected:
        return 0.6;
      case SecurityEvent.phoenixRegeneration:
        return 0.5;
    }
  }

  bool _shouldActivatePhoenix() {
    if (_anomalies.isEmpty) return false;

    // Izračunaj prosečnu težinu anomalija u poslednjih sat vremena
    final recentAnomalies = _anomalies.where((a) =>
        a.timestamp.isAfter(DateTime.now().subtract(Duration(hours: 1))));

    if (recentAnomalies.isEmpty) return false;

    final avgSeverity =
        recentAnomalies.map((a) => a.severityScore).reduce((a, b) => a + b) /
            recentAnomalies.length;

    return avgSeverity > MAX_ANOMALY_THRESHOLD;
  }

  void _startKeyRotation() {
    _keyRotationTimer = Timer.periodic(KEY_ROTATION_INTERVAL, (_) {
      _initializeKeys();
    });
  }

  /// Stream bezbednosnih događaja
  Stream<SecurityEvent> get securityEvents => _eventController.stream;

  void dispose() {
    _keyRotationTimer?.cancel();
    _eventController.close();
  }
}
