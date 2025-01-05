import 'dart:async';
import 'dart:typed_data';
import '../models/protocol_manager.dart';
import '../models/node.dart';
import '../models/protocol.dart';
import '../models/bluetooth_interfaces.dart';
import '../models/bluetooth_types.dart';

class BluetoothManager implements ProtocolManager {
  final FlutterBluetoothSerial bluetooth;
  final Map<String, BluetoothConnection> _connections = {};
  static const int MTU_SIZE = 512;

  BluetoothManager([FlutterBluetoothSerial? bluetoothInstance])
      : bluetooth = bluetoothInstance ?? FlutterBluetoothSerial.instance;

  @override
  Future<List<Node>> scanForDevices() async {
    List<Node> discoveredNodes = [];

    try {
      bool? isEnabled = await bluetooth.isEnabled;
      if (isEnabled != true) {
        await bluetooth.requestEnable();
      }

      await for (BluetoothDiscoveryResult result
          in bluetooth.startDiscovery()) {
        if (result.device.isBonded) {
          discoveredNodes.add(Node(
            result.device.address,
            batteryLevel: 1.0,
            signalStrength: _calculateSignalStrength(result.rssi),
            managers: <Protocol, ProtocolManager>{},
          ));
        }
      }
    } catch (e) {
      print('Bluetooth scan error: $e');
    }

    return discoveredNodes;
  }

  @override
  Future<bool> sendData(String nodeId, List<int> data) async {
    try {
      BluetoothConnection? connection = _connections[nodeId];

      if (connection == null || !connection.isConnected) {
        connection = await BluetoothConnection.toAddress(nodeId);
        _connections[nodeId] = connection;
      }

      final chunks = _splitIntoChunks(data, MTU_SIZE);
      for (var chunk in chunks) {
        connection.output.add(Uint8List.fromList(chunk));
        await connection.output.allSent;
      }

      return true;
    } catch (e) {
      print('Bluetooth send error: $e');
      return false;
    }
  }

  @override
  Future<void> startListening() async {
    try {
      final devices = await bluetooth.getBondedDevices();
      for (var device in devices) {
        _listenToDevice(device.address);
      }
    } catch (e) {
      print('Start listening error: $e');
    }
  }

  @override
  Future<void> stopListening() async {
    for (var connection in _connections.values) {
      await connection.close();
    }
    _connections.clear();
  }

  double _calculateSignalStrength(int rssi) {
    return (rssi + 100) / 100.0;
  }

  List<List<int>> _splitIntoChunks(List<int> data, int chunkSize) {
    List<List<int>> chunks = [];
    for (var i = 0; i < data.length; i += chunkSize) {
      var end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
      chunks.add(data.sublist(i, end));
    }
    return chunks;
  }

  void _listenToDevice(String address) async {
    try {
      final connection = await BluetoothConnection.toAddress(address);
      _connections[address] = connection;
    } catch (e) {
      print('Device listening error: $e');
    }
  }
}
