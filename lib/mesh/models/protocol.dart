enum Protocol { bluetooth, wifiDirect, sound }

class ProtocolScore {
  final Protocol protocol;
  final double score;

  ProtocolScore(this.protocol, this.score);
}
