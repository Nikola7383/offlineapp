/// Status konekcije
enum ConnectionStatus {
  /// Konekcija je aktivna
  active,

  /// Konekcija je u procesu uspostavljanja
  connecting,

  /// Konekcija je prekinuta
  disconnected,

  /// Konekcija je pauzirana
  paused,

  /// Konekcija je u procesu gašenja
  shuttingDown
}

/// Informacije o konekciji između čvorova
class ConnectionInfo {
  /// ID izvornog čvora
  final String sourceNodeId;

  /// ID ciljnog čvora
  final String targetNodeId;

  /// Vreme uspostavljanja konekcije
  final DateTime establishedAt;

  /// Trenutni status konekcije
  final ConnectionStatus status;

  /// Jačina signala (0.0 - 1.0)
  final double signalStrength;

  /// Latencija u milisekundama
  final int latencyMs;

  /// Broj poslatih paketa
  final int packetsSent;

  /// Broj primljenih paketa
  final int packetsReceived;

  /// Broj izgubljenih paketa
  final int packetsLost;

  /// Prosečna veličina paketa u bajtovima
  final int avgPacketSize;

  /// Tip enkripcije koji se koristi
  final String encryptionType;

  /// Verzija protokola
  final String protocolVersion;

  const ConnectionInfo({
    required this.sourceNodeId,
    required this.targetNodeId,
    required this.establishedAt,
    required this.status,
    required this.signalStrength,
    required this.latencyMs,
    required this.packetsSent,
    required this.packetsReceived,
    required this.packetsLost,
    required this.avgPacketSize,
    required this.encryptionType,
    required this.protocolVersion,
  });

  /// Kreira kopiju sa ažuriranim vrednostima
  ConnectionInfo copyWith({
    String? sourceNodeId,
    String? targetNodeId,
    DateTime? establishedAt,
    ConnectionStatus? status,
    double? signalStrength,
    int? latencyMs,
    int? packetsSent,
    int? packetsReceived,
    int? packetsLost,
    int? avgPacketSize,
    String? encryptionType,
    String? protocolVersion,
  }) {
    return ConnectionInfo(
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      establishedAt: establishedAt ?? this.establishedAt,
      status: status ?? this.status,
      signalStrength: signalStrength ?? this.signalStrength,
      latencyMs: latencyMs ?? this.latencyMs,
      packetsSent: packetsSent ?? this.packetsSent,
      packetsReceived: packetsReceived ?? this.packetsReceived,
      packetsLost: packetsLost ?? this.packetsLost,
      avgPacketSize: avgPacketSize ?? this.avgPacketSize,
      encryptionType: encryptionType ?? this.encryptionType,
      protocolVersion: protocolVersion ?? this.protocolVersion,
    );
  }

  /// Računa kvalitet konekcije (0.0 - 1.0)
  double get quality {
    final packetLossRate = packetsLost / (packetsSent + 0.1);
    final normalizedLatency = latencyMs / 1000.0;

    return (signalStrength * 0.4 +
            (1 - packetLossRate) * 0.4 +
            (1 - normalizedLatency.clamp(0.0, 1.0)) * 0.2)
        .clamp(0.0, 1.0);
  }

  /// Proverava da li je konekcija stabilna
  bool get isStable =>
      status == ConnectionStatus.active &&
      quality > 0.7 &&
      signalStrength > 0.6;

  @override
  String toString() {
    return 'ConnectionInfo('
        'source: $sourceNodeId, '
        'target: $targetNodeId, '
        'status: $status, '
        'quality: ${quality.toStringAsFixed(2)})';
  }
}
