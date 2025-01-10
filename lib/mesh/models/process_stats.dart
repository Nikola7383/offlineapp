/// Statistike procesa
class ProcessStats {
  /// CPU iskorišćenost (0-100%)
  final double cpuUsage;

  /// Iskorišćenost memorije u MB
  final double memoryUsageMb;

  /// Broj aktivnih threadova
  final int threadCount;

  /// Broj otvorenih fajlova
  final int openFileCount;

  /// Broj mrežnih konekcija
  final int networkConnectionCount;

  /// Vreme merenja
  final DateTime timestamp;

  const ProcessStats({
    required this.cpuUsage,
    required this.memoryUsageMb,
    required this.threadCount,
    required this.openFileCount,
    required this.networkConnectionCount,
    required this.timestamp,
  });

  /// Kreira kopiju sa ažuriranim vrednostima
  ProcessStats copyWith({
    double? cpuUsage,
    double? memoryUsageMb,
    int? threadCount,
    int? openFileCount,
    int? networkConnectionCount,
    DateTime? timestamp,
  }) {
    return ProcessStats(
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsageMb: memoryUsageMb ?? this.memoryUsageMb,
      threadCount: threadCount ?? this.threadCount,
      openFileCount: openFileCount ?? this.openFileCount,
      networkConnectionCount:
          networkConnectionCount ?? this.networkConnectionCount,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessStats &&
          runtimeType == other.runtimeType &&
          cpuUsage == other.cpuUsage &&
          memoryUsageMb == other.memoryUsageMb &&
          threadCount == other.threadCount &&
          openFileCount == other.openFileCount &&
          networkConnectionCount == other.networkConnectionCount &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      cpuUsage.hashCode ^
      memoryUsageMb.hashCode ^
      threadCount.hashCode ^
      openFileCount.hashCode ^
      networkConnectionCount.hashCode ^
      timestamp.hashCode;

  @override
  String toString() =>
      'ProcessStats{cpuUsage: $cpuUsage, memoryUsageMb: $memoryUsageMb, threadCount: $threadCount, openFileCount: $openFileCount, networkConnectionCount: $networkConnectionCount, timestamp: $timestamp}';
}
