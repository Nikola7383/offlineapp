import 'dart:async';
import 'dart:collection';
import 'package:collection/collection.dart';
import '../models/node.dart';
import '../models/route_info.dart';
import '../models/node_stats.dart';

/// Optimizuje rutiranje za velike grupe čvorova u mesh mreži
class GroupRoutingOptimizer {
  // Mapa grupa i njihovih članova
  final Map<String, Set<String>> _groups = {};

  // Keš optimalnih ruta
  final _routeCache = _LRUCache<String, List<RouteInfo>>(maxSize: 1000);

  // Mapa susednih čvorova
  final Map<String, Set<String>> _neighbors = {};

  // Stream controller za promene u rutama
  final _routeController = StreamController<RouteChangeEvent>.broadcast();

  // Konstante
  static const int MAX_GROUP_SIZE = 1000;
  static const int MAX_HOPS = 10;
  static const Duration ROUTE_CACHE_TTL = Duration(minutes: 5);

  Stream<RouteChangeEvent> get routeStream => _routeController.stream;

  /// Kreira novu grupu
  void createGroup(String groupId, Set<String> memberIds) {
    if (memberIds.length > MAX_GROUP_SIZE) {
      throw ArgumentError(
          'Grupa ne može imati više od $MAX_GROUP_SIZE članova');
    }
    _groups[groupId] = memberIds;
    _invalidateGroupRoutes(groupId);
  }

  /// Dodaje člana u grupu
  void addGroupMember(String groupId, String memberId) {
    final group = _groups[groupId];
    if (group == null) {
      throw ArgumentError('Grupa $groupId ne postoji');
    }
    if (group.length >= MAX_GROUP_SIZE) {
      throw ArgumentError('Grupa je dostigla maksimalnu veličinu');
    }

    group.add(memberId);
    _invalidateGroupRoutes(groupId);
  }

  /// Uklanja člana iz grupe
  void removeGroupMember(String groupId, String memberId) {
    final group = _groups[groupId];
    if (group != null) {
      group.remove(memberId);
      _invalidateGroupRoutes(groupId);
    }
  }

  /// Ažurira informacije o susednim čvorovima
  void updateNeighbors(String nodeId, Set<String> neighborIds) {
    _neighbors[nodeId] = neighborIds;
    // Invalidira keš za sve grupe koje sadrže ovaj čvor
    for (final entry in _groups.entries) {
      if (entry.value.contains(nodeId)) {
        _invalidateGroupRoutes(entry.key);
      }
    }
  }

  /// Računa optimalne rute za grupu
  List<RouteInfo> calculateGroupRoutes(
    String groupId,
    List<Node> availableNodes,
    Map<String, NodeStats> nodeStats,
  ) {
    final group = _groups[groupId];
    if (group == null) return [];

    // Proveri keš
    final cacheKey = _generateCacheKey(groupId, availableNodes);
    final cachedRoutes = _routeCache.get(cacheKey);
    if (cachedRoutes != null) return cachedRoutes;

    // Izračunaj nove rute
    final routes = _calculateOptimalRoutes(
      group,
      availableNodes,
      nodeStats,
    );

    // Keširaj rezultat
    _routeCache.put(cacheKey, routes);

    return routes;
  }

  /// Računa optimalne rute između članova grupe
  List<RouteInfo> _calculateOptimalRoutes(
    Set<String> members,
    List<Node> availableNodes,
    Map<String, NodeStats> nodeStats,
  ) {
    final routes = <RouteInfo>[];
    final processedPairs = <String>{};

    // Kreiraj graf susednosti
    final graph = _buildAdjacencyGraph(availableNodes);

    // Izračunaj rute između svih parova članova
    for (final source in members) {
      for (final target in members) {
        if (source == target) continue;

        final pairKey = '${source}_$target';
        if (processedPairs.contains(pairKey)) continue;
        processedPairs.add(pairKey);

        final route = _findOptimalRoute(
          source,
          target,
          graph,
          availableNodes,
          nodeStats,
        );

        if (route != null) {
          routes.add(route);
        }
      }
    }

    // Optimizuj rute za celu grupu
    return _optimizeGroupRoutes(routes, members);
  }

