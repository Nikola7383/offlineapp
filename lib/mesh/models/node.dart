import 'protocol.dart';
import 'protocol_manager.dart';

/// Tipovi čvorova u mreži
enum NodeType {
  /// Standardni čvor koji može da prosleđuje poruke
  regular,

  /// Super čvor sa većim kapacitetom i mogućnostima
  superNode,

  /// Edge čvor koji služi kao gateway
  edge,

  /// Relay čvor koji samo prosleđuje poruke
  relay,
}

/// Model koji predstavlja čvor u mesh mreži
class Node {
  final String id;
  final bool isActive;
  final double batteryLevel;
  final NodeType type;
  final Map<String, dynamic> capabilities;

  const Node({
    required this.id,
    required this.isActive,
    required this.batteryLevel,
    required this.type,
    this.capabilities = const {},
  });

  /// Kreira kopiju čvora sa ažuriranim vrednostima
  Node copyWith({
    bool? isActive,
    double? batteryLevel,
    NodeType? type,
    Map<String, dynamic>? capabilities,
  }) {
    return Node(
      id: id,
      isActive: isActive ?? this.isActive,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      type: type ?? this.type,
      capabilities: capabilities ?? Map.from(this.capabilities),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isActive == other.isActive &&
          batteryLevel == other.batteryLevel &&
          type == other.type;

  @override
  int get hashCode =>
      id.hashCode ^ isActive.hashCode ^ batteryLevel.hashCode ^ type.hashCode;

  @override
  String toString() {
    return 'Node(id: $id, isActive: $isActive, batteryLevel: $batteryLevel, type: $type)';
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
