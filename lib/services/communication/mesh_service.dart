class MeshService {
  final MeshNetwork _network;
  final SecurityService _security;
  final LoggerService _logger;

  MeshService({
    required MeshNetwork network,
    required SecurityService security,
    required LoggerService logger,
  })  : _network = network,
        _security = security,
        _logger = logger;

  Future<void> initialize(
      {required MeshConfig config,
      required Function onNetworkReady,
      required Function onError}) async {
    try {
      // Inicijalizuj mrežu
      await _network.initialize(
          capacity: config.nodeCapacity, secure: config.secureRouting);

      // Postavi auto-reconnect
      if (config.autoReconnect) {
        await _enableAutoReconnect();
      }

      // Započni node discovery
      await _startNodeDiscovery();
    } catch (e) {
      _logger.error('Mesh inicijalizacija nije uspela: $e');
      onError(e);
    }
  }

  Future<bool> broadcast(EncryptedMessage message,
      {required Priority priority, required bool redundancy}) async {
    try {
      // Proveri mrežni status
      if (!await _network.isReady) {
        await _rebuildNetwork();
      }

      // Pripremi poruku za broadcast
      final meshMessage =
          await _prepareMeshMessage(message, priority: priority);

      // Pošalji broadcast
      final success =
          await _network.broadcast(meshMessage, withRedundancy: redundancy);

      return success;
    } catch (e) {
      _logger.error('Mesh broadcast nije uspeo: $e');
      return false;
    }
  }
}
