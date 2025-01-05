class NetworkReconnectionStrategy extends RecoveryStrategy {
  static const MAX_RETRY_ATTEMPTS = 5;
  static const BACKOFF_MULTIPLIER = 1.5;

  @override
  Future<RecoveryResult> execute(HealthIssue issue) async {
    final network = GetIt.instance<MeshNetwork>();
    var delay = Duration(seconds: 1);

    for (var attempt = 1; attempt <= MAX_RETRY_ATTEMPTS; attempt++) {
      try {
        // Disconnect from current peers
        await network.disconnectAll();

        // Wait with exponential backoff
        await Future.delayed(delay);
        delay = Duration(
            milliseconds: (delay.inMilliseconds * BACKOFF_MULTIPLIER).round());

        // Attempt reconnection
        await network.initialize();
        final connectedPeers = await network.getConnectedPeers();

        if (connectedPeers.isNotEmpty) {
          return RecoveryResult(
            successful: true,
            message: 'Network reconnection successful',
            metrics: {
              'connectedPeers': connectedPeers.length,
              'attempts': attempt,
            },
          );
        }
      } catch (e) {
        if (attempt == MAX_RETRY_ATTEMPTS) {
          return RecoveryResult(
            successful: false,
            message:
                'Network reconnection failed after $MAX_RETRY_ATTEMPTS attempts',
            metrics: {'attempts': attempt},
          );
        }
      }
    }

    return RecoveryResult(
      successful: false,
      message: 'Network reconnection failed',
    );
  }
}

class PeerDiscoveryStrategy extends RecoveryStrategy {
  @override
  Future<RecoveryResult> execute(HealthIssue issue) async {
    try {
      final network = GetIt.instance<MeshNetwork>();
      final discovery = GetIt.instance<PeerDiscoveryManager>();

      // Force new peer discovery
      await discovery.forcePeerDiscovery();

      // Wait for discovery to complete
      await Future.delayed(Duration(seconds: 10));

      final peers = await network.getConnectedPeers();

      return RecoveryResult(
        successful: peers.isNotEmpty,
        message: peers.isNotEmpty
            ? 'Discovered ${peers.length} peers'
            : 'No peers discovered',
        metrics: {
          'discoveredPeers': peers.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      return RecoveryResult(
        successful: false,
        message: 'Peer discovery failed: $e',
      );
    }
  }
}
