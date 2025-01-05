import 'dart:async';
import '../models/node.dart';

class RouteInfo {
  final String sourceId;
  final String targetId;
  final List<String> path;
  final int hopCount;
  final DateTime timestamp;

  RouteInfo({
    required this.sourceId,
    required this.targetId,
    required this.path,
    required this.hopCount,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  RouteInfo copyWith({List<String>? path, int? hopCount}) {
    return RouteInfo(
      sourceId: sourceId,
      targetId: targetId,
      path: path ?? this.path,
      hopCount: hopCount ?? this.hopCount,
      timestamp: timestamp,
    );
  }
}

class MeshRouter {
  // Čuva najbolje rute do svakog čvora
  final Map<String, RouteInfo> _routes = {};

  // Čuva informacije o poslednjoj komunikaciji sa čvorom
  final Map<String, DateTime> _lastSeen = {};

  // Maksimalan broj hopova pre nego što odbacimo rutu
  static const int MAX_HOPS = 5;

  // Vreme nakon kojeg smatramo rutu zastarelom
  static const Duration ROUTE_TIMEOUT = Duration(minutes: 5);

  // Dodaje ili ažurira rutu
  void updateRoute(RouteInfo route) {
    final existing = _routes[route.targetId];

    if (existing == null ||
        route.hopCount < existing.hopCount ||
        existing.timestamp.isBefore(DateTime.now().subtract(ROUTE_TIMEOUT))) {
      _routes[route.targetId] = route;
    }

    _lastSeen[route.targetId] = DateTime.now();
  }

  // Nalazi najbolju rutu do odredišta
  RouteInfo? findRoute(String sourceId, String targetId) {
    final route = _routes[targetId];
    if (route == null) return null;

    // Proveri da li je ruta zastarela
    if (route.timestamp.isBefore(DateTime.now().subtract(ROUTE_TIMEOUT))) {
      _routes.remove(targetId);
      return null;
    }

    return route;
  }

  // Ažurira rute na osnovu dostupnih čvorova
  void updateFromNodes(Set<Node> nodes) {
    final now = DateTime.now();

    // Dodaj direktne rute do svih dostupnih čvorova
    for (var node in nodes) {
      updateRoute(RouteInfo(
        sourceId: node.id,
        targetId: node.id,
        path: [node.id],
        hopCount: 1,
        timestamp: now,
      ));
    }

    // Ukloni zastarele rute
    _routes.removeWhere(
        (_, route) => route.timestamp.isBefore(now.subtract(ROUTE_TIMEOUT)));
  }

  // Generiše routing tabelu za debug
  String generateRoutingTable() {
    final buffer = StringBuffer();
    buffer.writeln('Routing Table:');
    buffer.writeln('Target\t\tHops\tPath');

    final sortedRoutes = _routes.values.toList()
      ..sort((a, b) => a.targetId.compareTo(b.targetId));

    for (var route in sortedRoutes) {
      buffer.writeln('${route.targetId}\t\t'
          '${route.hopCount}\t'
          '${route.path.join(" -> ")}');
    }

    return buffer.toString();
  }

  // Čisti sve rute
  void clear() {
    _routes.clear();
    _lastSeen.clear();
  }
}
