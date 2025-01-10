import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:wifi_p2p_flutter/wifi_p2p_flutter.dart';
import '../models/node.dart';
import 'message_transport.dart';

/// Implementacija transporta preko WiFi Direct-a
class WiFiDirectTransport implements MessageTransport {
  final WifiP2pFlutter _wifiP2p = WifiP2pFlutter();
  final _stats = _WiFiDirectTransportStats();

  // Stream controller za poruke
  final _messageController = StreamController<TransportMessage>.broadcast();

  // Aktivne konekcije
  final Map<String, Socket> _connections = {};

  // Server socket za prihvatanje konekcija
  ServerSocket? _serverSocket;

  // Status transporta
  TransportStatus _status = TransportStatus.notInitialized;

  // Konstante
  static const int PORT = 8888;

  @override
  TransportStatus get status => _status;

  @override
  Stream<TransportMessage> get messageStream => _messageController.stream;

  @override
  Future<void> initialize() async {
    try {
      _status = TransportStatus.initializing;

      // Inicijalizuj WiFi P2P
      await _wifiP2p.initialize();

      // Proveri da li je WiFi uključen
      final isEnabled = await _wifiP2p.isWifiEnabled();
      if (!isEnabled) {
        await _wifiP2p.enableWifi();
      }

      // Započni osluškivanje
      await _startServer();
      await _startDiscovery();

      _status = TransportStatus.ready;
    } catch (e) {
      _status = TransportStatus.error;
      throw TransportException(
        'Inicijalizacija WiFi Direct-a nije uspela',
        details: e,
      );
    }
  }

  @override
  Future<void> sendData(
    String targetNodeId,
    Uint8List data,
    TransportOptions options,
  ) async {
    try {
      final socket = await _getConnection(targetNodeId);

      // Pošalji podatke
      socket.add(data);
      await socket.flush();

      _stats._recordSentMessage(data.length);

      // Čekaj potvrdu ako je potrebno
      if (options.requireAck) {
        await _waitForAck(socket, options.timeout);
      }
    } catch (e) {
      _stats._recordFailedDelivery();
      throw TransportException(
        'Slanje podataka nije uspelo',
        details: e,
      );
    }
  }

  @override
  Future<void> broadcast(Uint8List data, TransportOptions options) async {
    final nodes = await discoverNodes();
    final futures = <Future>[];

    for (final node in nodes) {
      futures.add(
        sendData(node.id, data, options).catchError((e) {
          // Ignoriši greške pri broadcast-u
          print('Greška pri slanju na ${node.id}: $e');
        }),
      );
    }

    await Future.wait(futures);
  }

  @override
  Future<List<Node>> discoverNodes() async {
    try {
      final peers = await _wifiP2p.discoverPeers();
      return peers
          .map((peer) => Node(
                id: peer.deviceAddress,
                isActive: true,
                batteryLevel: 1.0, // TODO: Implementirati proveru baterije
                type: NodeType.regular,
                capabilities: {
                  'name': peer.deviceName,
                  'isGroupOwner': peer.isGroupOwner,
                  'primaryDeviceType': peer.primaryDeviceType,
                },
              ))
          .toList();
    } catch (e) {
      throw TransportException(
        'Pretraga uređaja nije uspela',
        details: e,
      );
    }
  }

