import 'dart:async';
import 'dart:math';
import 'package:collection/collection.dart';
import '../models/node.dart';
import '../models/route_info.dart';
import '../models/node_stats.dart';

/// Optimizovani mesh router sa podrškom za load balancing i node prioritization
class OptimizedMeshRouter {
  // Čuva najbolje rute do svakog čvora
  final Map<String, List<RouteInfo>> _routes = {};

  // Čuva statistike za svaki čvor
  final Map<String, NodeStats> _nodeStats = {};

  // Čuva informacije o opterećenju čvorova
  final Map<String, double> _nodeLoad = {};

  // Konstante za konfiguraciju
  static const int MAX_ROUTES_PER_TARGET = 3; // Broj alternativnih ruta
  static const int MAX_HOPS = 8; // Povećan broj hopova za veće mreže
  static const Duration ROUTE_TIMEOUT = Duration(minutes: 10);
  static const Duration STATS_UPDATE_INTERVAL = Duration(seconds: 30);

  Timer? _statsUpdateTimer;

  OptimizedMeshRouter() {
    _initializeStatsUpdater();
  }

  void _initializeStatsUpdater() {
    _statsUpdateTimer?.cancel();
    _statsUpdateTimer = Timer.periodic(STATS_UPDATE_INTERVAL, (_) {
      _updateAllNodeStats();
    });
  }

  /// Dodaje ili ažurira rutu sa podrškom za više alternativnih putanja
  void updateRoute(RouteInfo route) {
    if (route.hopCount > MAX_HOPS) return;

    final routes = _routes[route.targetId] ?? [];

    // Dodaj novu rutu ili ažuriraj postojeću
    final existingIndex = routes
        .indexWhere((r) => const ListEquality().equals(r.path, route.path));

    if (existingIndex != -1) {
      routes[existingIndex] = route;
    } else {
      routes.add(route);
    }

    // Sortiraj rute po kvalitetu i zadrži najbolje
    routes.sort((a, b) =>
        _calculateRouteQuality(a).compareTo(_calculateRouteQuality(b)));
    _routes[route.targetId] = routes.take(MAX_ROUTES_PER_TARGET).toList();

    // Ažuriraj statistike čvorova
    for (var nodeId in route.path) {
      _updateNodeStats(
          nodeId: nodeId, routeQuality: _calculateRouteQuality(route));
    }
  }

  /// Pronalazi najbolju rutu na osnovu više faktora
  RouteInfo? findRoute(String sourceId, String targetId) {
    final routes = _routes[targetId];
    if (routes == null || routes.isEmpty) return null;

    // Filtriraj zastarele rute
    final validRoutes = routes
        .where((r) =>
            !r.timestamp.isBefore(DateTime.now().subtract(ROUTE_TIMEOUT)))
        .toList();

    if (validRoutes.isEmpty) {
      _routes.remove(targetId);
      return null;
    }

    // Izaberi najbolju rutu uzimajući u obzir load balancing
    return _selectBestRoute(validRoutes);
  }

  /// Ažurira rute i statistike na osnovu dostupnih čvorova
  void updateFromNodes(Set<Node> nodes) {
    final now = DateTime.now();

    // Dodaj direktne rute
    for (var node in nodes) {
      final route = RouteInfo(
        sourceId: node.id,
        targetId: node.id,
        path: [node.id],
        hopCount: 1,
        timestamp: now,
        nodeType: node.type,
        batteryLevel: node.batteryLevel,
      );
      updateRoute(route);
    }

    // Ažuriraj statistike čvorova
    for (var node in nodes) {
      _updateNodeLoad(node.id, node.currentLoad);
    }

    _cleanupStaleRoutes();
  }