  /// Pronalazi optimalnu rutu između dva čvora
  RouteInfo? _findOptimalRoute(
    String sourceId,
    String targetId,
    Map<String, Set<String>> graph,
    List<Node> availableNodes,
    Map<String, NodeStats> nodeStats,
  ) {
    // Koristi modifikovani Dijkstra algoritam
    final distances = <String, double>{};
    final previous = <String, String>{};
    final unvisited = HeapPriorityQueue<String>((a, b) {
      return distances[a]!.compareTo(distances[b]!);
    });

    // Inicijalizacija
    for (final node in graph.keys) {
      distances[node] = double.infinity;
    }
    distances[sourceId] = 0;
    unvisited.add(sourceId);

    while (unvisited.isNotEmpty) {
      final current = unvisited.removeFirst();
      if (current == targetId) break;

      final neighbors = graph[current] ?? {};
      for (final neighbor in neighbors) {
        final node = availableNodes.firstWhere((n) => n.id == neighbor);
        final stats = nodeStats[neighbor];
        if (stats == null) continue;

        // Računaj težinu grane
        final weight = _calculateEdgeWeight(
          node,
          stats,
          distances[current]!,
        );

        final distance = distances[current]! + weight;
        if (distance < (distances[neighbor] ?? double.infinity)) {
          distances[neighbor] = distance;
          previous[neighbor] = current;
          unvisited.add(neighbor);
        }
      }
    }

    // Rekonstruiši putanju
    if (!previous.containsKey(targetId)) return null;

    var pathNodes = <String>[];
    var current = targetId;
    while (current != sourceId) {
      pathNodes.add(current);
      current = previous[current]!;
    }
    pathNodes.add(sourceId);
    pathNodes = pathNodes.reversed.toList();

    return RouteInfo(
      sourceId: sourceId,
      targetId: targetId,
      path: pathNodes,
      hopCount: pathNodes.length - 1,
      timestamp: DateTime.now(),
    );
  }

  /// Optimizuje rute za celu grupu
  List<RouteInfo> _optimizeGroupRoutes(
    List<RouteInfo> routes,
    Set<String> members,
  ) {
    // Pronađi zajedničke podputanje
    final commonSubpaths = _findCommonSubpaths(routes);

    // Konsoliduj rute koje dele značajne delove putanje
    final optimizedRoutes = <RouteInfo>[];
    final processedRoutes = <RouteInfo>{};

    for (final route in routes) {
      if (processedRoutes.contains(route)) continue;

      final relatedRoutes = _findRelatedRoutes(
        route,
        routes,
        commonSubpaths,
      );

      if (relatedRoutes.isEmpty) {
        optimizedRoutes.add(route);
      } else {
        final optimizedRoute = _mergeRoutes(
          [route, ...relatedRoutes],
          members,
        );
        optimizedRoutes.add(optimizedRoute);
        processedRoutes.addAll(relatedRoutes);
      }
    }

    return optimizedRoutes;
  }

  /// Pronalazi zajedničke podputanje među rutama
  Map<List<String>, List<RouteInfo>> _findCommonSubpaths(
      List<RouteInfo> routes) {
    final subpaths = <List<String>, List<RouteInfo>>{};

    for (final route in routes) {
      for (var i = 0; i < route.path.length - 1; i++) {
        for (var j = i + 2; j <= route.path.length; j++) {
          final subpath = route.path.sublist(i, j);
          if (subpath.length >= 2) {
            subpaths.putIfAbsent(subpath, () => []).add(route);
          }
        }
      }
    }

    // Filtriraj samo značajne podputanje
    return Map.fromEntries(
      subpaths.entries.where((e) => e.value.length > 1),
    );
  }

