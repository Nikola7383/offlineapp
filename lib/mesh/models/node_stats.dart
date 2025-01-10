import 'connection_info.dart';

/// Statistike čvora u mreži
class NodeStats {
  /// ID čvora
  final String nodeId;

  /// Nivo pouzdanosti čvora (0.0 - 1.0)
  final double reliability;

  /// Stopa grešaka (0.0 - 1.0)
  final double errorRate;

  /// Nivo baterije (0.0 - 1.0)
  final double batteryLevel;

  /// Iskorišćenost procesora (0.0 - 1.0)
  final double cpuUsage;

  /// Iskorišćenost memorije (0.0 - 1.0)
  final double memoryUsage;

  /// Iskorišćenost skladišta (0.0 - 1.0)
  final double storageUsage;

  /// Aktivne konekcije
  final List<ConnectionInfo> activeConnections;

  /// Broj uspešnih transakcija
  final int successfulTransactions;

  /// Broj neuspešnih transakcija
  final int failedTransactions;

  /// Prosečno vreme odziva u milisekundama
  final int avgResponseTimeMs;

  /// Vreme poslednjeg ažuriranja
  final DateTime lastUpdated;

  /// Uptime u sekundama
  final int uptimeSeconds;

  const NodeStats({
    required this.nodeId,
    required this.reliability,
    required this.errorRate,
    required this.batteryLevel,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.storageUsage,
    required this.activeConnections,
    required this.successfulTransactions,
    required this.failedTransactions,
    required this.avgResponseTimeMs,
    required this.lastUpdated,
    required this.uptimeSeconds,
  });

  /// Kreira kopiju sa ažuriranim vrednostima
  NodeStats copyWith({
    String? nodeId,
    double? reliability,
    double? errorRate,
    double? batteryLevel,
    double? cpuUsage,
    double? memoryUsage,
    double? storageUsage,
    List<ConnectionInfo>? activeConnections,
    int? successfulTransactions,
    int? failedTransactions,
    int? avgResponseTimeMs,
    DateTime? lastUpdated,
    int? uptimeSeconds,
  }) {
    return NodeStats(
      nodeId: nodeId ?? this.nodeId,
      reliability: reliability ?? this.reliability,
      errorRate: errorRate ?? this.errorRate,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      storageUsage: storageUsage ?? this.storageUsage,
      activeConnections: activeConnections ?? this.activeConnections,
      successfulTransactions:
          successfulTransactions ?? this.successfulTransactions,
      failedTransactions: failedTransactions ?? this.failedTransactions,
      avgResponseTimeMs: avgResponseTimeMs ?? this.avgResponseTimeMs,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      uptimeSeconds: uptimeSeconds ?? this.uptimeSeconds,
    );
  }

  /// Računa ukupnu stopu uspešnosti transakcija
  double get transactionSuccessRate {
    final total = successfulTransactions + failedTransactions;
    if (total == 0) return 1.0;
    return successfulTransactions / total;
  }

  /// Proverava da li je čvor preopterećen
  bool get isOverloaded =>
      cpuUsage > 0.9 || memoryUsage > 0.9 || storageUsage > 0.9;

  /// Proverava da li je čvor zdrav
  bool get isHealthy =>
      reliability > 0.8 &&
      errorRate < 0.1 &&
      batteryLevel > 0.2 &&
      !isOverloaded &&
      transactionSuccessRate > 0.95;

  /// Računa ukupan skor zdravlja čvora (0.0 - 1.0)
  double get healthScore {
    return (reliability * 0.3 +
            (1 - errorRate) * 0.2 +
            batteryLevel * 0.1 +
            (1 - cpuUsage) * 0.1 +
            (1 - memoryUsage) * 0.1 +
            (1 - storageUsage) * 0.1 +
            transactionSuccessRate * 0.1)
        .clamp(0.0, 1.0);
  }

  @override
  String toString() {
    return 'NodeStats('
        'nodeId: $nodeId, '
        'health: ${healthScore.toStringAsFixed(2)}, '
        'connections: ${activeConnections.length})';
  }
}
