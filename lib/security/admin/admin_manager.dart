class AdminManager {
  static final AdminManager _instance = AdminManager._internal();
  final int _maxAdminDevices = 10;
  final Map<String, AdminDevice> _registeredAdmins = {};

  factory AdminManager() {
    return _instance;
  }

  AdminManager._internal();

  bool canRegisterNewAdmin() {
    return _registeredAdmins.length < _maxAdminDevices;
  }

  Future<bool> registerAdminDevice(String deviceId, String adminCode) async {
    if (!canRegisterNewAdmin()) return false;

    final device = AdminDevice(
        deviceId: deviceId,
        registeredAt: DateTime.now(),
        lastActive: DateTime.now());

    _registeredAdmins[deviceId] = device;
    return true;
  }

  void deactivateAdmin(String deviceId) {
    _registeredAdmins.remove(deviceId);
  }

  List<AdminDevice> getActiveAdmins() {
    return _registeredAdmins.values.toList();
  }
}

class AdminDevice {
  final String deviceId;
  final DateTime registeredAt;
  DateTime lastActive;

  AdminDevice(
      {required this.deviceId,
      required this.registeredAt,
      required this.lastActive});
}
