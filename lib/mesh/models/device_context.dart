class DeviceContext {
  final double batteryLevel;
  final double signalStrength;
  final double distance;
  final bool hasWifi;
  final bool hasBluetooth;

  DeviceContext({
    required this.batteryLevel,
    required this.signalStrength,
    required this.distance,
    this.hasWifi = true,
    this.hasBluetooth = true,
  });
}
