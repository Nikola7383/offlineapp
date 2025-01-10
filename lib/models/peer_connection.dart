class PeerConnection {
  final String peerId;
  final DateTime connectedAt;
  ConnectionState state;
  int failedAttempts;

  // Statistika za monitoring
  int messagesSent;
  int messagesReceived;
  int failedMessages;

  PeerConnection({
    required this.peerId,
  })  : connectedAt = DateTime.now(),
        state = ConnectionState.connecting,
        failedAttempts = 0,
        messagesSent = 0,
        messagesReceived = 0,
        failedMessages = 0;

  Future<void> sendMessage(Message message) async {
    try {
      // Implementacija slanja
      messagesSent++;
      state = ConnectionState.active;
      failedAttempts = 0;
    } catch (e) {
      failedMessages++;
      failedAttempts++;
      _handleFailure();
    }
  }

  void _handleFailure() {
    if (failedAttempts > 3) {
      state = ConnectionState.failing;
    }
    if (failedAttempts > 5) {
      state = ConnectionState.failed;
    }
  }
}
