import 'protocol.dart';
import 'protocol_manager.dart';

class Node {
  final String id;
  double batteryLevel;
  double signalStrength;
  final Map<Protocol, ProtocolManager> managers;

  Node(
    this.id, {
    required this.batteryLevel,
    required this.signalStrength,
    required this.managers,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Node(id: $id, battery: $batteryLevel, signal: $signalStrength)';

  Future<List<Node>> getNeighbors() async {
    List<Node> neighbors = [];

    for (var entry in managers.entries) {
      try {
        final protocol = entry.key;
        final manager = entry.value;
        final protocolNeighbors = await manager.scanForDevices();

        for (var neighbor in protocolNeighbors) {
          connections[neighbor.id] = NodeConnection(
            protocol: protocol,
            strength: neighbor.signalStrength,
            lastSeen: DateTime.now(),
          );
        }

        neighbors.addAll(protocolNeighbors);
      } catch (e) {
        print('Discovery failed for protocol ${entry.key}: $e');
      }
    }

    return neighbors;
  }

  List<NodeConnection> getActiveConnections() {
    final now = DateTime.now();
    return connections.values
        .where((conn) => now.difference(conn.lastSeen) < Duration(minutes: 1))
        .toList();
  }

  Future<void> updateConnectionStrength(String nodeId, double strength) async {
    final existing = connections[nodeId];
    if (existing != null) {
      connections[nodeId] = NodeConnection(
        protocol: existing.protocol,
        strength: strength,
        lastSeen: DateTime.now(),
      );
    }
  }
}

class NodeConnection {
  final Protocol protocol;
  final double strength;
  final DateTime lastSeen;

  NodeConnection({
    required this.protocol,
    required this.strength,
    required this.lastSeen,
  });

  bool get isActive =>
      DateTime.now().difference(lastSeen) < Duration(minutes: 1);
}
