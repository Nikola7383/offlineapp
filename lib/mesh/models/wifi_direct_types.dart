import 'dart:async';

abstract class WifiP2pInterface {
  Future<bool> isSupported();
  Future<bool> isEnabled();
  Future<void> enable();
  Future<void> startDiscovery();
  Future<void> stopDiscovery();
  Future<WifiP2pInfo> connect(String address);
  Future<void> startListeningToP2pState();
  Future<void> stopListeningToP2pState();

  Stream<WifiP2pEvent> get onPeerDiscovered;
  Stream<ConnectionChangedEvent> get onConnectionChanged;
}

class WifiP2p implements WifiP2pInterface {
  @override
  Future<bool> isSupported() async => throw UnimplementedError();

  @override
  Future<bool> isEnabled() async => throw UnimplementedError();

  @override
  Future<void> enable() async => throw UnimplementedError();

  @override
  Future<void> startDiscovery() async => throw UnimplementedError();

  @override
  Future<void> stopDiscovery() async => throw UnimplementedError();

  @override
  Future<WifiP2pInfo> connect(String address) async =>
      throw UnimplementedError();

  @override
  Future<void> startListeningToP2pState() async => throw UnimplementedError();

  @override
  Future<void> stopListeningToP2pState() async => throw UnimplementedError();

  @override
  Stream<WifiP2pEvent> get onPeerDiscovered => throw UnimplementedError();
  @override
  Stream<ConnectionChangedEvent> get onConnectionChanged =>
      throw UnimplementedError();
}

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

class WifiP2pConnection {
  final WifiP2pInfo info;
  bool _isConnected = true;

  WifiP2pConnection(this.info);

  bool get isConnected => _isConnected;

  Future<void> send(Uint8List data) async {
    if (!_isConnected) throw Exception('Connection is closed');
    // Implementacija će biti dodata kasnije
  }

  Future<void> disconnect() async {
    _isConnected = false;
  }
}
