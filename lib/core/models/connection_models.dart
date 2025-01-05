/// Tipovi konekcija
enum ConnectionType { wifi, bluetooth, cellular, ethernet }

/// Status konekcije
class ConnectionStatus {
  final bool isConnected;
  final Set<ConnectionType> activeTypes;
  final ConnectionStrength strength;
  final DateTime timestamp;

  const ConnectionStatus({
    required this.isConnected,
    required this.activeTypes,
    required this.strength,
    required this.timestamp,
  });

  /// Kreira offline status
  factory ConnectionStatus.offline() {
    return ConnectionStatus(
      isConnected: false,
      activeTypes: {},
      strength: ConnectionStrength.none,
      timestamp: DateTime.now(),
    );
  }
}

/// Jačina konekcije
enum ConnectionStrength { none, weak, moderate, strong }

/// Konfiguracija za connection service
class ConnectionConfig {
  final Duration checkInterval;
  final Set<ConnectionType> enabledTypes;
  final bool autoReconnect;
  final int maxReconnectAttempts;

  const ConnectionConfig({
    this.checkInterval = const Duration(seconds: 30),
    this.enabledTypes = const {
      ConnectionType.wifi,
      ConnectionType.bluetooth,
      ConnectionType.cellular
    },
    this.autoReconnect = true,
    this.maxReconnectAttempts = 3,
  });
}
