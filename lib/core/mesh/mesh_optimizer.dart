import 'package:collection/collection.dart';
import 'peer_metrics.dart';
import '../services/logger_service.dart';

class MeshOptimizer {
  static const int MAX_PEERS = 10;
  static const Duration RECONNECT_INTERVAL = Duration(seconds: 30);

  final Map<String, PeerMetrics> _peerMetrics = {};

  void trackPeerMetrics(String peerId, int latency, int messageCount) {
    _peerMetrics[peerId] = PeerMetrics(
      latency: latency,
      messageCount: messageCount,
      lastSeen: DateTime.now(),
    );
  }

  List<String> getOptimalPeers() {
    return _peerMetrics.entries
        .toList()
        .sorted((a, b) => a.value.score.compareTo(b.value.score))
        .take(MAX_PEERS)
        .map((e) => e.key)
        .toList();
  }

  void clearOldMetrics() {
    final now = DateTime.now();
    _peerMetrics.removeWhere(
        (_, metrics) => now.difference(metrics.lastSeen) > RECONNECT_INTERVAL);
  }
}
