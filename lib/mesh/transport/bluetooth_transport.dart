import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../models/node.dart';
import 'message_transport.dart';

/// Implementacija transporta preko Bluetooth-a
class BluetoothTransport implements MessageTransport {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  final _stats = _BluetoothTransportStats();

  // Stream controller za poruke
  final _messageController = StreamController<TransportMessage>.broadcast();

  // Aktivne konekcije
  final Map<String, BluetoothConnection> _connections = {};

  // Status transporta
  TransportStatus _status = TransportStatus.notInitialized;

  @override
  TransportStatus get status => _status;

  @override
  Stream<TransportMessage> get messageStream => _messageController.stream;

  @override
  Future<void> initialize() async {
    try {
      _status = TransportStatus.initializing;

      // Proveri dozvole
      final isEnabled = await _bluetooth.isEnabled ?? false;
      if (!isEnabled) {
        await _bluetooth.requestEnable();
      }

      // Započni osluškivanje
      await _startListening();

      _status = TransportStatus.ready;
    } catch (e) {
      _status = TransportStatus.error;
      throw TransportException(
        'Inicijalizacija Bluetooth-a nije uspela',
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
      final connection = await _getConnection(targetNodeId);

      // Pošalji podatke
      connection.output.add(data);
      await connection.output.allSent;

      _stats._recordSentMessage(data.length);

      // Čekaj potvrdu ako je potrebno
      if (options.requireAck) {
        await _waitForAck(connection, options.timeout);
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
      final results = await _bluetooth.getBondedDevices();
      return results
          .map((device) => Node(
                id: device.address,
                isActive: device.isConnected,
                batteryLevel: 1.0, // TODO: Implementirati proveru baterije
                type: NodeType.regular,
                capabilities: {
                  'name': device.name,
                  'bondState': device.bondState.toString(),
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
      final devices = await _bluetooth.getBondedDevices();
      return devices.any((d) => d.address == nodeId && d.isConnected);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    _status = TransportStatus.notInitialized;

    // Zatvori sve konekcije
    for (final connection in _connections.values) {
      await connection.close();
    }
    _connections.clear();

    await _messageController.close();
  }

  /// Započinje osluškivanje dolaznih konekcija
  Future<void> _startListening() async {
    _bluetooth.startDiscovery().listen(
      (device) {
        // Pokušaj konekciju sa novim uređajem
        _connectToDevice(device);
      },
      onError: (error) {
        print('Greška pri discovery-ju: $error');
      },
    );
  }

  /// Povezuje se sa uređajem
  Future<void> _connectToDevice(BluetoothDiscoveryResult device) async {
    try {
      final connection =
          await BluetoothConnection.toAddress(device.device.address);
      _connections[device.device.address] = connection;

      // Osluškuj poruke
      connection.input?.listen(
        (data) {
          _handleIncomingData(device.device.address, data);
        },
        onError: (error) {
          print('Greška pri čitanju: $error');
          _connections.remove(device.device.address);
        },
        onDone: () {
          _connections.remove(device.device.address);
        },
      );
    } catch (e) {
      print('Konekcija nije uspela: $e');
    }
  }

  /// Obrađuje dolazne podatke
  void _handleIncomingData(String sourceNodeId, Uint8List data) {
    _stats._recordReceivedMessage(data.length);

    _messageController.add(TransportMessage(
      sourceNodeId: sourceNodeId,
      data: data,
      timestamp: DateTime.now(),
      metadata: {
        'transport': 'bluetooth',
      },
    ));
  }

  /// Vraća postojeću ili kreira novu konekciju
  Future<BluetoothConnection> _getConnection(String nodeId) async {
    if (_connections.containsKey(nodeId)) {
      return _connections[nodeId]!;
    }

    final connection = await BluetoothConnection.toAddress(nodeId);
    _connections[nodeId] = connection;
    return connection;
  }

  /// Čeka potvrdu prijema
  Future<void> _waitForAck(
      BluetoothConnection connection, Duration timeout) async {
    // TODO: Implementirati protokol za potvrdu prijema
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

/// Implementacija statistike za Bluetooth transport
class _BluetoothTransportStats implements TransportStats {
  int _messagesSent = 0;
  int _messagesReceived = 0;
  int _failedDeliveries = 0;
  double _totalLatency = 0;
  int _latencyMeasurements = 0;

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
  double get averageSignalStrength => 0.0; // TODO: Implementirati

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
}
