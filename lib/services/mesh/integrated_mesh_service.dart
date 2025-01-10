class IntegratedMeshService {
  final MeshNetworkService _mesh;
  final MessageVerificationService _verification;
  final MeshSecurityService _security;
  final MeshRecoveryService _recovery;
  final LoggerService _logger;

  // Performance optimizacije
  final _messageCache = LRUCache<String, SecureMessage>(maxSize: 1000);
  final _verificationQueue = PriorityQueue<QueuedMessage>();

  IntegratedMeshService({
    required MeshNetworkService mesh,
    required MessageVerificationService verification,
    required MeshSecurityService security,
    required MeshRecoveryService recovery,
    required LoggerService logger,
  })  : _mesh = mesh,
        _verification = verification,
        _security = security,
        _recovery = recovery,
        _logger = logger {
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      // Inicijalizuj mesh networking
      await _mesh.initialize();

      // Postavi handlere za poruke
      _mesh.onMessageReceived.listen(_handleIncomingMessage);
      _mesh.onPeerConnected.listen(_handlePeerConnection);

      // Pokreni verification queue processor
      _startVerificationQueueProcessor();
    } catch (e) {
      _logger.error('Service initialization failed: $e');
      await _recovery.handleServiceFailure();
    }
  }

  Future<void> sendMessage(Message message) async {
    try {
      // 1. Pripremi poruku za slanje
      final secureMessage =
          await _security.prepareMessageForTransmission(message);

      // 2. Cache-iraj za brži pristup
      _messageCache.put(message.id, secureMessage);

      // 3. Pošalji preko mesh mreže
      final sendResult = await _mesh.broadcastMessage(secureMessage);

      // 4. Handle rezultat
      if (!sendResult.success) {
        await _handleSendFailure(secureMessage, sendResult.error);
      }
    } catch (e) {
      _logger.error('Failed to send message: $e');
      throw MeshException('Message sending failed');
    }
  }

  Future<void> _handleIncomingMessage(SecureMessage message) async {
    try {
      // 1. Brza provera cache-a
      if (_messageCache.containsKey(message.originalMessage.id)) {
        return; // Već imamo ovu poruku
      }

      // 2. Dodaj u verification queue sa prioritetom
      _verificationQueue.add(QueuedMessage(
        message: message,
        priority: _calculateMessagePriority(message),
      ));
    } catch (e) {
      _logger.error('Message handling failed: $e');
      await _recovery.handleMessageFailure(message);
    }
  }

  void _startVerificationQueueProcessor() {
    Timer.periodic(Duration(milliseconds: 100), (_) async {
      if (_verificationQueue.isEmpty) return;

      final queuedMessage = _verificationQueue.removeFirst();
      try {
        // Verifikuj poruku
        final verificationResult =
            await _verification.verifyMessage(queuedMessage.message);

        if (verificationResult.isValid) {
          // Procesiranje verifikovane poruke
          await _processVerifiedMessage(queuedMessage.message);
        } else {
          await _handleVerificationFailure(
              queuedMessage.message, verificationResult.failureReason);
        }
      } catch (e) {
        _logger.error('Verification processing failed: $e');
      }
    });
  }

  int _calculateMessagePriority(SecureMessage message) {
    int priority = 0;

    // Prioritet baziran na tipu poruke
    if (message.originalMessage.isUrgent) priority += 100;
    if (message.originalMessage.isSystem) priority += 50;

    // Prioritet baziran na starosti
    final age = DateTime.now().difference(message.timestamp).inMinutes;
    priority += (30 - age).clamp(0, 30); // Max 30 poena za svežinu

    return priority;
  }
}
