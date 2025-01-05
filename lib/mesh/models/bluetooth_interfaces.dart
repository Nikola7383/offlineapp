import 'bluetooth_types.dart';

abstract class FlutterBluetoothSerial {
  Future<bool?> get isEnabled;
  Future<List<BluetoothDevice>> getBondedDevices();
  Stream<BluetoothDiscoveryResult> startDiscovery();
  Future<bool?> requestEnable();
  Future<bool?> requestDisable();

  static final FlutterBluetoothSerial instance = throw UnimplementedError();
}

abstract class BluetoothDevice {
  String get address;
  String get name;
  bool get isBonded;
  BluetoothDeviceType get type;
  BluetoothBondState get bondState;
}

abstract class BluetoothDeviceOutput {
  Future<void> get allSent;
  void add(List<int> data);
}

abstract class BluetoothConnection {
  bool get isConnected;
  BluetoothDeviceOutput get output;
  Future<void> close();
  Future<void> finish();

  static Future<BluetoothConnection> toAddress(String address) async =>
      throw UnimplementedError();
}

class BluetoothDiscoveryResult {
  final BluetoothDevice device;
  final int rssi;

  BluetoothDiscoveryResult({
    required this.device,
    required this.rssi,
  });
}
