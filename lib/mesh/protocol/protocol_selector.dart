class ProtocolSelector {
  final Map<Protocol, ProtocolMetrics> _metrics = {};
  final List<Protocol> _fallbackChain = [
    Protocol.wifiDirect,
    Protocol.bluetooth,
    Protocol.sound
  ];

  Protocol selectOptimalProtocol(DeviceContext context) {
    final availableProtocols = _getAvailableProtocols(context);
    if (availableProtocols.isEmpty) {
      throw NoProtocolAvailableException('No protocols available');
    }

    return availableProtocols
        .map((p) => ProtocolScore(p, _calculateScore(p, context)))
        .reduce((a, b) => a.score > b.score ? a : b)
        .protocol;
  }

  List<Protocol> _getAvailableProtocols(DeviceContext context) {
    return _fallbackChain
        .where((p) => _isProtocolAvailable(p, context))
        .toList();
  }

  bool _isProtocolAvailable(Protocol protocol, DeviceContext context) {
    switch (protocol) {
      case Protocol.wifiDirect:
        return context.hasWifi && context.signalStrength > 0.3;
      case Protocol.bluetooth:
        return context.hasBluetooth && context.batteryLevel > 0.1;
      case Protocol.sound:
        return true; // Sound is always available as last resort
    }
  }

  double _calculateScore(Protocol protocol, DeviceContext context) {
    final metrics = _metrics[protocol];
    double score = 0.0;

    // Base score from context
    score += _calculateContextScore(protocol, context);

    // Historical performance
    if (metrics != null) {
      score += metrics.successRate * 0.4;
    }

    return score;
  }

  double _calculateContextScore(Protocol protocol, DeviceContext context) {
    switch (protocol) {
      case Protocol.wifiDirect:
        return context.signalStrength * 0.6 + context.batteryLevel * 0.4;
      case Protocol.bluetooth:
        return context.batteryLevel * 0.7 + context.signalStrength * 0.3;
      case Protocol.sound:
        return 0.3; // Base score for sound (always available but less preferred)
    }
  }

  void recordProtocolResult(Protocol protocol, bool success) {
    _metrics.putIfAbsent(protocol, () => ProtocolMetrics()).addResult(success);
  }
}
