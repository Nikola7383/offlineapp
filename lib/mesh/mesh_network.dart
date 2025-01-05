import 'dart:async';
import 'models/node.dart';
import 'models/protocol.dart';
import 'models/protocol_manager.dart';
import 'protocols/bluetooth_manager.dart';
import 'protocols/wifi_direct_manager.dart';
import 'protocols/sound_manager.dart';
import 'routing/mesh_router.dart';

class MeshNetwork {
  final Map<Protocol, ProtocolManager> _protocols;
  final Set<Node> _nodes = {};
  final StreamController<Set<Node>> _nodesController =
      StreamController.broadcast();
  final StreamController<List<int>> _dataController =
      StreamController.broadcast();
  Timer? _scanTimer;
  bool _isRunning = false;
  final MeshRouter _router = MeshRouter();

  MeshNetwork({
    BluetoothManager? bluetoothManager,
    WiFiDirectManager? wifiDirectManager,
    SoundManager? soundManager,
  }) : _protocols = {
          Protocol.bluetooth: bluetoothManager ?? BluetoothManager(),
          Protocol.wifiDirect: wifiDirectManager ?? WiFiDirectManager(),
          Protocol.sound: soundManager ?? SoundManager(),
        };

  /// Započinje mesh mrežu
  Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;

    // Pokreni sve protokole
    for (var manager in _protocols.values) {
      await manager.startListening();

      if (manager is SoundManager) {
        manager.dataStream.listen(_handleIncomingData);
      }
    }

    // Periodično skeniraj za nove uređaje
    _scanTimer =
        Timer.periodic(Duration(seconds: 30), (_) => _scanForDevices());

    // Inicijalno skeniranje
    await _scanForDevices();
  }

  /// Zaustavlja mesh mrežu
  Future<void> stop() async {
    _isRunning = false;
    _scanTimer?.cancel();
    _scanTimer = null;

    for (var manager in _protocols.values) {
      await manager.stopListening();
    }
  }

  /// Šalje podatke svim dostupnim čvorovima
  Future<void> broadcast(List<int> data) async {
    if (!_isRunning) throw StateError('Mesh network is not running');

    for (var node in _nodes) {
      await sendTo(node.id, data);
    }
  }

  /// Šalje podatke određenom čvoru koristeći rutiranje
  Future<bool> sendTo(String nodeId, List<int> data) async {
    if (!_isRunning) throw StateError('Mesh network is not running');

    // Nađi rutu do odredišta
    final route = _router.findRoute(_nodes.first.id, nodeId);
    if (route == null) return false;

    // Ako je direktna veza, koristi postojeću logiku
    if (route.hopCount == 1) {
      final node = _nodes.lookup(nodeId);
      if (node == null) return false;

      for (var entry in node.managers.entries) {
        final success = await entry.value.sendData(nodeId, data);
        if (success) return true;
      }
      return false;
    }

    // Ako nije direktna veza, prosledi sledećem čvoru u ruti
    final nextHop = route.path[1]; // Prvi hop nakon izvora
    final node = _nodes.lookup(nextHop);
    if (node == null) return false;

    // Dodaj routing informacije u podatke
    final routedData = _encodeRoutingData(route, data);

    for (var entry in node.managers.entries) {
      final success = await entry.value.sendData(nextHop, routedData);
      if (success) return true;
    }

    return false;
  }

  /// Skenira za nove uređaje preko svih protokola
  Future<void> _scanForDevices() async {
    final newNodes = <Node>{};

    for (var entry in _protocols.entries) {
      final protocol = entry.key;
      final manager = entry.value;

      final discoveredNodes = await manager.scanForDevices();

      for (var node in discoveredNodes) {
        node.managers[protocol] = manager;
        newNodes.add(node);
      }
    }

    _nodes.clear();
    _nodes.addAll(newNodes);

    // Ažuriraj rute
    _router.updateFromNodes(_nodes);

    _nodesController.add(_nodes);
  }

  /// Obrađuje dolazne podatke
  void _handleIncomingData(List<int> data) {
    _dataController.add(data);
  }

  /// Stream za praćenje promena u mreži
  Stream<Set<Node>> get nodesStream => _nodesController.stream;

  /// Stream za primanje podataka
  Stream<List<int>> get dataStream => _dataController.stream;

  /// Trenutno dostupni čvorovi
  Set<Node> get nodes => Set.from(_nodes);

  /// Čisti resurse
  Future<void> dispose() async {
    await stop();
    await _nodesController.close();
    await _dataController.close();

    for (var manager in _protocols.values) {
      if (manager is SoundManager) {
        manager.dispose();
      }
    }
  }

  // Dodaj pomoćne metode za rutiranje
  List<int> _encodeRoutingData(RouteInfo route, List<int> data) {
    // Dodaj routing header
    final header = [
      ...route.sourceId.codeUnits,
      0x00, // separator
      ...route.targetId.codeUnits,
      0x00,
      route.hopCount,
      ...route.path.map((id) => id.codeUnits).expand((x) => x),
      0x00,
    ];

    return [...header, ...data];
  }

  RouteInfo? _decodeRoutingData(List<int> data) {
    try {
      var i = 0;

      // Čitaj source ID
      final sourceChars = <int>[];
      while (data[i] != 0x00) {
        sourceChars.add(data[i++]);
      }
      i++; // Preskoči separator

      // Čitaj target ID
      final targetChars = <int>[];
      while (data[i] != 0x00) {
        targetChars.add(data[i++]);
      }
      i++; // Preskoči separator

      final hopCount = data[i++];

      // Čitaj path
      final pathIds = <String>[];
      var currentId = <int>[];
      while (data[i] != 0x00) {
        if (data[i] == 0x00) {
          pathIds.add(String.fromCharCodes(currentId));
          currentId = [];
        } else {
          currentId.add(data[i]);
        }
        i++;
      }

      return RouteInfo(
        sourceId: String.fromCharCodes(sourceChars),
        targetId: String.fromCharCodes(targetChars),
        path: pathIds,
        hopCount: hopCount,
      );
    } catch (e) {
      print('Error decoding routing data: $e');
      return null;
    }
  }
}
