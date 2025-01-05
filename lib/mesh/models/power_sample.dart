class PowerSample {
  final DateTime timestamp;
  final double batteryLevel;
  final double powerDraw;
  final List<Protocol> activeProtocols;

  PowerSample({
    required this.timestamp,
    required this.batteryLevel,
    required this.powerDraw,
    required this.activeProtocols,
  });
}