  /// Računa kvalitet rute na osnovu više faktora
  double _calculateRouteQuality(RouteInfo route) {
    double quality = 100.0;

    // Faktor broja hopova
    quality -= (route.hopCount * 10);

    // Faktor tipa čvorova na putu
    for (var nodeId in route.path) {
      final stats = _nodeStats[nodeId];
      if (stats != null) {
        quality += stats.reliability * 10;
        quality -= stats.errorRate * 20;
        quality += stats.batteryLevel * 5;
      }
    }

    // Faktor opterećenja čvorova
    double avgLoad = 0.0;
    int loadCount = 0;
    for (var nodeId in route.path) {
      final load = _nodeLoad[nodeId];
      if (load != null) {
        avgLoad += load;
        loadCount++;
      }
    }
    if (loadCount > 0) {
      avgLoad /= loadCount;
      quality -= (avgLoad * 30); // Veći uticaj opterećenja
    }

    return quality;
  }

  /// Bira najbolju rutu uzimajući u obzir load balancing
  RouteInfo _selectBestRoute(List<RouteInfo> routes) {
    // Koristi weighted random selection za load balancing
    final totalQuality = routes.fold<double>(
        0.0, (sum, route) => sum + _calculateRouteQuality(route));

    double random = Random().nextDouble() * totalQuality;

    for (var route in routes) {
      random -= _calculateRouteQuality(route);
      if (random <= 0) return route;
    }

    return routes.first;
  }

  /// Ažurira statistike čvora
  void _updateNodeStats({
    required String nodeId,
    double? routeQuality,
    bool hadError = false,
  }) {
    final stats = _nodeStats[nodeId] ?? NodeStats(nodeId: nodeId);

    if (routeQuality != null) {
      stats.updateReliability(routeQuality);
    }

    if (hadError) {
      stats.incrementErrors();
    }

    _nodeStats[nodeId] = stats;
  }

  /// Ažurira informacije o opterećenju čvora
  void _updateNodeLoad(String nodeId, double load) {
    _nodeLoad[nodeId] = load;
  }

  /// Periodično ažuriranje statistika
  void _updateAllNodeStats() {
    final now = DateTime.now();

    // Ažuriraj statistike za sve čvorove
    for (var nodeId in _nodeStats.keys) {
      final stats = _nodeStats[nodeId]!;
      stats.updateTimestamp(now);

      // Resetuj statistike ako je čvor neaktivan duže vreme
      if (stats.lastUpdate.isBefore(now.subtract(ROUTE_TIMEOUT))) {
        stats.reset();
      }
    }
  }

  /// Čisti zastarele rute
  void _cleanupStaleRoutes() {
    final now = DateTime.now();
    _routes.removeWhere((_, routes) => routes.every(
        (route) => route.timestamp.isBefore(now.subtract(ROUTE_TIMEOUT))));
  }

  /// Čisti sve rute i statistike
  void dispose() {
    _statsUpdateTimer?.cancel();
    _routes.clear();
    _nodeStats.clear();
    _nodeLoad.clear();
  }

  /// Generiše detaljni izveštaj o stanju mreže
  String generateNetworkReport() {
    final buffer = StringBuffer();
    buffer.writeln('Network Status Report:');
    buffer.writeln('======================');

    // Rute
    buffer.writeln('\nRouting Table:');
    buffer.writeln('Target\t\tHops\tQuality\tPath');

    final sortedRoutes = _routes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (var entry in sortedRoutes) {
      for (var route in entry.value) {
        buffer.writeln('${route.targetId}\t\t'
            '${route.hopCount}\t'
            '${_calculateRouteQuality(route).toStringAsFixed(2)}\t'
            '${route.path.join(" -> ")}');
      }
    }

    // Statistike čvorova
    buffer.writeln('\nNode Statistics:');
    buffer.writeln('Node ID\t\tReliability\tError Rate\tLoad');

    final sortedStats = _nodeStats.values.toList()
      ..sort((a, b) => a.nodeId.compareTo(b.nodeId));

    for (var stats in sortedStats) {
      buffer.writeln('${stats.nodeId}\t\t'
          '${stats.reliability.toStringAsFixed(2)}\t\t'
          '${stats.errorRate.toStringAsFixed(2)}\t\t'
          '${_nodeLoad[stats.nodeId]?.toStringAsFixed(2) ?? "N/A"}');
    }

    return buffer.toString();
  }
}
