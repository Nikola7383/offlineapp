enum DeviceLevel {
  secretMaster, // Najviši nivo - potpuna kontrola
  masterAdmin, // Administrativni nivo - upravljanje seed-ovima
  seedDevice, // Seed uređaji - ograničena kontrola
  regularDevice // Obični uređaji - samo osnovne funkcije
}

class DeviceHierarchy {
  static final Map<DeviceLevel, List<String>> _permissions = {
    DeviceLevel.secretMaster: [
      'full_encryption',
      'key_management',
      'analytics_access',
      'system_wipe',
      'master_control',
      'seed_management',
      'network_monitoring',
      'emergency_protocols'
    ],
    DeviceLevel.masterAdmin: [
      'seed_management',
      'local_encryption',
      'network_monitoring',
      'emergency_broadcast',
      'traffic_control'
    ],
    DeviceLevel.seedDevice: [
      'basic_encryption',
      'message_relay',
      'status_reporting',
      'emergency_response'
    ],
    DeviceLevel.regularDevice: [
      'message_receive',
      'status_update',
      'basic_security'
    ]
  };

  static List<String> getDevicePermissions(DeviceLevel level) {
    return _permissions[level] ?? [];
  }
}