  @override
  Future<bool> isNodeAvailable(String nodeId) async {
    try {
      final peers = await _wifiP2p.discoverPeers();
      return peers.any((p) => p.deviceAddress == nodeId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    _status = TransportStatus.notInitialized;

    // Zatvori sve konekcije
    for (final socket in _connections.values) {
      await socket.close();
    }
    _connections.clear();

    // Zatvori server
    await _serverSocket?.close();
    _serverSocket = null;

    await _messageController.close();
    await _wifiP2p.close();
  }

  /// Pokreće server za prihvatanje konekcija
  Future<void> _startServer() async {
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, PORT);

    _serverSocket!.listen((socket) {
      final address = socket.remoteAddress.address;
      _handleNewConnection(address, socket);
    });
  }

  /// Započinje otkrivanje drugih uređaja
  Future<void> _startDiscovery() async {
    _wifiP2p.streamPeers().listen(
      (peers) {
        // Pokušaj konekciju sa novim peer-ovima
        for (final peer in peers) {
          _connectToPeer(peer);
        }
      },
      onError: (error) {
        print('Greška pri discovery-ju: $error');
      },
    );

    await _wifiP2p.discoverPeers();
  }

  /// Povezuje se sa peer-om
  Future<void> _connectToPeer(WifiP2pDevice peer) async {
    try {
      await _wifiP2p.connect(peer);

      // Sačekaj da se uspostavi konekcija
      await Future.delayed(const Duration(seconds: 2));

      // Pokušaj da se povežeš na peer-ov server
      final socket = await Socket.connect(peer.deviceAddress, PORT);
      _handleNewConnection(peer.deviceAddress, socket);
    } catch (e) {
      print('Konekcija nije uspela: $e');
    }
  }

  /// Obrađuje novu konekciju
  void _handleNewConnection(String address, Socket socket) {
    _connections[address] = socket;

    // Osluškuj poruke
    socket.listen(
      (data) {
        _handleIncomingData(address, data);
      },
      onError: (error) {
        print('Greška pri čitanju: $error');
        _connections.remove(address);
      },
      onDone: () {
        _connections.remove(address);
      },
    );
  }

  /// Obrađuje dolazne podatke
  void _handleIncomingData(String sourceNodeId, Uint8List data) {
    _stats._recordReceivedMessage(data.length);

    _messageController.add(TransportMessage(
      sourceNodeId: sourceNodeId,
      data: data,
      timestamp: DateTime.now(),
      metadata: {
        'transport': 'wifi_direct',
      },
    ));
  }

  /// Vraća postojeću ili kreira novu konekciju
  Future<Socket> _getConnection(String nodeId) async {
    if (_connections.containsKey(nodeId)) {
      return _connections[nodeId]!;
    }

    final peers = await _wifiP2p.discoverPeers();
    final peer = peers.firstWhere(
      (p) => p.deviceAddress == nodeId,
      orElse: () => throw TransportException('Čvor nije pronađen'),
    );

    await _wifiP2p.connect(peer);

    // Sačekaj da se uspostavi konekcija
    await Future.delayed(const Duration(seconds: 2));

    final socket = await Socket.connect(nodeId, PORT);
    _connections[nodeId] = socket;
    return socket;
  }

  /// Čeka potvrdu prijema
  Future<void> _waitForAck(Socket socket, Duration timeout) async {
    // TODO: Implementirati protokol za potvrdu prijema
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

/// Implementacija statistike za WiFi Direct transport
class _WiFiDirectTransportStats implements TransportStats {
  int _messagesSent = 0;
  int _messagesReceived = 0;
  int _failedDeliveries = 0;
  double _totalLatency = 0;
  int _latencyMeasurements = 0;
  double _totalSignalStrength = 0;
  int _signalMeasurements = 0;

  @override
  int get totalMessagesSent => _messagesSent;

  @override
  int get totalMessagesReceived => _messagesReceived;

  @override
  int get failedDeliveries => _failedDeliveries;

  @override
  double get averageLatency =>
      _latencyMeasurements > 0 ? _totalLatency / _latencyMeasurements : 0;

  @override
  double get averageSignalStrength =>
      _signalMeasurements > 0 ? _totalSignalStrength / _signalMeasurements : 0;

  @override
  double get deliverySuccessRate => _messagesSent > 0
      ? (_messagesSent - _failedDeliveries) / _messagesSent
      : 0.0;

  @override
  void reset() {
    _messagesSent = 0;
    _messagesReceived = 0;
    _failedDeliveries = 0;
    _totalLatency = 0;
    _latencyMeasurements = 0;
    _totalSignalStrength = 0;
    _signalMeasurements = 0;
  }

  void _recordSentMessage(int size) {
    _messagesSent++;
  }

  void _recordReceivedMessage(int size) {
    _messagesReceived++;
  }

  void _recordFailedDelivery() {
    _failedDeliveries++;
  }

  void _recordLatency(Duration latency) {
    _totalLatency += latency.inMilliseconds;
    _latencyMeasurements++;
  }

  void _recordSignalStrength(double strength) {
    _totalSignalStrength += strength;
    _signalMeasurements++;
  }
}
