class MeshRecoveryService {
  final DatabaseService _db;
  final MeshNetworkService _mesh;
  final SecurityService _security;
  final LoggerService _logger;

  // Recovery stanja i metrike
  final Map<String, RecoveryState> _peerRecoveryStates = {};
  final Queue<RecoveryAttempt> _recoveryQueue = Queue();
  bool _isRecovering = false;

  MeshRecoveryService({
    required DatabaseService db,
    required MeshNetworkService mesh,
    required SecurityService security,
    required LoggerService logger,
  })  : _db = db,
        _mesh = mesh,
        _security = security,
        _logger = logger {
    _initializeRecoveryMonitor();
  }

  Future<void> _initializeRecoveryMonitor() async {
    // Monitor svakih 30 sekundi
    Timer.periodic(Duration(seconds: 30), (_) => _checkNetworkHealth());
  }

  Future<void> _checkNetworkHealth() async {
    try {
      final peers = await _mesh.getActivePeers();

      for (final peer in peers) {
        if (_shouldInitiateRecovery(peer)) {
          await _initiateRecoveryForPeer(peer);
        }
      }
    } catch (e) {
      _logger.error('Health check failed: $e');
    }
  }

  Future<void> _initiateRecoveryForPeer(PeerConnection peer) async {
    if (_isRecovering) return; // Već u recovery procesu

    try {
      _isRecovering = true;

      // 1. Sačuvaj trenutno stanje
      await _saveRecoveryState(peer);

      // 2. Pokušaj rekonektovanje
      final recovered = await _attemptReconnection(peer);

      // 3. Ako je uspešno, sinhronizuj poruke
      if (recovered) {
        await _syncMessages(peer);
      } else {
        // 4. Ako nije, stavi u queue za kasnije
        _recoveryQueue.add(RecoveryAttempt(peer: peer));
      }
    } catch (e) {
      _logger.error('Recovery failed for peer ${peer.peerId}: $e');
      await _handleRecoveryFailure(peer);
    } finally {
      _isRecovering = false;
    }
  }

  Future<void> _syncMessages(PeerConnection peer) async {
    try {
      // 1. Nađi zadnju sinhronizovanu poruku
      final lastSync = await _db.getLastSyncTimestamp(peer.peerId);

      // 2. Uzmi sve nove poruke od tada
      final messages = await _db.getMessagesSince(lastSync);

      // 3. Verifikuj i enkriptuj pre slanja
      final secureMessages = await Future.wait(
          messages.map((m) => _security.prepareMessageForTransmission(m)));

      // 4. Pošalji peer-u
      await _mesh.sendBulkMessages(peer, secureMessages);

      // 5. Ažuriraj sync timestamp
      await _db.updateSyncTimestamp(peer.peerId);
    } catch (e) {
      _logger.error('Message sync failed: $e');
      throw RecoveryException('Failed to sync messages');
    }
  }

  bool _shouldInitiateRecovery(PeerConnection peer) {
    return peer.state == ConnectionState.failing ||
        peer.failedAttempts > 3 ||
        _hasRecentMessageFailures(peer);
  }

  bool _hasRecentMessageFailures(PeerConnection peer) {
    return peer.failedMessages > 5 &&
        peer.messagesSent > 0 &&
        (peer.failedMessages / peer.messagesSent) > 0.2; // 20% failure rate
  }
}
