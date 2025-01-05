import 'dart:async';
import 'dart:typed_data';
import '../models/protocol_manager.dart';
import '../models/node.dart';
import '../models/protocol.dart';
import '../models/wifi_direct_types.dart';

class WiFiDirectManager implements ProtocolManager {
  static const int CHUNK_SIZE = 1024 * 32; // 32KB chunks
  final Map<String, WifiP2pConnection> _connections = {};
  final StreamController<WifiP2pEvent> _eventController =
      StreamController.broadcast();
  bool _isInitialized = false;
  StreamSubscription? _connectionSubscription;

  // Dodajemo dependency injection za testiranje
  final WifiP2pInterface wifiP2p;

  WiFiDirectManager([WifiP2pInterface? wifiP2pInstance])
      : wifiP2p = wifiP2pInstance ?? WifiP2p();

  @override
  Future<List<Node>> scanForDevices() async {
    List<Node> discoveredNodes = [];

    try {
      if (!_isInitialized) {
        await _initialize();
      }

      // Započni P2P skeniranje
      await wifiP2p.startDiscovery();

      // Čekaj rezultate 10 sekundi
      await for (WifiP2pEvent event in wifiP2p.onPeerDiscovered.timeout(
        Duration(seconds: 10),
        onTimeout: (sink) => sink.close(),
      )) {
        if (event is PeerDiscoveredEvent) {
          discoveredNodes.add(Node(
            event.peer.deviceAddress,
            batteryLevel: 1.0, // Biće ažurirano kroz komunikaciju
            signalStrength: event.peer.signalStrength,
            managers: <Protocol, ProtocolManager>{},
          ));
        }
      }

      await wifiP2p.stopDiscovery();
    } catch (e) {
      print('WiFi Direct scan error: $e');
    }

    return discoveredNodes;
  }

  @override
  Future<bool> sendData(String nodeId, List<int> data) async {
    try {
      WifiP2pConnection? connection = _connections[nodeId];

      if (connection == null || !connection.isConnected) {
        final info = await wifiP2p.connect(nodeId);
        connection = WifiP2pConnection(info);
        _connections[nodeId] = connection;
      }

      // Podeli podatke na chunks
      final chunks = _splitIntoChunks(data, CHUNK_SIZE);
      for (var chunk in chunks) {
        await connection.send(Uint8List.fromList(chunk));
      }

      return true;
    } catch (e) {
      print('WiFi Direct send error: $e');
      return false;
    }
  }

  @override
  Future<void> startListening() async {
    try {
      if (!_isInitialized) {
        await _initialize();
      }

      await wifiP2p.startListeningToP2pState();

      _connectionSubscription = wifiP2p.onConnectionChanged.listen((event) {
        if (event.connected) {
          _handleNewConnection(event.deviceAddress);
        } else {
          _connections.remove(event.deviceAddress);
        }
      });
    } catch (e) {
      print('WiFi Direct listening error: $e');
    }
  }

  @override
  Future<void> stopListening() async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    for (var connection in _connections.values) {
      await connection.disconnect();
    }
    _connections.clear();

    try {
      await wifiP2p.stopListeningToP2pState();
    } catch (e) {
      print('Error stopping WiFi Direct listening: $e');
    }
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      final isSupported = await wifiP2p.isSupported();
      if (!isSupported) {
        throw UnsupportedError('WiFi Direct is not supported on this device');
      }

      final isEnabled = await wifiP2p.isEnabled();
      if (!isEnabled) {
        await wifiP2p.enable();
      }

      _isInitialized = true;
    } catch (e) {
      print('WiFi Direct initialization error: $e');
      rethrow;
    }
  }

  Future<void> _handleNewConnection(String deviceAddress) async {
    try {
      final info = await wifiP2p.connect(deviceAddress);
      _connections[deviceAddress] = WifiP2pConnection(info);
    } catch (e) {
      print('Failed to handle new connection: $e');
    }
  }

  List<List<int>> _splitIntoChunks(List<int> data, int chunkSize) {
    List<List<int>> chunks = [];
    for (var i = 0; i < data.length; i += chunkSize) {
      var end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
      chunks.add(data.sublist(i, end));
    }
    return chunks;
  }

  void dispose() {
    stopListening();
    _eventController.close();
  }
}
