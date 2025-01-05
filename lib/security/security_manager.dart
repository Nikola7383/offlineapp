import 'dynamic_keys.dart';
import 'key_distribution.dart';
import 'mutated_defense.dart';

class SecurityManager {
  // Singleton instanca
  static final SecurityManager _instance = SecurityManager._internal();

  // Instance menadžera
  late DynamicKeyManager _keyManager;
  late KeyDistributor _keyDistributor;
  late MutatedDefense _mutatedDefense;

  // Status sistema
  bool _isInitialized = false;
  bool _isActive = false;

  // Factory konstruktor koji vraća istu instancu
  factory SecurityManager() {
    return _instance;
  }

  // Privatni konstruktor
  SecurityManager._internal() {
    _initializeSecurity();
  }

  // Inicijalizacija sigurnosnih komponenti
  void _initializeSecurity() {
    if (!_isInitialized) {
      try {
        _keyManager = DynamicKeyManager();
        _keyDistributor = KeyDistributor();
        _mutatedDefense = MutatedDefense();

        _isInitialized = true;
        _isActive = true;

        print('Security Manager je uspešno inicijalizovan');
      } catch (e) {
        print('Greška pri inicijalizaciji Security Manager-a: $e');
        _isInitialized = false;
        _isActive = false;
      }
    }
  }

  // Detekcija napada
  void detectAttack(
      {required AttackType type,
      required String source,
      required double severity}) {
    if (_isActive) {
      _mutatedDefense.detectAttack(
          type: type, source: source, severity: severity);
    }
  }

  // Dodavanje seed uređaja
  void addSeedDevice(String deviceId) {
    if (_isActive) {
      _keyDistributor.addSeedDevice(deviceId);
    }
  }

  // Uklanjanje seed uređaja
  void removeSeedDevice(String deviceId) {
    if (_isActive) {
      _keyDistributor.removeSeedDevice(deviceId);
    }
  }

  // Provera statusa sistema
  bool isSystemActive() {
    return _isActive;
  }

  // Privremeno deaktiviranje sistema
  void deactivateSystem() {
    if (_isActive) {
      _isActive = false;
      print('Security sistem je privremeno deaktiviran');
    }
  }

  // Reaktiviranje sistema
  void reactivateSystem() {
    if (!_isActive && _isInitialized) {
      _isActive = true;
      print('Security sistem je reaktiviran');
    }
  }

  // Resetovanje sistema
  void resetSystem() {
    dispose();
    _initializeSecurity();
    print('Security sistem je resetovan');
  }

  // Dobijanje trenutnog statusa
  Map<String, dynamic> getSystemStatus() {
    return {
      'initialized': _isInitialized,
      'active': _isActive,
      'attacksDetected': _mutatedDefense.getAttackCount(),
      'currentDefenseMode': _mutatedDefense.getCurrentMode().toString(),
    };
  }

  // Čišćenje resursa
  void dispose() {
    if (_isInitialized) {
      _keyManager.dispose();
      _mutatedDefense.dispose();
      _isActive = false;
      _isInitialized = false;
      print('Security Manager je zaustavljen i očišćen');
    }
  }

  // Metoda za logovanje sigurnosnih događaja
  void logSecurityEvent(String event, {String? details}) {
    if (_isActive) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] Security Event: $event ${details ?? ""}');
      // TODO: Implementirati sigurno čuvanje logova
    }
  }

  // Metoda za proveru integriteta sistema
  Future<bool> checkSystemIntegrity() async {
    if (!_isActive) return false;

    try {
      // Provera komponenti sistema
      final keyManagerOk = await _checkKeyManagerIntegrity();
      final distributorOk = await _checkDistributorIntegrity();
      final defenseOk = await _checkDefenseIntegrity();

      return keyManagerOk && distributorOk && defenseOk;
    } catch (e) {
      logSecurityEvent('Integrity check failed', details: e.toString());
      return false;
    }
  }

  // Pomoćne metode za proveru integriteta
  Future<bool> _checkKeyManagerIntegrity() async {
    // TODO: Implementirati proveru integriteta key managera
    return true;
  }

  Future<bool> _checkDistributorIntegrity() async {
    // TODO: Implementirati proveru integriteta distributora
    return true;
  }

  Future<bool> _checkDefenseIntegrity() async {
    // TODO: Implementirati proveru integriteta odbrane
    return true;
  }
}
