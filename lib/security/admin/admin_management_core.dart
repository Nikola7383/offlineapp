import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AdminManagementCore {
  static final AdminManagementCore _instance = AdminManagementCore._internal();
  final Map<String, AdminDevice> _activeAdmins = {};
  final int _maxAdmins = 10;
  final Duration _adminSessionTimeout = Duration(hours: 12);
  final BiometricCore _biometricCore = BiometricCore();

  factory AdminManagementCore() {
    return _instance;
  }

  AdminManagementCore._internal();

  Future<String?> registerAdmin(
      {required String deviceId,
      required String registrationCode,
      required Map<String, dynamic> adminData}) async {
    if (_activeAdmins.length >= _maxAdmins) {
      throw Exception('Maximum number of admins reached');
    }

    if (!await _validateRegistrationCode(registrationCode)) {
      throw Exception('Invalid registration code');
    }

    // Zahtevamo biometrijsku validaciju za registraciju
    if (!await _biometricCore.validateBiometric(SecurityLevel.maximum)) {
      throw Exception('Biometric validation failed');
    }

    final adminId = await _generateAdminId(deviceId);
    final adminDevice = AdminDevice(
        id: adminId,
        deviceId: deviceId,
        registeredAt: DateTime.now(),
        lastActive: DateTime.now(),
        status: AdminStatus.active,
        securityLevel: AdminSecurityLevel.standard,
        deviceData: await _collectDeviceData(),
        adminData: adminData);

    _activeAdmins[adminId] = adminDevice;
    _startAdminMonitoring(adminDevice);

    await SecurityCore().logSecurityEvent('ADMIN_REGISTRATION', {
      'admin_id': adminId,
      'device_id': deviceId,
      'timestamp': DateTime.now().toIso8601String()
    });

    return adminId;
  }

  Future<Map<String, dynamic>> _collectDeviceData() async {
    // Prikupljanje podataka o uređaju za dodatnu verifikaciju
    return {
      'hardware_id': await _getHardwareId(),
      'device_fingerprint': await _generateDeviceFingerprint(),
      'security_features': await _checkSecurityFeatures()
    };
  }

  Future<void> _startAdminMonitoring(AdminDevice admin) async {
    Timer.periodic(Duration(minutes: 15), (timer) async {
      if (!await _validateAdminDevice(admin)) {
        await deactivateAdmin(admin.id, reason: 'Failed device validation');
        timer.cancel();
      }
    });
  }

  Future<bool> _validateAdminDevice(AdminDevice admin) async {
    // Provera integriteta admin uređaja
    final currentDeviceData = await _collectDeviceData();
    if (!_compareDeviceData(currentDeviceData, admin.deviceData)) {
      return false;
    }

    // Provera vremena neaktivnosti
    if (DateTime.now().difference(admin.lastActive) > _adminSessionTimeout) {
      return false;
    }

    return true;
  }

  Future<void> deactivateAdmin(String adminId, {String? reason}) async {
    final admin = _activeAdmins[adminId];
    if (admin == null) return;

    admin.status = AdminStatus.deactivated;
    _activeAdmins.remove(adminId);

    // Deaktiviranje svih povezanih seed-ova
    await SeedManagementCore().deactivateAdminSeeds(adminId);

    await SecurityCore().logSecurityEvent('ADMIN_DEACTIVATION', {
      'admin_id': adminId,
      'reason': reason ?? 'Manual deactivation',
      'timestamp': DateTime.now().toIso8601String()
    });
  }

  Future<bool> validateAdminOperation(
      String adminId, AdminOperation operation) async {
    final admin = _activeAdmins[adminId];
    if (admin == null) return false;

    // Ažuriranje vremena poslednje aktivnosti
    admin.lastActive = DateTime.now();

    // Provera biometrije za kritične operacije
    if (operation.securityLevel == AdminSecurityLevel.critical) {
      if (!await _biometricCore.validateBiometric(SecurityLevel.high)) {
        return false;
      }
    }

    return true;
  }

  List<AdminDevice> getActiveAdmins() {
    return _activeAdmins.values
        .where((admin) => admin.status == AdminStatus.active)
        .toList();
  }

  Future<String> _generateAdminId(String deviceId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = utf8.encode('$deviceId:$timestamp');
    return sha256.convert(data).toString().substring(0, 16);
  }
}

enum AdminStatus { active, suspended, deactivated }

enum AdminSecurityLevel { standard, elevated, critical }

class AdminDevice {
  final String id;
  final String deviceId;
  final DateTime registeredAt;
  DateTime lastActive;
  AdminStatus status;
  AdminSecurityLevel securityLevel;
  final Map<String, dynamic> deviceData;
  final Map<String, dynamic> adminData;

  AdminDevice(
      {required this.id,
      required this.deviceId,
      required this.registeredAt,
      required this.lastActive,
      required this.status,
      required this.securityLevel,
      required this.deviceData,
      required this.adminData});
}

class AdminOperation {
  final String operationId;
  final AdminSecurityLevel securityLevel;
  final String description;
  final DateTime timestamp;

  AdminOperation(
      {required this.operationId,
      required this.securityLevel,
      required this.description,
      required this.timestamp});
}
