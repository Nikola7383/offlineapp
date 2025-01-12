import 'package:injectable/injectable.dart';

@injectable
class MeshRouter extends InjectableService {
  final Map<String, RoutingInfo> _routingTable = {};
  final Set<String> _activeNodes = {};
  final _routeUpdates = StreamController<RouteUpdate>.broadcast();

  static const MAX_HOPS = 5;
  static const ROUTE_TIMEOUT = Duration(minutes: 30);

  Stream<RouteUpdate> get routeUpdates => _routeUpdates.stream;

  Future<void> updateRoute(String targetId, RoutingInfo info) async {
    if (info.hops >= MAX_HOPS) {
      logger.warning('Route exceeds max hops: $targetId');
      return;
    }

    final existing = _routingTable[targetId];
    if (existing == null || info.isBetterThan(existing)) {
      _routingTable[targetId] = info;
      _routeUpdates.add(RouteUpdate(targetId, info));
    }
  }

  Future<List<String>> findOptimalRoute(String targetId) async {
    final info = _routingTable[targetId];
    if (info == null || info.isExpired) {
      await _initiateRouteDiscovery(targetId);
      throw RouteNotFoundException('No route to $targetId');
    }
    return info.path;
  }

  Future<void> _initiateRouteDiscovery(String targetId) async {
    final discovery = RouteDiscoveryMessage(
      targetId: targetId,
      initiatorId: await DeviceInfo.deviceId,
      timestamp: DateTime.now(),
    );

    // Broadcast to all active nodes
    for (final nodeId in _activeNodes) {
      try {
        await _sendDiscovery(nodeId, discovery);
      } catch (e) {
        logger.error('Failed to send discovery to $nodeId', e);
      }
    }
  }
}

class RoutingInfo {
  final List<String> path;
  final int hops;
  final DateTime lastUpdated;
  final double reliability;

  RoutingInfo({
    required this.path,
    required this.reliability,
    DateTime? lastUpdated,
  })  : hops = path.length - 1,
        lastUpdated = lastUpdated ?? DateTime.now();

  bool get isExpired => DateTime.now().difference(lastUpdated) > ROUTE_TIMEOUT;

  bool isBetterThan(RoutingInfo other) {
    if (hops < other.hops) return true;
    if (hops == other.hops) return reliability > other.reliability;
    return false;
  }
}
