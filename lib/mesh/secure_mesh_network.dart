import 'dart:async';
import 'dart:typed_data';
import 'models/node.dart';
import 'models/protocol.dart';
import 'mesh_network.dart';
import 'security/security_manager.dart';
import 'security/anti_tampering.dart';
import 'security/security_types.dart';

class SecureMeshNetwork {
  final MeshNetwork _network;
  final SecurityManager _security;
  final AntiTampering _antiTampering;

  final StreamController<List<int>> _secureDataController =
      StreamController.broadcast();
  final Map<String, DateTime> _lastMessageTime = {};

  static const Duration MESSAGE_RATE_LIMIT = Duration(milliseconds: 100);
  static const int MAX_MESSAGE_SIZE = 1024 * 1024; // 1MB

  bool _isCompromised = false;

  SecureMeshNetwork({
    MeshNetwork? network,
    SecurityManager? security,
    AntiTampering? antiTampering,
  })  : _network = network ?? MeshNetwork(),
        _security = security ?? SecurityManager(),
        _antiTampering = antiTampering ?? AntiTampering() {
    _initializeSecurityListeners();
  }

  Future<void> start() async {
    // Registruj mrežu za anti-tampering
    _antiTampering.registerModule('network',
        _network.nodes.map((n) => n.id.codeUnits).expand((x) => x).toList());

    // Pokreni mrežu
    await _network.start();

    // Slušaj dolazne poruke
    _network.dataStream.listen(_handleIncomingData);
  }

  Future<void> broadcast(List<int> data) async {
    if (_isCompromised) throw SecurityException('Network is compromised');

    _enforceRateLimit('broadcast');
    _validateMessageSize(data);

    // Enkriptuj podatke
    final encrypted = await _security.encrypt(data);

    // Dodaj anti-tampering proveru
    final withIntegrity = _addIntegrityCheck(encrypted);

    // Pošalji preko mreže
    await _network.broadcast(withIntegrity);
  }

  Future<bool> sendTo(String nodeId, List<int> data) async {
    if (_isCompromised) throw SecurityException('Network is compromised');

    _enforceRateLimit(nodeId);
    _validateMessageSize(data);

    // Enkriptuj podatke specifično za ovaj čvor
    final encrypted = await _security.encrypt(
      data,
      level: _getEncryptionLevelForNode(nodeId),
    );

    // Dodaj anti-tampering proveru
    final withIntegrity = _addIntegrityCheck(encrypted);

    return _network.sendTo(nodeId, withIntegrity);
  }

  void _initializeSecurityListeners() {
    // Prati bezbednosne događaje
    _security.securityEvents.listen(_handleSecurityEvent);
    _antiTampering.securityEvents.listen(_handleSecurityEvent);

    // Prati promene u mreži
    _network.nodesStream.listen((nodes) {
      _antiTampering.updateModuleState('network',
          nodes.map((n) => n.id.codeUnits).expand((x) => x).toList());
    });
  }

  Future<void> _handleIncomingData(List<int> data) async {
    try {
      // Proveri integritet
      final verified = _verifyIntegrityCheck(data);
      if (!verified) {
        _handleSecurityEvent(SecurityEvent.attackDetected);
        return;
      }

      // Dekriptuj podatke
      final message = EncryptedMessage.fromJson(_bytesToJson(verified));

      final decrypted = await _security.decrypt(message);

      // Emituj dekriptovane podatke
      _secureDataController.add(decrypted.toList());
    } catch (e) {
      _handleSecurityEvent(SecurityEvent.anomalyDetected);
    }
  }

  void _handleSecurityEvent(SecurityEvent event) {
    switch (event) {
      case SecurityEvent.attackDetected:
      case SecurityEvent.protocolCompromised:
        _isCompromised = true;
        _initiateEmergencyProtocol();
        break;

      case SecurityEvent.phoenixRegeneration:
        _isCompromised = false;
        _restartNetwork();
        break;

      default:
        // Logiraj događaj
        print('Security event: $event');
    }
  }

  void _enforceRateLimit(String target) {
    final now = DateTime.now();
    final lastTime = _lastMessageTime[target];

    if (lastTime != null && now.difference(lastTime) < MESSAGE_RATE_LIMIT) {
      throw SecurityException('Rate limit exceeded');
    }

    _lastMessageTime[target] = now;
  }

  void _validateMessageSize(List<int> data) {
    if (data.length > MAX_MESSAGE_SIZE) {
      throw SecurityException('Message too large');
    }
  }

  EncryptionLevel _getEncryptionLevelForNode(String nodeId) {
    // Implementiraj logiku za određivanje nivoa enkripcije
    // baziranu na istoriji čvora, njegovom ponašanju, itd.
    return _isCompromised ? EncryptionLevel.phoenix : EncryptionLevel.advanced;
  }

  List<int> _addIntegrityCheck(EncryptedMessage message) {
    final json = message.toJson();
    final checksum = _calculateChecksum(json.toString());
    return [...checksum, ..._jsonToBytes(json)];
  }

  List<int>? _verifyIntegrityCheck(List<int> data) {
    if (data.length < 64) return null; // Minimum size for checksum

    final checksum = data.take(64).toList();
    final payload = data.skip(64).toList();

    final calculatedChecksum =
        _calculateChecksum(_bytesToJson(payload).toString());

    if (!_compareChecksums(checksum, calculatedChecksum)) {
      return null;
    }

    return payload;
  }

  void _initiateEmergencyProtocol() {
    // 1. Zaustavi sve aktivne komunikacije
    // 2. Obriši osetljive podatke
    // 3. Pripremi se za Phoenix regeneraciju
    _network.stop();
  }

  Future<void> _restartNetwork() async {
    // 1. Generiši nove ključeve
    // 2. Uspostavi nove konekcije
    // 3. Resetuj stanje
    await _network.start();
  }

  // Helper metode
  List<int> _calculateChecksum(String data) {
    // Implementiraj kompleksnu hash funkciju
    return List<int>.filled(64, 0); // Placeholder
  }

  bool _compareChecksums(List<int> c1, List<int> c2) {
    if (c1.length != c2.length) return false;
    var result = 0;
    for (var i = 0; i < c1.length; i++) {
      result |= c1[i] ^ c2[i];
    }
    return result == 0;
  }

  Map<String, dynamic> _bytesToJson(List<int> bytes) {
    // Implementiraj konverziju
    return {}; // Placeholder
  }

  List<int> _jsonToBytes(Map<String, dynamic> json) {
    // Implementiraj konverziju
    return []; // Placeholder
  }

  Stream<List<int>> get secureDataStream => _secureDataController.stream;
  Set<Node> get nodes => _network.nodes;
  bool get isCompromised => _isCompromised;

  Future<void> dispose() async {
    await _network.dispose();
    _security.dispose();
    _antiTampering.dispose();
    await _secureDataController.close();
  }
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
