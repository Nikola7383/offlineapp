import 'dart:async';
import '../models/node.dart';
import '../models/node_stats.dart';
import '../models/route_info.dart';
import '../prioritization/node_priority.dart';

/// Upravlja balansiranjem opterećenja u mesh mreži
class LoadBalancer {
  // Mapa trenutnog opterećenja po čvoru
  final Map<String, double> _nodeLoads = {};

  // Statistike čvorova
  final Map<String, NodeStats> _nodeStats = {};

  // Prioriteti čvorova
  final Map<String, NodePriority> _nodePriorities = {};

  // Stream controller za promene opterećenja
  final _loadController = StreamController<LoadChangeEvent>.broadcast();

  // Konstante
  static const double MAX_LOAD = 1.0;
  static const double LOAD_THRESHOLD = 0.8;
  static const double CRITICAL_LOAD = 0.9;
  static const Duration STATS_EXPIRY = Duration(minutes: 5);
  static const int MAX_REDISTRIBUTION_ATTEMPTS = 3;

  Stream<LoadChangeEvent> get loadStream => _loadController.stream;

  /// Ažurira opterećenje čvora
  void updateNodeLoad(String nodeId, double load) {
    if (load < 0.0 || load > MAX_LOAD) {
      throw ArgumentError('Opterećenje mora biti između 0.0 i 1.0');
    }

    final oldLoad = _nodeLoads[nodeId];
    _nodeLoads[nodeId] = load;

    _loadController.add(LoadChangeEvent(
      nodeId: nodeId,
      oldLoad: oldLoad ?? 0.0,
      newLoad: load,
      timestamp: DateTime.now(),
    ));

    // Proveri da li je potrebna redistribucija
    if (_needsRedistribution(nodeId, load)) {
      _redistributeLoad(nodeId);
    }
  }

  /// Ažurira statistike čvora
  void updateNodeStats(String nodeId, NodeStats stats) {
    _nodeStats[nodeId] = stats;
    _updateNodePriority(nodeId);
  }

  /// Ažurira prioritet čvora
  void _updateNodePriority(String nodeId) {
    final stats = _nodeStats[nodeId];
    if (stats == null) return;

    final load = _nodeLoads[nodeId] ?? 0.0;
    final priority = NodePriority.calculate(
      load: load,
      reliability: stats.reliability,
      errorRate: stats.errorRate,
      batteryLevel: stats.batteryLevel,
      uptime: stats.uptime,
    );

    _nodePriorities[nodeId] = priority;
  }

  /// Vraća trenutno opterećenje čvora
  double getNodeLoad(String nodeId) => _nodeLoads[nodeId] ?? 0.0;

  /// Vraća statistike čvora
  NodeStats? getNodeStats(String nodeId) => _nodeStats[nodeId];

  /// Vraća prioritet čvora
  NodePriority? getNodePriority(String nodeId) => _nodePriorities[nodeId];

  /// Bira najbolji čvor za novu konekciju
  String? selectBestNode(List<Node> availableNodes) {
    if (availableNodes.isEmpty) return null;

    // Filtriraj preopterećene čvorove
    final eligibleNodes = availableNodes.where((node) {
      final load = _nodeLoads[node.id] ?? 0.0;
      final priority = _nodePriorities[node.id];
      return load < LOAD_THRESHOLD &&
          node.isActive &&
          (priority?.canAcceptConnections ?? true);
    }).toList();

    if (eligibleNodes.isEmpty) return null;

    // Sortiraj po kompozitnom skoru
    eligibleNodes.sort((a, b) {
      final scoreA = _calculateNodeScore(a);
      final scoreB = _calculateNodeScore(b);
      return scoreB.compareTo(scoreA); // Veći skor je bolji
    });

    return eligibleNodes.first.id;
  }

