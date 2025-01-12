/// Tipovi za mrežnu komunikaciju

/// Status transportnog sloja
enum TransportStatus {
  connected, // Uspešno povezan
  disconnected, // Nije povezan
  connecting, // U procesu povezivanja
  error // Greška u povezivanju
}

/// Status rute
enum RouteStatus {
  active, // Ruta je aktivna
  inactive, // Ruta je neaktivna
  blocked, // Ruta je blokirana
  unknown // Status rute nije poznat
}

/// Tip konekcije
enum ConnectionType {
  bluetooth, // Bluetooth konekcija
  wifi, // WiFi konekcija
  wifiDirect, // WiFi Direct konekcija
  sound, // Zvučna konekcija
  cellular // Mobilna mreža
}

/// Status konekcije
enum ConnectionStatus {
  connected, // Uspešno povezan
  disconnected, // Nije povezan
  connecting, // U procesu povezivanja
  error // Greška u povezivanju
}

/// Informacije o ruti
class RouteInfo {
  final String routeId;
  final RouteStatus status;
  final DateTime lastUpdated;
  final Map<String, dynamic>? metadata;

  const RouteInfo({
    required this.routeId,
    required this.status,
    required this.lastUpdated,
    this.metadata,
  });
}

/// Status servisa za razmenu poruka
class MessagingServiceStatus {
  final TransportStatus transportStatus;
  final RouteStatus routeStatus;
  final List<String> activeConnections;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const MessagingServiceStatus({
    required this.transportStatus,
    required this.routeStatus,
    required this.activeConnections,
    required this.timestamp,
    this.metadata,
  });
}

/// Informacije o konekciji
class ConnectionInfo {
  final String connectionId;
  final ConnectionType type;
  final ConnectionStatus status;
  final DateTime established;
  final Map<String, dynamic>? metadata;

  const ConnectionInfo({
    required this.connectionId,
    required this.type,
    required this.status,
    required this.established,
    this.metadata,
  });
}
