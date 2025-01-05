class PeerMetrics {
  final int latency;
  final int messageCount;
  final DateTime lastSeen;

  PeerMetrics({
    required this.latency,
    required this.messageCount,
    required this.lastSeen,
  });

  double get score {
    final latencyScore = 1000 / (latency + 1); // niži latency = bolji score
    final messageScore = messageCount / 100; // više poruka = bolji score
    final freshnessScore =
        DateTime.now().difference(lastSeen).inMinutes < 30 ? 1.0 : 0.5;

    return (latencyScore + messageScore) * freshnessScore;
  }
}
