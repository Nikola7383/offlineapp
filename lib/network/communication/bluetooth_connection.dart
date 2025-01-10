import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'network_communicator.dart';

/// Upravlja Bluetooth konekcijom sa čvorom
class BluetoothConnection implements NodeConnection {
  @override
  final String nodeId;

  // Bluetooth konekcija
  BluetoothDevice? _device;
  flutter_bluetooth_serial.BluetoothConnection? _connection;

  // Stream controller za primljene poruke
  final _messageController = StreamController<NetworkMessage>.broadcast();

  // Status konekcije
  bool _isConnected = false;
  bool _isConnecting = false;

  // Konstante
  static const Duration CONNECT_TIMEOUT = Duration(seconds: 30);
  static const Duration DISCOVERY_TIMEOUT = Duration(seconds: 10);

  Stream<NetworkMessage> get messageStream => _messageController.stream;
  bool get isConnected => _isConnected;

  BluetoothConnection({
    required this.nodeId,
  });

  /// Inicijalizuje Bluetooth konekciju
  Future<bool> initialize() async {
    try {
      // Proveri da li je Bluetooth uključen
      final bluetoothState = await FlutterBluetoothSerial.instance.state;
      if (bluetoothState != BluetoothState.STATE_ON) {
        // Pokušaj uključiti Bluetooth
        final success = await FlutterBluetoothSerial.instance.requestEnable();
        if (!success) return false;
      }

      // Pronađi uređaj
      _device = await _discoverDevice();
      if (_device == null) return false;

      // Uspostavi konekciju
      return await _connect();
    } catch (e) {
      print('Greška pri inicijalizaciji Bluetooth konekcije: $e');
      return false;
    }
  }

  /// Pronalazi Bluetooth uređaj
  Future<BluetoothDevice?> _discoverDevice() async {
    try {
      // Prvo proveri uparene uređaje
      final bondedDevices =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      final bondedDevice = bondedDevices.firstWhere(
        (d) => d.address == nodeId,
        orElse: () => throw Exception('Uređaj nije uparen'),
      );

      if (bondedDevice != null) return bondedDevice;

      // Ako uređaj nije uparen, pokreni discovery
      final completer = Completer<BluetoothDevice?>();

      // Postavi timeout
      Timer(DISCOVERY_TIMEOUT, () {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });

      // Pretplati se na discovery rezultate
      FlutterBluetoothSerial.instance.startDiscovery().listen(
        (result) {
          if (result.device.address == nodeId && !completer.isCompleted) {
            completer.complete(result.device);
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
        onError: (e) {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      );

      return await completer.future;
    } catch (e) {
      print('Greška pri pronalaženju Bluetooth uređaja: $e');
      return null;
    }
  }

  /// Uspostavlja Bluetooth konekciju
  Future<bool> _connect() async {
    if (_isConnected) return true;
    if (_isConnecting) return false;
    if (_device == null) return false;

    _isConnecting = true;

    try {
      // Uspostavi konekciju
      _connection =
          await flutter_bluetooth_serial.BluetoothConnection.toAddress(
        _device!.address,
      );

      // Pretplati se na primanje podataka
      _connection!.input!.listen(
        _handleReceivedData,
        onDone: () {
          _isConnected = false;
          _connection = null;
        },
        onError: (e) {
          print('Greška pri primanju podataka: $e');
          _isConnected = false;
          _connection = null;
        },
      );

      _isConnected = true;
      _isConnecting = false;
      return true;
    } catch (e) {
      print('Greška pri uspostavljanju Bluetooth konekcije: $e');
      _isConnected = false;
      _isConnecting = false;
      return false;
    }
  }

  /// Obrađuje primljene podatke
  void _handleReceivedData(Uint8List data) {
    try {
      // Parsiraj primljene podatke u poruku
      final message = _parseMessage(data);
      if (message != null) {
        _messageController.add(message);
      }
    } catch (e) {
      print('Greška pri obradi primljenih podataka: $e');
    }
  }

  /// Parsira primljene podatke u poruku
  NetworkMessage? _parseMessage(Uint8List data) {
    try {
      // Format poruke: [type(1)][sourceId(36)][targetId(36)][payload(n)]
      if (data.length < 73) return null; // Minimalna veličina poruke

      final type = MessageType.values[data[0]];
      final sourceId = String.fromCharCodes(data.sublist(1, 37));
      final targetId = String.fromCharCodes(data.sublist(37, 73));
      final payload = data.sublist(73);

      return NetworkMessage(
        type: type,
        sourceId: sourceId,
        targetId: targetId,
        payload: payload,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Greška pri parsiranju poruke: $e');
      return null;
    }
  }

  /// Serijalizuje poruku u bajtove
  Uint8List _serializeMessage(NetworkMessage message) {
    final buffer = BytesBuilder();

    // Dodaj tip poruke
    buffer.addByte(message.type.index);

    // Dodaj source ID (fiksirano na 36 bajtova)
    final sourceIdBytes = Uint8List(36)..setAll(0, message.sourceId.codeUnits);
    buffer.add(sourceIdBytes);

    // Dodaj target ID (fiksirano na 36 bajtova)
    final targetIdBytes = Uint8List(36)..setAll(0, message.targetId.codeUnits);
    buffer.add(targetIdBytes);

    // Dodaj payload
    buffer.add(message.payload);

    return buffer.toBytes();
  }

  @override
  Future<bool> send(NetworkMessage message) async {
    if (!_isConnected) {
      final connected = await _connect();
      if (!connected) return false;
    }

    try {
      final data = _serializeMessage(message);
      _connection!.output.add(data);
      await _connection!.output.allSent;
      return true;
    } catch (e) {
      print('Greška pri slanju poruke: $e');
      return false;
    }
  }

  @override
  Future<void> close() async {
    _isConnected = false;
    await _connection?.close();
    await _messageController.close();
  }
}
