class ProtocolPriority {
  final Map<Protocol, int> protocolScores = {
    Protocol.wifiDirect: 3,
    Protocol.bluetooth: 2,
    Protocol.sound: 1
  };

  Protocol selectProtocol(Message message, DeviceContext context) {
    final availableProtocols = getAvailableProtocols(context);
    return availableProtocols
        .sorted((a, b) => calculateScore(b) - calculateScore(a))
        .first;
  }

  int calculateScore(Protocol protocol) {
    return protocolScores[protocol]! *
        getReliabilityFactor(protocol) *
        getSpeedFactor(protocol);
  }
}
