class ConnectionManager extends InjectableService implements Disposable {
  final _reconnectionAttempts = <String, int>{};
  final _connectionStates = <String, ConnectionState>{};
  static const MAX_RECONNECTION_ATTEMPTS = 3;

  final StreamController<ConnectionStateChange> _stateController =
      StreamController.broadcast();

  Stream<ConnectionStateChange> get connectionStateChanges =>
      _stateController.stream;

  @override
  Future<void> initialize() async {
    await super.initialize();
    _startConnectionMonitoring();
  }

  void updateConnectionState(String peerId, ConnectionState newState) {
    final oldState = _connectionStates[peerId];
    _connectionStates[peerId] = newState;

    _stateController.add(ConnectionStateChange(
        peerId: peerId, oldState: oldState, newState: newState));

    if (newState == ConnectionState.disconnected) {
      _handleDisconnection(peerId);
    }
  }

  Future<void> _handleDisconnection(String peerId) async {
    final attempts = _reconnectionAttempts[peerId] ?? 0;
    if (attempts < MAX_RECONNECTION_ATTEMPTS) {
      _reconnectionAttempts[peerId] = attempts + 1;
      await _attemptReconnection(peerId);
    } else {
      logger.warning('Max reconnection attempts reached for peer: $peerId');
    }
  }

  Future<void> _attemptReconnection(String peerId) async {
    // Exponential backoff
    final delay = Duration(seconds: pow(2, _reconnectionAttempts[peerId] ?? 0));
    await Future.delayed(delay);
    // Attempt reconnection logic here
  }
}

enum ConnectionState { connecting, connected, disconnected, failed }

class ConnectionStateChange {
  final String peerId;
  final ConnectionState? oldState;
  final ConnectionState newState;

  ConnectionStateChange({
    required this.peerId,
    this.oldState,
    required this.newState,
  });
}
