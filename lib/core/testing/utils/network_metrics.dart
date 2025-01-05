@injectable
class NetworkMetrics extends InjectableService {
  final MeshNetwork _mesh;
  final Map<String, List<Duration>> _latencies = {};

  NetworkMetrics(LoggerService logger, this._mesh) : super(logger);

  Future<Duration> measureLatency(String peerId) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Šaljemo ping poruku
      await _mesh.sendMessage(
        peerId,
        Message(type: MessageType.ping, content: 'ping'),
      );

      // Čekamo pong odgovor
      await _waitForPong(peerId);

      stopwatch.stop();
      _recordLatency(peerId, stopwatch.elapsed);

      return stopwatch.elapsed;
    } catch (e, stack) {
      logger.error('Failed to measure latency', e, stack);
      rethrow;
    }
  }

  Future<void> _waitForPong(String peerId) async {
    await _mesh.messageStream
        .where((msg) => msg.type == MessageType.pong && msg.senderId == peerId)
        .timeout(
          Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('Pong timeout'),
        )
        .first;
  }

  void _recordLatency(String peerId, Duration latency) {
    _latencies.putIfAbsent(peerId, () => []).add(latency);
  }

  double getAverageLatency(String peerId) {
    final peerLatencies = _latencies[peerId];
    if (peerLatencies == null || peerLatencies.isEmpty) return 0.0;

    final totalMs = peerLatencies.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );

    return totalMs / peerLatencies.length;
  }

  void resetMetrics() {
    _latencies.clear();
  }
}
