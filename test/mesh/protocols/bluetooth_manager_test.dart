@GenerateMocks([])
import 'dart:typed_data' show Uint8List;
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../../lib/mesh/protocols/bluetooth_manager.dart';
import '../../../lib/mesh/models/node.dart';
import '../../../lib/mesh/models/protocol.dart';
import '../../../lib/mesh/models/bluetooth_types.dart';
import '../../../lib/mesh/models/bluetooth_interfaces.dart';

// Definišemo interfejs umesto importa flutter_bluetooth_serial
abstract class BluetoothDevice {
  String get address;
  String get name;
  bool get isBonded;
  BluetoothDeviceType get type;
  BluetoothBondState get bondState;
}

abstract class BluetoothDeviceOutput {
  Future<void> get allSent;
  void add(Uint8List data);
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

  BluetoothDiscoveryResult({required this.device, required this.rssi});
}

// Custom Mock implementacije
class MockBluetoothSerial extends Fake implements FlutterBluetoothSerial {
  bool _throwOnDiscovery = false;

  void setThrowOnDiscovery(bool value) {
    _throwOnDiscovery = value;
  }

  @override
  Future<bool?> get isEnabled => Future.value(true);

  @override
  Future<List<BluetoothDevice>> getBondedDevices() async {
    return [MockBluetoothDevice('AA:BB:CC:DD:EE:FF', true)];
  }

  @override
  Stream<BluetoothDiscoveryResult> startDiscovery() {
    if (_throwOnDiscovery) {
      throw Exception('Scan failed');
    }
    return Stream.fromIterable([
      BluetoothDiscoveryResult(
        device: MockBluetoothDevice('AA:BB:CC:DD:EE:FF', true),
        rssi: -70,
      )
    ]);
  }

  @override
  Future<bool?> requestEnable() async => true;
}

class MockBluetoothDevice implements BluetoothDevice {
  @override
  final String address;
  @override
  final String name;
  @override
  final bool isBonded;
  @override
  final BluetoothDeviceType type = BluetoothDeviceType.unknown;
  @override
  final BluetoothBondState bondState = BluetoothBondState.bonded;

  MockBluetoothDevice(this.address, this.isBonded, {this.name = 'Mock Device'});
}

class MockBluetoothConnection implements BluetoothConnection {
  static final Map<String, MockBluetoothConnection> _instances = {};
  final MockBluetoothOutput _output = MockBluetoothOutput();
  bool _isConnected = true;

  @override
  bool get isConnected => _isConnected;

  @override
  BluetoothDeviceOutput get output => _output;

  @override
  Future<void> close() async {
    _isConnected = false;
  }

  @override
  Future<void> finish() async {
    await close();
  }

  static Future<BluetoothConnection> toAddress(String address) async {
    return _instances.putIfAbsent(address, () => MockBluetoothConnection());
  }
}

class MockBluetoothOutput implements BluetoothDeviceOutput {
  final List<List<int>> sentData = [];

  @override
  Future<void> get allSent => Future.value();

  @override
  add(Uint8List data) {
    sentData.add(data.toList());
  }
}

void main() {
  late BluetoothManager bluetoothManager;
  late MockBluetoothSerial mockBluetooth;

  setUp(() {
    mockBluetooth = MockBluetoothSerial();
    bluetoothManager = BluetoothManager(mockBluetooth);
  });

  group('Bluetooth Device Discovery', () {
    test('Should discover devices', () async {
      final discoveredNodes = await bluetoothManager.scanForDevices();
      expect(discoveredNodes.length, equals(1));
      expect(discoveredNodes.first.id, equals('AA:BB:CC:DD:EE:FF'));
    });

    test('Should handle scan errors gracefully', () async {
      mockBluetooth.setThrowOnDiscovery(true);
      final nodes = await bluetoothManager.scanForDevices();
      expect(nodes, isEmpty);
    });
  });

  group('Data Transmission', () {
    test('Should send data successfully', () async {
      final testData = List<int>.generate(1000, (i) => i % 256);
      final result =
          await bluetoothManager.sendData('AA:BB:CC:DD:EE:FF', testData);
      expect(result, isTrue);
    });

    test('Should handle send errors gracefully', () async {
      final invalidAddress = 'INVALID';
      final testData = List<int>.generate(10, (i) => i);
      final result = await bluetoothManager.sendData(invalidAddress, testData);
      expect(result, isFalse);
    });
  });

  group('Connection Management', () {
    test('Should start and stop listening without errors', () async {
      await expectLater(bluetoothManager.startListening(), completes);
      await expectLater(bluetoothManager.stopListening(), completes);
    });
  });
}