  /// Redistribuira opterećenje sa preopterećenog čvora
  void _redistributeLoad(String nodeId) {
    final currentLoad = _nodeLoads[nodeId] ?? 0.0;
    if (currentLoad <= LOAD_THRESHOLD) return;

    final excessLoad = currentLoad - LOAD_THRESHOLD;
    final stats = _nodeStats[nodeId];
    if (stats == null) return;

    // Pronađi aktivne konekcije koje se mogu premestiti
    final connections = stats.activeConnections;
    if (connections.isEmpty) return;

    // Sortiraj konekcije po prioritetu (manje bitne prve)
    connections.sort((a, b) => a.priority.compareTo(b.priority));

    var remainingLoadToRedistribute = excessLoad;
    var redistributionAttempts = 0;

    while (remainingLoadToRedistribute > 0 &&
        redistributionAttempts < MAX_REDISTRIBUTION_ATTEMPTS) {
      // Pronađi čvorove koji mogu prihvatiti dodatno opterećenje
      final availableNodes = _findAvailableNodes(nodeId);
      if (availableNodes.isEmpty) break;

      // Izračunaj koliko opterećenja svaki čvor može prihvatiti
      final nodeCapacities = <String, double>{};
      for (final node in availableNodes) {
        final currentLoad = _nodeLoads[node] ?? 0.0;
        final availableCapacity = LOAD_THRESHOLD - currentLoad;
        if (availableCapacity > 0) {
          nodeCapacities[node] = availableCapacity;
        }
      }

      if (nodeCapacities.isEmpty) break;

      // Redistribuiraj konekcije
      for (final connection in connections) {
        if (remainingLoadToRedistribute <= 0) break;

        final targetNode = _selectBestNodeForRedistribution(nodeCapacities);
        if (targetNode == null) break;

        // Premesti konekciju
        final loadPerConnection = connection.load;
        if (loadPerConnection <= nodeCapacities[targetNode]!) {
          _moveConnection(connection, nodeId, targetNode);
          remainingLoadToRedistribute -= loadPerConnection;
          nodeCapacities[targetNode] =
              nodeCapacities[targetNode]! - loadPerConnection;
        }
      }

      redistributionAttempts++;
    }

    // Ako je i dalje preopterećen, označi čvor kao kritičan
    if (remainingLoadToRedistribute > 0) {
      _handleCriticalLoad(nodeId);
    }
  }

  /// Pronalazi čvorove koji mogu prihvatiti dodatno opterećenje
  List<String> _findAvailableNodes(String excludeNodeId) {
    return _nodeLoads.entries
        .where((entry) =>
            entry.key != excludeNodeId &&
            entry.value < LOAD_THRESHOLD &&
            (_nodePriorities[entry.key]?.canAcceptConnections ?? true))
        .map((entry) => entry.key)
        .toList();
  }

  /// Bira najbolji čvor za redistribuciju
  String? _selectBestNodeForRedistribution(Map<String, double> nodeCapacities) {
    if (nodeCapacities.isEmpty) return null;

    return nodeCapacities.entries.reduce((a, b) {
      final priorityA = _nodePriorities[a.key];
      final priorityB = _nodePriorities[b.key];

      if (priorityA == null || priorityB == null) {
        return a.value > b.value ? a : b;
      }

      final scoreA = priorityA.redistributionScore * a.value;
      final scoreB = priorityB.redistributionScore * b.value;

      return scoreA > scoreB ? a : b;
    }).key;
  }

  /// Premešta konekciju sa jednog čvora na drugi
  void _moveConnection(
      ConnectionInfo connection, String fromNode, String toNode) {
    // Ažuriraj opterećenja
    _nodeLoads[fromNode] = (_nodeLoads[fromNode] ?? 0.0) - connection.load;
    _nodeLoads[toNode] = (_nodeLoads[toNode] ?? 0.0) + connection.load;

    // Ažuriraj statistike
    final fromStats = _nodeStats[fromNode];
    final toStats = _nodeStats[toNode];

    if (fromStats != null) {
      fromStats.removeConnection(connection);
      _updateNodePriority(fromNode);
    }

    if (toStats != null) {
      toStats.addConnection(connection);
      _updateNodePriority(toNode);
    }

    // Emituj događaje
    _loadController.add(LoadChangeEvent(
      nodeId: fromNode,
      oldLoad: (_nodeLoads[fromNode] ?? 0.0) + connection.load,
      newLoad: _nodeLoads[fromNode] ?? 0.0,
      timestamp: DateTime.now(),
    ));

    _loadController.add(LoadChangeEvent(
      nodeId: toNode,
      oldLoad: (_nodeLoads[toNode] ?? 0.0) - connection.load,
      newLoad: _nodeLoads[toNode] ?? 0.0,
      timestamp: DateTime.now(),
    ));
  }

  /// Upravlja kritičnim opterećenjem čvora
  void _handleCriticalLoad(String nodeId) {
    final priority = _nodePriorities[nodeId];
    if (priority == null) return;

    // Smanji prioritet čvora
    priority.degradePriority();

    // Ako je prioritet ispod kritičnog nivoa, iniciraj hitne mere
    if (priority.level < NodePriorityLevel.low) {
      _initiateEmergencyMeasures(nodeId);
    }
  }

  /// Inicira hitne mere za kritično opterećen čvor
  void _initiateEmergencyMeasures(String nodeId) {
    // TODO: Implementirati hitne mere
    // 1. Privremeno blokiraj nove konekcije
    // 2. Pokušaj agresivniju redistribuciju
    // 3. Obavesti mrežu o problemu
  }

  /// Čisti resurse
  void dispose() {
    _loadController.close();
  }
}

/// Event za promenu opterećenja
class LoadChangeEvent {
  final String nodeId;
  final double oldLoad;
  final double newLoad;
  final DateTime timestamp;

  const LoadChangeEvent({
    required this.nodeId,
    required this.oldLoad,
    required this.newLoad,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'LoadChangeEvent(nodeId: $nodeId, oldLoad: $oldLoad, newLoad: $newLoad)';
  }
}
