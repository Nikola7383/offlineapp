class AccessControl {
  static final AccessControl _instance = AccessControl._internal();
  DeviceLevel? _currentDeviceLevel;

  factory AccessControl() {
    return _instance;
  }

  AccessControl._internal();

  Future<bool> initializeDevice(String deviceCode) async {
    try {
      // Validacija device koda i određivanje nivoa
      _currentDeviceLevel = await _validateDeviceCode(deviceCode);
      return _currentDeviceLevel != null;
    } catch (e) {
      return false;
    }
  }

  Future<DeviceLevel?> _validateDeviceCode(String code) async {
    // Kompleksna validacija koda za određivanje nivoa uređaja
    if (code.startsWith('SM_')) return DeviceLevel.secretMaster;
    if (code.startsWith('MA_')) return DeviceLevel.masterAdmin;
    if (code.startsWith('SD_')) return DeviceLevel.seedDevice;
    if (code.startsWith('RD_')) return DeviceLevel.regularDevice;
    return null;
  }

  bool canAccessFeature(String feature) {
    if (_currentDeviceLevel == null) return false;

    final permissions =
        DeviceHierarchy.getDevicePermissions(_currentDeviceLevel!);
    return permissions.contains(feature);
  }
}
