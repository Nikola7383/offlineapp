import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ProximityValidator {
  static final ProximityValidator _instance = ProximityValidator._internal();
  final Map<String, DateTime> _lastValidatedDevices = {};
  final double _requiredProximity = 2.0; // metri

  factory ProximityValidator() {
    return _instance;
  }

  ProximityValidator._internal();

  Future<bool> validateProximity(String deviceId) async {
    try {
      // Provera da li je Master Admin u blizini
      final isNearby = await _checkDeviceProximity(deviceId);
      if (isNearby) {
        _lastValidatedDevices[deviceId] = DateTime.now();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkDeviceProximity(String deviceId) async {
    // Implementacija BLE provere blizine
    return true; // Placeholder
  }

  bool canOperateOffline(String deviceId) {
    final lastValidation = _lastValidatedDevices[deviceId];
    if (lastValidation == null) return false;

    // Provera da li je prošlo manje od 24h od poslednje validacije
    final timeSinceValidation = DateTime.now().difference(lastValidation);
    return timeSinceValidation.inHours < 24;
  }
}
