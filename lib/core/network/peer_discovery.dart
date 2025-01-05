@injectable
class PeerDiscoveryManager extends InjectableService {
  final MeshRouter _router;
  final Set<String> _discoveredPeers = {};
  final _peerUpdates = StreamController<PeerUpdate>.broadcast();

  static const DISCOVERY_INTERVAL = Duration(minutes: 5);
  static const PEER_TIMEOUT = Duration(minutes: 15);

  Timer? _discoveryTimer;
  final Map<String, DateTime> _lastSeen = {};

  PeerDiscoveryManager(
    LoggerService logger,
    this._router,
  ) : super(logger);

  @override
  Future<void> initialize() async {
    await super.initialize();
    _startDiscoveryProcess();
    _startPeerMonitoring();
  }

  void _startDiscoveryProcess() {
    _discoveryTimer = Timer.periodic(
      DISCOVERY_INTERVAL,
      (_) => _performDiscovery(),
    );
  }

  Future<void> _performDiscovery() async {
    try {
      final deviceId = await DeviceInfo.deviceId;
      final discovery = DiscoveryMessage(
        senderId: deviceId,
        timestamp: DateTime.now(),
        capabilities: await _getDeviceCapabilities(),
      );

      await _broadcastDiscovery(discovery);
      _cleanupStaleNodes();
    } catch (e, stack) {
      logger.error('Discovery failed', e, stack);
    }
  }

  Future<void> handleDiscoveryResponse(
    String peerId,
    Map<String, dynamic> capabilities,
  ) async {
    _lastSeen[peerId] = DateTime.now();

    if (!_discoveredPeers.contains(peerId)) {
      _discoveredPeers.add(peerId);
      _peerUpdates.add(PeerUpdate(
        peerId: peerId,
        status: PeerStatus.discovered,
        capabilities: capabilities,
      ));
    }

    await _router.updateRoute(
      peerId,
      RoutingInfo(
        path: [await DeviceInfo.deviceId, peerId],
        reliability: 1.0,
      ),
    );
  }

  void _cleanupStaleNodes() {
    final now = DateTime.now();
    _lastSeen.removeWhere((peerId, lastSeen) {
      final isStale = now.difference(lastSeen) > PEER_TIMEOUT;
      if (isStale) {
        _discoveredPeers.remove(peerId);
        _peerUpdates.add(PeerUpdate(
          peerId: peerId,
          status: PeerStatus.lost,
        ));
      }
      return isStale;
    });
  }

  @override
  Future<void> dispose() async {
    _discoveryTimer?.cancel();
    await _peerUpdates.close();
    await super.dispose();
  }
}

enum PeerStatus { discovered, connected, disconnected, lost }

class PeerUpdate {
  final String peerId;
  final PeerStatus status;
  final Map<String, dynamic>? capabilities;

  PeerUpdate({
    required this.peerId,
    required this.status,
    this.capabilities,
  });
}
