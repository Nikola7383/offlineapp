import 'dart:async';
import 'dart:typed_data' show Uint8List;
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import '../../../lib/mesh/protocols/wifi_direct_manager.dart';
import '../../../lib/mesh/models/node.dart';
import '../../../lib/mesh/models/protocol.dart';
import '../../../lib/mesh/models/wifi_direct_types.dart';

// Mock klase za WiFi P2P
class MockWifiP2p implements WifiP2pInterface {
  bool _isEnabled = true;
  bool _isSupported = true;
  final List<StreamController<WifiP2pEvent>> _controllers = [];
  final List<String> _connectedDevices = [];
  final _connectionController =
      StreamController<ConnectionChangedEvent>.broadcast();
  final _peerController = StreamController<WifiP2pEvent>.broadcast();

  void reset() {
    _isEnabled = true;
    _isSupported = true;
    _connectedDevices.clear();
  }

  @override
  Future<bool> isSupported() async => _isSupported;

  @override
  Future<bool> isEnabled() async => _isEnabled;

  @override
  Future<void> enable() async => _isEnabled = true;

  @override
  Future<void> startDiscovery() async {
    if (!_isEnabled) throw Exception('WiFi P2P is disabled');
    if (!_isSupported) throw Exception('WiFi P2P is not supported');

    _peerController.add(PeerDiscoveredEvent(
        WifiP2pDevice('AA:BB:CC:DD:EE:FF', 'Test Device', 0.8)));
  }

  @override
  Future<void> stopDiscovery() async {}

  @override
  Future<WifiP2pInfo> connect(String address) async {
    if (!_isEnabled) throw Exception('WiFi P2P is disabled');
    _connectedDevices.add(address);
    return WifiP2pInfo(address, true);
  }

  @override
  Stream<WifiP2pEvent> get onPeerDiscovered => _peerController.stream;

  @override
  Stream<ConnectionChangedEvent> get onConnectionChanged =>
      _connectionController.stream;

  @override
  Future<void> startListeningToP2pState() async {
    if (!_isEnabled) throw Exception('WiFi P2P is disabled');
  }

  @override
  Future<void> stopListeningToP2pState() async {}

  // Helper metode za testiranje
  void simulateConnection(String address) {
    _connectionController.add(ConnectionChangedEvent(address, true));
  }

  void simulateDisconnection(String address) {
    _connectionController.add(ConnectionChangedEvent(address, false));
  }

  void dispose() {
    _connectionController.close();
    _peerController.close();
  }
}

// Mock modeli
class WifiP2pDevice {
  final String deviceAddress;
  final String deviceName;
  final double signalStrength;

  WifiP2pDevice(this.deviceAddress, this.deviceName, this.signalStrength);
}

class WifiP2pInfo {
  final String deviceAddress;
  final bool isGroupOwner;

  WifiP2pInfo(this.deviceAddress, this.isGroupOwner);
}

class WifiP2pEvent {}

class PeerDiscoveredEvent extends WifiP2pEvent {
  final WifiP2pDevice peer;
  PeerDiscoveredEvent(this.peer);
}

class ConnectionChangedEvent extends WifiP2pEvent {
  final String deviceAddress;
  final bool connected;
  ConnectionChangedEvent(this.deviceAddress, this.connected);
}

void main() {
  late WiFiDirectManager wifiDirectManager;
  late MockWifiP2p mockWifiP2p;

  setUp(() {
    mockWifiP2p = MockWifiP2p();
    wifiDirectManager = WiFiDirectManager(mockWifiP2p);
  });

  tearDown(() {
    mockWifiP2p.dispose();
  });

  group('Device Discovery', () {
    test('Should discover devices when WiFi P2P is enabled', () async {
      final discoveredNodes = await wifiDirectManager.scanForDevices();

      expect(discoveredNodes, isNotEmpty);
      expect(discoveredNodes.first.id, equals('AA:BB:CC:DD:EE:FF'));
      expect(discoveredNodes.first.signalStrength, closeTo(0.8, 0.01));
    });

    test('Should handle discovery when WiFi P2P is disabled', () async {
      mockWifiP2p._isEnabled = false;
      final discoveredNodes = await wifiDirectManager.scanForDevices();
      expect(discoveredNodes, isEmpty);
    });

    test('Should handle unsupported devices', () async {
      mockWifiP2p._isSupported = false;
      final discoveredNodes = await wifiDirectManager.scanForDevices();
      expect(discoveredNodes, isEmpty);
    });
  });

  group('Data Transmission', () {
    test('Should send data successfully', () async {
      final testData = List<int>.generate(1000, (i) => i % 256);
      final success =
          await wifiDirectManager.sendData('AA:BB:CC:DD:EE:FF', testData);

      expect(success, isTrue);
      expect(mockWifiP2p._connectedDevices, contains('AA:BB:CC:DD:EE:FF'));
    });

    test('Should handle send errors gracefully', () async {
      mockWifiP2p._isEnabled = false;

      final testData = List<int>.generate(10, (i) => i);
      final success =
          await wifiDirectManager.sendData('AA:BB:CC:DD:EE:FF', testData);

      expect(success, isFalse);
    });
  });

  group('Connection Management', () {
    test('Should start listening successfully', () async {
      await expectLater(wifiDirectManager.startListening(), completes);
    });

    test('Should stop listening and clean up', () async {
      await wifiDirectManager.startListening();
      await expectLater(wifiDirectManager.stopListening(), completes);
    });

    test('Should handle connection events', () async {
      await wifiDirectManager.startListening();

      mockWifiP2p.simulateConnection('AA:BB:CC:DD:EE:FF');

      await Future.delayed(Duration(milliseconds: 100));

      expect(mockWifiP2p._connectedDevices, contains('AA:BB:CC:DD:EE:FF'));
    });
  });
}
