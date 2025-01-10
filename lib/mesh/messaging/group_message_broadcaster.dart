import 'dart:async';
import '../models/message_priority.dart';
import '../models/route_info.dart';
import '../models/node.dart';
import '../routing/group_routing_optimizer.dart';

/// Upravlja slanjem poruka u grupama
class GroupMessageBroadcaster {
  final GroupRoutingOptimizer _routingOptimizer;

  // Mapa aktivnih broadcast sesija
  final Map<String, BroadcastSession> _activeSessions = {};

  // Stream controller za status isporuke
  final _deliveryController = StreamController<DeliveryStatus>.broadcast();

  // Konstante
  static const Duration SESSION_TIMEOUT = Duration(minutes: 15);
  static const int MAX_RETRY_COUNT = 3;
  static const Duration RETRY_DELAY = Duration(seconds: 5);

  Stream<DeliveryStatus> get deliveryStream => _deliveryController.stream;

  GroupMessageBroadcaster({
    required GroupRoutingOptimizer routingOptimizer,
  }) : _routingOptimizer = routingOptimizer;

  /// Šalje poruku grupi
  Future<void> broadcastMessage(
    String groupId,
    BroadcastMessage message,
    List<Node> availableNodes,
  ) async {
    // Kreiraj novu broadcast sesiju
    final sessionId = '${groupId}_${DateTime.now().millisecondsSinceEpoch}';
    final session = BroadcastSession(
      id: sessionId,
      groupId: groupId,
      message: message,
      timestamp: DateTime.now(),
    );
    _activeSessions[sessionId] = session;

    try {
      // Izračunaj optimalne rute
      final routes = _routingOptimizer.calculateGroupRoutes(
        groupId,
        availableNodes,
        {}, // TODO: Dodati node stats
      );

      if (routes.isEmpty) {
        _deliveryController.add(DeliveryStatus(
          sessionId: sessionId,
          status: DeliveryState.failed,
          error: 'Nema dostupnih ruta',
        ));
        return;
      }

      // Optimizuj redosled slanja
      final optimizedRoutes = _optimizeDeliveryOrder(routes, message);

      // Podeli rute u grupe za paralelno slanje
      final routeGroups = _groupRoutesForParallelDelivery(optimizedRoutes);

      // Pošalji poruke po grupama
      for (final group in routeGroups) {
        await _deliverToRouteGroup(session, group);
      }

      // Proveri status isporuke
      final undelivered = session.getUndeliveredNodes();
      if (undelivered.isEmpty) {
        _deliveryController.add(DeliveryStatus(
          sessionId: sessionId,
          status: DeliveryState.completed,
        ));
      } else {
        // Pokušaj ponovno slanje za neisporučene
        await _retryUndelivered(session, undelivered, availableNodes);
      }
    } catch (e) {
      _deliveryController.add(DeliveryStatus(
        sessionId: sessionId,
        status: DeliveryState.failed,
        error: e.toString(),
      ));
    } finally {
      // Očisti sesiju nakon isteka
      Timer(SESSION_TIMEOUT, () {
        _activeSessions.remove(sessionId);
      });
    }
  }

  /// Optimizuje redosled isporuke poruka
  List<RouteInfo> _optimizeDeliveryOrder(
    List<RouteInfo> routes,
    BroadcastMessage message,
  ) {
    final prioritizedRoutes = List<RouteInfo>.from(routes);

    // Sortiraj rute po prioritetu
    prioritizedRoutes.sort((a, b) {
      // Prvo po prioritetu poruke
      if (message.priority == MessagePriority.critical) {
        return -1;
      }

      // Zatim po broju hopova (kraće rute imaju prednost)
      final hopCompare = a.hopCount.compareTo(b.hopCount);
      if (hopCompare != 0) return hopCompare;

      // Na kraju po pouzdanosti rute
      final reliabilityA = a.reliability ?? 0.0;
      final reliabilityB = b.reliability ?? 0.0;
      return reliabilityB.compareTo(reliabilityA);
    });

    return prioritizedRoutes;
  }

  /// Grupiše rute za paralelno slanje
  List<List<RouteInfo>> _groupRoutesForParallelDelivery(
      List<RouteInfo> routes) {
    final groups = <List<RouteInfo>>[];
    final usedNodes = <String>{};
    var currentGroup = <RouteInfo>[];

    for (final route in routes) {
      // Proveri da li ruta deli čvorove sa trenutnom grupom
      final routeNodes = route.path.toSet();
      if (routeNodes.intersection(usedNodes).isEmpty) {
        // Ruta je nezavisna, dodaj je u trenutnu grupu
        currentGroup.add(route);
        usedNodes.addAll(routeNodes);
      } else {
        // Ruta deli čvorove, započni novu grupu
        if (currentGroup.isNotEmpty) {
          groups.add(currentGroup);
          currentGroup = <RouteInfo>[];
          usedNodes.clear();
        }
        currentGroup.add(route);
        usedNodes.addAll(routeNodes);
      }
    }

    if (currentGroup.isNotEmpty) {
      groups.add(currentGroup);
    }

    return groups;
  }

