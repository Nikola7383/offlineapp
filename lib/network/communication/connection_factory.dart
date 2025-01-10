import 'network_communicator.dart';
import 'bluetooth_connection.dart';
import 'wifi_direct_connection.dart';
import 'sound_connection.dart';
import 'connection_manager.dart';

/// Factory za kreiranje konekcija
class ConnectionFactory {
  /// Kreira konekciju određenog tipa
  static Future<NodeConnection?> createConnection(
    String nodeId,
    ConnectionType type,
  ) async {
    NodeConnection? connection;

    switch (type) {
      case ConnectionType.bluetooth:
        connection = BluetoothConnection(nodeId: nodeId);
        break;
      case ConnectionType.wifiDirect:
        connection = WiFiDirectConnection(nodeId: nodeId);
        break;
      case ConnectionType.sound:
        connection = SoundConnection(nodeId: nodeId);
        break;
    }

    if (connection != null && await connection.initialize()) {
      return connection;
    }

    return null;
  }

  /// Kreira konekciju sa najboljim dostupnim tipom
  static Future<NodeConnection?> createBestConnection(String nodeId) async {
    // Pokušaj svaki tip konekcije po prioritetu
    for (final type in ConnectionType.values) {
      try {
        final connection = await createConnection(nodeId, type);
        if (connection != null) {
          return connection;
        }
      } catch (e) {
        print('Greška pri kreiranju $type konekcije: $e');
        continue;
      }
    }

    return null;
  }

  /// Proverava dostupnost određenog tipa konekcije
  static Future<bool> isConnectionTypeAvailable(ConnectionType type) async {
    switch (type) {
      case ConnectionType.bluetooth:
        // TODO: Implementirati proveru dostupnosti Bluetooth-a
        return true;
      case ConnectionType.wifiDirect:
        // TODO: Implementirati proveru dostupnosti WiFi Direct-a
        return true;
      case ConnectionType.sound:
        // Zvučna komunikacija je uvek dostupna
        return true;
    }
  }

  /// Vraća listu dostupnih tipova konekcija
  static Future<List<ConnectionType>> getAvailableConnectionTypes() async {
    final availableTypes = <ConnectionType>[];

    for (final type in ConnectionType.values) {
      if (await isConnectionTypeAvailable(type)) {
        availableTypes.add(type);
      }
    }

    return availableTypes;
  }

  /// Vraća najbolji dostupni tip konekcije
  static Future<ConnectionType?> getBestAvailableType() async {
    final availableTypes = await getAvailableConnectionTypes();
    return availableTypes.isNotEmpty ? availableTypes.first : null;
  }
}
