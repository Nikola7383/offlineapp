import 'dart:async';
import '../models/node.dart';
import '../models/node_stats.dart';
import '../models/message_priority.dart';

/// Upravlja prioritetima čvorova i poruka u mesh mreži
class NodePrioritizer {
  // Mapa prioriteta čvorova
  final Map<String, double> _nodePriorities = {};

  // Mapa redova čekanja po prioritetu
  final Map<MessagePriority, List<QueuedMessage>> _messageQueues = {
    MessagePriority.critical: [],
    MessagePriority.high: [],
    MessagePriority.medium: [],
    MessagePriority.low: [],
  };

  // Stream controller za promene prioriteta
  final _priorityController = StreamController<PriorityChangeEvent>.broadcast();

  // Konstante
  static const double BASE_PRIORITY = 0.5;
  static const double MAX_PRIORITY = 1.0;
  static const Duration QUEUE_TIMEOUT = Duration(minutes: 5);

  Stream<PriorityChangeEvent> get priorityStream => _priorityController.stream;

  /// Ažurira prioritet čvora
  void updateNodePriority(String nodeId, Node node, NodeStats stats) {
    final oldPriority = _nodePriorities[nodeId] ?? BASE_PRIORITY;
    final newPriority = _calculateNodePriority(node, stats);

    _nodePriorities[nodeId] = newPriority;

    _priorityController.add(PriorityChangeEvent(
      nodeId: nodeId,
      oldPriority: oldPriority,
      newPriority: newPriority,
      timestamp: DateTime.now(),
    ));

    _rebalanceQueues();
  }

  /// Dodaje poruku u red čekanja
  void enqueueMessage(QueuedMessage message) {
    final queue = _messageQueues[message.priority]!;
    queue.add(message);

    // Sortiraj red po prioritetu i vremenu
    queue.sort((a, b) {
      final priorityCompare = b.priority.index.compareTo(a.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      return a.timestamp.compareTo(b.timestamp);
    });

    _cleanupExpiredMessages();
  }

  /// Uzima sledeću poruku iz reda
  QueuedMessage? dequeueNextMessage(String nodeId) {
    // Prvo proveri kritične poruke
    for (final priority in MessagePriority.values) {
      final queue = _messageQueues[priority]!;
      final index = queue
          .indexWhere((msg) => msg.targetNodeId == nodeId && !msg.isExpired);

      if (index != -1) {
        return queue.removeAt(index);
      }
    }
    return null;
  }

  /// Vraća trenutni prioritet čvora
  double getNodePriority(String nodeId) =>
      _nodePriorities[nodeId] ?? BASE_PRIORITY;

  /// Vraća broj poruka u redu za čvor
  int getQueuedMessageCount(String nodeId) {
    return _messageQueues.values
        .expand((queue) => queue)
        .where((msg) => msg.targetNodeId == nodeId && !msg.isExpired)
        .length;
  }

  /// Računa prioritet čvora na osnovu njegovih karakteristika
  double _calculateNodePriority(Node node, NodeStats stats) {
    var priority = BASE_PRIORITY;

    // Faktori za računanje prioriteta
    const typeWeight = 0.3;
    const reliabilityWeight = 0.2;
    const batteryWeight = 0.15;
    const errorRateWeight = 0.15;
    const successRateWeight = 0.2;

    // Tip čvora
    switch (node.type) {
      case NodeType.superNode:
        priority += 0.3 * typeWeight;
        break;
      case NodeType.edge:
        priority += 0.2 * typeWeight;
        break;
      case NodeType.regular:
        priority += 0.1 * typeWeight;
        break;
      case NodeType.relay:
        // Relay čvorovi imaju najniži prioritet
        break;
    }

    // Pouzdanost
    priority += stats.reliability * reliabilityWeight;

    // Nivo baterije
    priority += node.batteryLevel * batteryWeight;

    // Stopa grešaka (inverzno)
    priority += (1.0 - stats.errorRate) * errorRateWeight;

    // Stopa uspešnosti
    priority += stats.successRate * successRateWeight;

    return priority.clamp(0.0, MAX_PRIORITY);
  }

  /// Rebalansira redove čekanja nakon promene prioriteta
  void _rebalanceQueues() {
    for (final queue in _messageQueues.values) {
      queue.sort((a, b) {
        final aPriority = _nodePriorities[a.targetNodeId] ?? BASE_PRIORITY;
        final bPriority = _nodePriorities[b.targetNodeId] ?? BASE_PRIORITY;
        final priorityCompare = bPriority.compareTo(aPriority);
        if (priorityCompare != 0) return priorityCompare;
        return a.timestamp.compareTo(b.timestamp);
      });
    }
  }

  /// Čisti istekle poruke iz redova
  void _cleanupExpiredMessages() {
    for (final queue in _messageQueues.values) {
      queue.removeWhere((msg) => msg.isExpired);
    }
  }

  /// Čisti resurse
  void dispose() {
    _priorityController.close();
    _messageQueues.clear();
    _nodePriorities.clear();
  }
}

/// Event za promenu prioriteta
class PriorityChangeEvent {
  final String nodeId;
  final double oldPriority;
  final double newPriority;
  final DateTime timestamp;

  const PriorityChangeEvent({
    required this.nodeId,
    required this.oldPriority,
    required this.newPriority,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'PriorityChangeEvent(nodeId: $nodeId, oldPriority: $oldPriority, newPriority: $newPriority)';
  }
}

/// Poruka u redu čekanja
class QueuedMessage {
  final String id;
  final String targetNodeId;
  final MessagePriority priority;
  final DateTime timestamp;
  final Duration timeout;
  final dynamic payload;

  const QueuedMessage({
    required this.id,
    required this.targetNodeId,
    required this.priority,
    required this.timestamp,
    this.timeout = const Duration(minutes: 5),
    required this.payload,
  });

  /// Proverava da li je poruka istekla
  bool get isExpired => DateTime.now().difference(timestamp) > timeout;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueuedMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QueuedMessage(id: $id, target: $targetNodeId, priority: $priority)';
  }
}