  /// Isporučuje poruke za grupu ruta
  Future<void> _deliverToRouteGroup(
    BroadcastSession session,
    List<RouteInfo> routes,
  ) async {
    final deliveryFutures =
        routes.map((route) => _deliverMessageViaRoute(session, route));

    await Future.wait(deliveryFutures);
  }

  /// Isporučuje poruku preko određene rute
  Future<void> _deliverMessageViaRoute(
    BroadcastSession session,
    RouteInfo route,
  ) async {
    try {
      // TODO: Implementirati stvarno slanje poruke
      // Za sada samo simuliramo slanje
      await Future.delayed(Duration(milliseconds: 100 * route.hopCount));

      session.markDelivered(route.targetId);

      _deliveryController.add(DeliveryStatus(
        sessionId: session.id,
        status: DeliveryState.inProgress,
        deliveredNode: route.targetId,
      ));
    } catch (e) {
      session.markFailed(route.targetId, e.toString());
    }
  }

  /// Pokušava ponovno slanje neisporučenih poruka
  Future<void> _retryUndelivered(
    BroadcastSession session,
    Set<String> undeliveredNodes,
    List<Node> availableNodes,
  ) async {
    var retryCount = 0;
    var remainingNodes = undeliveredNodes;

    while (retryCount < MAX_RETRY_COUNT && remainingNodes.isNotEmpty) {
      await Future.delayed(RETRY_DELAY);

      // Izračunaj nove rute samo za neisporučene čvorove
      final retryRoutes = _routingOptimizer
          .calculateGroupRoutes(
            session.groupId,
            availableNodes,
            {}, // TODO: Dodati node stats
          )
          .where((r) => remainingNodes.contains(r.targetId))
          .toList();

      // Pokušaj ponovno slanje
      for (final route in retryRoutes) {
        await _deliverMessageViaRoute(session, route);
      }

      // Ažuriraj preostale čvorove
      remainingNodes = session.getUndeliveredNodes();
      retryCount++;
    }

    // Finalni status
    _deliveryController.add(DeliveryStatus(
      sessionId: session.id,
      status: remainingNodes.isEmpty
          ? DeliveryState.completed
          : DeliveryState.partiallyDelivered,
      undeliveredNodes: remainingNodes,
    ));
  }

  /// Čisti resurse
  void dispose() {
    _deliveryController.close();
    _activeSessions.clear();
  }
}

/// Sesija za broadcast poruke
class BroadcastSession {
  final String id;
  final String groupId;
  final BroadcastMessage message;
  final DateTime timestamp;
  final Map<String, DeliveryAttempt> _deliveryStatus = {};

  BroadcastSession({
    required this.id,
    required this.groupId,
    required this.message,
    required this.timestamp,
  });

  /// Označava čvor kao uspešno isporučen
  void markDelivered(String nodeId) {
    _deliveryStatus[nodeId] = DeliveryAttempt(
      status: DeliveryState.completed,
      timestamp: DateTime.now(),
    );
  }

  /// Označava čvor kao neuspešno isporučen
  void markFailed(String nodeId, String error) {
    _deliveryStatus[nodeId] = DeliveryAttempt(
      status: DeliveryState.failed,
      timestamp: DateTime.now(),
      error: error,
    );
  }

  /// Vraća set neisporučenih čvorova
  Set<String> getUndeliveredNodes() {
    return _deliveryStatus.entries
        .where((e) => e.value.status != DeliveryState.completed)
        .map((e) => e.key)
        .toSet();
  }
}

/// Pokušaj isporuke
class DeliveryAttempt {
  final DeliveryState status;
  final DateTime timestamp;
  final String? error;

  const DeliveryAttempt({
    required this.status,
    required this.timestamp,
    this.error,
  });
}

/// Status isporuke
class DeliveryStatus {
  final String sessionId;
  final DeliveryState status;
  final String? deliveredNode;
  final Set<String>? undeliveredNodes;
  final String? error;

  const DeliveryStatus({
    required this.sessionId,
    required this.status,
    this.deliveredNode,
    this.undeliveredNodes,
    this.error,
  });

  @override
  String toString() {
    return 'DeliveryStatus(sessionId: $sessionId, status: $status, '
        'delivered: $deliveredNode, undelivered: $undeliveredNodes)';
  }
}

/// Stanje isporuke
enum DeliveryState {
  /// U toku
  inProgress,

  /// Uspešno završeno
  completed,

  /// Delimično isporučeno
  partiallyDelivered,

  /// Neuspešno
  failed,
}

/// Broadcast poruka
class BroadcastMessage {
  final String id;
  final MessagePriority priority;
  final dynamic payload;
  final Map<String, dynamic>? metadata;

  const BroadcastMessage({
    required this.id,
    required this.priority,
    required this.payload,
    this.metadata,
  });
}
