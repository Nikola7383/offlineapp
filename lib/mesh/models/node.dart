import 'package:equatable/equatable.dart';

/// Status čvora u mreži
enum NodeStatus {
  /// Aktivan čvor
  active,

  /// Neaktivan čvor
  inactive,

  /// Čvor u procesu povezivanja
  connecting,

  /// Čvor koji je izgubio konekciju
  disconnected,

  /// Čvor koji je uklonjen iz mreže
  removed
}

/// Tip čvora u mreži
enum NodeType {
  /// Standardni čvor
  standard,

  /// Relay čvor
  relay,

  /// Gateway čvor
  gateway,

  /// Edge čvor
  edge
}

/// Model koji predstavlja čvor u mesh mreži
class Node extends Equatable {
  /// Jedinstveni identifikator čvora
  final String id;

  /// IP adresa čvora
  final String address;

  /// Port na kojem čvor sluša
  final int port;

  /// Nivo baterije (0.0 - 1.0)
  final double batteryLevel;

  /// Da li je čvor aktivan
  final bool isActive;

  /// Tip čvora
  final NodeType type;

  /// Vreme poslednjeg viđenja čvora
  DateTime lastSeen;

  /// Status čvora
  NodeStatus status;

  /// Kreira novi čvor
  Node({
    required this.id,
    required this.address,
    required this.port,
    required this.isActive,
    required this.batteryLevel,
    required this.type,
    DateTime? lastSeen,
    this.status = NodeStatus.active,
  }) : lastSeen = lastSeen ?? DateTime.now();

  /// Ažurira vreme poslednjeg viđenja čvora
  void updateLastSeen(DateTime time) {
    lastSeen = time;
  }

  /// Ažurira status čvora
  void updateStatus(NodeStatus newStatus) {
    status = newStatus;
  }

  /// Vraća vreme proteklo od poslednjeg viđenja čvora
  Duration getTimeSinceLastSeen() {
    return DateTime.now().difference(lastSeen);
  }

  @override
  List<Object?> get props => [id];

  @override
  bool get stringify => true;
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
