import 'package:nearby_connections/nearby_connections.dart';

class MeshNetworkService {
  final DatabaseService _db;
  final SecurityService _security;
  final LoggerService _logger;

  // Čuvamo aktivne konekcije
  final Map<String, PeerConnection> _activePeers = {};
  // Message queue za retransmisiju
  final Queue<Message> _messageQueue = Queue();

  MeshNetworkService({
    required DatabaseService db,
    required SecurityService security,
    required LoggerService logger,
  })  : _db = db,
        _security = security,
        _logger = logger {
    _initializeP2P();
  }

  Future<void> _initializeP2P() async {
    try {
      // Inicijalizacija P2P discovery
      await _startDiscovery();
      // Inicijalizacija message queue
      await _initMessageQueue();
      // Pokretanje recovery monitora
      _startRecoveryMonitor();
    } catch (e) {
      _logger.error('P2P Init failed: $e');
      await _handleInitFailure();
    }
  }

  Future<void> broadcastMessage(Message message) async {
    try {
      // Prvo sačuvaj lokalno
      await _db.saveMessage(message);

      // Enkriptuj pre slanja
      final encryptedMessage = await _security.encryptMessage(message);

      // Pokušaj slanje svim peer-ovima
      final futures = _activePeers.values
          .map((peer) => _sendMessageToPeer(peer, encryptedMessage));

      // Čekaj rezultate i handle-uj failures
      final results = await Future.wait(futures);
      _handleSendResults(message, results);
    } catch (e) {
      _logger.error('Broadcast failed: $e');
      // Dodaj u queue za retry
      _messageQueue.add(message);
      await _handleBroadcastFailure(message);
    }
  }

  Future<void> _handleMessageReceived(Message message) async {
    try {
      // Verifikuj integritet
      if (!await _security.verifyMessage(message)) {
        _logger.warning('Message verification failed');
        return;
      }

      // Proveri da li već imamo poruku
      if (await _db.messageExists(message.id)) {
        return;
      }

      // Sačuvaj i propagiraj dalje
      await _db.saveMessage(message);
      await _propagateMessage(message);
    } catch (e) {
      _logger.error('Message handling failed: $e');
      await _handleReceiveFailure(message);
    }
  }

  // Recovery i retry mehanizmi
  Future<void> _retryFailedMessages() async {
    while (_messageQueue.isNotEmpty) {
      final message = _messageQueue.removeFirst();
      await broadcastMessage(message);
    }
  }
}
