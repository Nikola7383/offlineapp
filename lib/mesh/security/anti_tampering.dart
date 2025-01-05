import 'dart:async';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'security_types.dart';

class AntiTampering {
  static const int INTEGRITY_CHECK_INTERVAL = 5000; // 5 sekundi
  static const int MAX_FAILED_CHECKS = 3;

  final Map<String, Uint8List> _checksums = {};
  final Map<String, int> _failedChecks = {};
  final StreamController<SecurityEvent> _eventController =
      StreamController.broadcast();
  Timer? _integrityCheckTimer;
  bool _isCompromised = false;

  AntiTampering() {
    _startIntegrityChecks();
  }

  /// Registruje novi modul za praćenje
  void registerModule(String moduleId, List<int> initialState) {
    _checksums[moduleId] = _calculateChecksum(initialState);
    _failedChecks[moduleId] = 0;
  }

  /// Verifikuje integritet modula
  bool verifyIntegrity(String moduleId, List<int> currentState) {
    if (_isCompromised) return false;

    final storedChecksum = _checksums[moduleId];
    if (storedChecksum == null) return false;

    final currentChecksum = _calculateChecksum(currentState);
    final isValid = _compareChecksums(storedChecksum, currentChecksum);

    if (!isValid) {
      _handleIntegrityViolation(moduleId);
      return false;
    }

    // Resetuj brojač neuspelih provera
    _failedChecks[moduleId] = 0;
    return true;
  }

  /// Ažurira očekivano stanje modula
  void updateModuleState(String moduleId, List<int> newState) {
    if (_isCompromised) return;
    _checksums[moduleId] = _calculateChecksum(newState);
  }

  /// Računa checksum za dati sadržaj
  Uint8List _calculateChecksum(List<int> data) {
    final hash1 = sha256.convert(data);
    final hash2 = sha512.convert(data);

    // Kombinuj hasheve za dodatnu sigurnost
    return Uint8List.fromList([...hash1.bytes, ...hash2.bytes.take(32)]);
  }

  /// Poredi checksume sa vremenski konstantnom kompleksnošću
  bool _compareChecksums(Uint8List checksum1, Uint8List checksum2) {
    if (checksum1.length != checksum2.length) return false;

    var result = 0;
    for (var i = 0; i < checksum1.length; i++) {
      result |= checksum1[i] ^ checksum2[i];
    }
    return result == 0;
  }

  /// Obrađuje narušavanje integriteta
  void _handleIntegrityViolation(String moduleId) {
    _failedChecks[moduleId] = (_failedChecks[moduleId] ?? 0) + 1;

    if (_failedChecks[moduleId]! >= MAX_FAILED_CHECKS) {
      _isCompromised = true;
      _eventController.add(SecurityEvent.attackDetected);
    }
  }

  /// Pokreće periodične provere integriteta
  void _startIntegrityChecks() {
    _integrityCheckTimer = Timer.periodic(
      Duration(milliseconds: INTEGRITY_CHECK_INTERVAL),
      (_) => _performIntegrityChecks(),
    );
  }

  /// Izvršava provere integriteta za sve module
  void _performIntegrityChecks() {
    if (_isCompromised) return;

    for (var moduleId in _checksums.keys) {
      // Ovde bi trebalo dobaviti trenutno stanje modula
      // U pravoj implementaciji, ovo bi bilo prosleđeno od strane modula
      _eventController.add(SecurityEvent.anomalyDetected);
    }
  }

  /// Stream bezbednosnih događaja
  Stream<SecurityEvent> get securityEvents => _eventController.stream;

  void dispose() {
    _integrityCheckTimer?.cancel();
    _eventController.close();
  }
}