  /// Pronalazi rute koje dele značajne delove putanje
  List<RouteInfo> _findRelatedRoutes(
    RouteInfo route,
    List<RouteInfo> allRoutes,
    Map<List<String>, List<RouteInfo>> commonSubpaths,
  ) {
    final related = <RouteInfo>{};

    for (final entry in commonSubpaths.entries) {
      if (entry.value.contains(route)) {
        related.addAll(entry.value);
      }
    }

    related.remove(route);
    return related.toList();
  }

  /// Spaja povezane rute u optimizovanu rutu
  RouteInfo _mergeRoutes(
    List<RouteInfo> routes,
    Set<String> members,
  ) {
    // TODO: Implementirati naprednije spajanje ruta
    // Za sada vraća prvu rutu kao primer
    return routes.first;
  }

  /// Gradi graf susednosti za dostupne čvorove
  Map<String, Set<String>> _buildAdjacencyGraph(List<Node> nodes) {
    final graph = <String, Set<String>>{};

    for (final node in nodes) {
      if (!node.isActive) continue;

      // Koristi postojeće informacije o susedima
      final knownNeighbors = _neighbors[node.id] ?? {};
      graph[node.id] = knownNeighbors;
    }

    return graph;
  }

  /// Računa težinu grane u grafu
  double _calculateEdgeWeight(
    Node node,
    NodeStats stats,
    double currentDistance,
  ) {
    // Osnovni faktori
    const reliabilityWeight = 0.3;
    const errorRateWeight = 0.2;
    const batteryWeight = 0.2;
    const distanceWeight = 0.3;

    // Normalizovana distanca
    final normalizedDistance = currentDistance / MAX_HOPS;

    return (1.0 - stats.reliability) * reliabilityWeight +
        stats.errorRate * errorRateWeight +
        (1.0 - node.batteryLevel) * batteryWeight +
        normalizedDistance * distanceWeight;
  }

  /// Generiše ključ za keš
  String _generateCacheKey(String groupId, List<Node> nodes) {
    final nodeIds = nodes.map((n) => n.id).join('_');
    return '${groupId}_$nodeIds';
  }

  /// Invalidira keširane rute za grupu
  void _invalidateGroupRoutes(String groupId) {
    // Ukloni sve keširane rute koje sadrže ovu grupu
    _routeCache.invalidateByPrefix(groupId);

    _routeController.add(RouteChangeEvent(
      groupId: groupId,
      timestamp: DateTime.now(),
      type: RouteChangeType.invalidated,
    ));
  }

  /// Čisti resurse
  void dispose() {
    _routeController.close();
    _routeCache.clear();
    _groups.clear();
    _neighbors.clear();
  }
}

/// LRU keš za rute
class _LRUCache<K, V> {
  final int maxSize;
  final _cache = LinkedHashMap<K, _CacheEntry<V>>();

  _LRUCache({required this.maxSize});

  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    // Pomeri na kraj (najskorije korišćeno)
    _cache.remove(key);
    _cache[key] = entry;

    return entry.value;
  }

  void put(K key, V value) {
    if (_cache.length >= maxSize) {
      _cache.remove(_cache.keys.first);
    }

    _cache[key] = _CacheEntry(
      value: value,
      timestamp: DateTime.now(),
    );
  }

  void invalidateByPrefix(String prefix) {
    _cache.removeWhere((key, _) => key.toString().startsWith(prefix));
  }

  void clear() => _cache.clear();
}

/// Unos u kešu
class _CacheEntry<V> {
  final V value;
  final DateTime timestamp;

  _CacheEntry({
    required this.value,
    required this.timestamp,
  });

  bool get isExpired =>
      DateTime.now().difference(timestamp) >
      GroupRoutingOptimizer.ROUTE_CACHE_TTL;
}

/// Tip promene rute
enum RouteChangeType {
  /// Rute su invalidrane
  invalidated,

  /// Rute su ažurirane
  updated,
}

/// Event za promenu rute
class RouteChangeEvent {
  final String groupId;
  final DateTime timestamp;
  final RouteChangeType type;

  const RouteChangeEvent({
    required this.groupId,
    required this.timestamp,
    required this.type,
  });

  @override
  String toString() {
    return 'RouteChangeEvent(groupId: $groupId, type: $type)';
  }
}
