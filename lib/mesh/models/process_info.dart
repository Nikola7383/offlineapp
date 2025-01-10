/// Status procesa
enum ProcessStatus {
  unknown,
  running,
  paused,
  stopped,
  error,
}

/// Prioritet procesa
enum ProcessPriority {
  unknown,
  low,
  normal,
  high,
  critical,
}

/// Informacije o procesu
class ProcessInfo {
  final String id;
  final String name;
  final ProcessStatus status;
  final ProcessPriority priority;
  final DateTime startTime;
  final DateTime lastUpdateTime;
  final double cpuUsage;
  final double memoryUsageMb;
  final int threadCount;
  final int openFileCount;
  final int networkConnectionCount;

  ProcessInfo({
    required this.id,
    required this.name,
    required this.status,
    required this.priority,
    required this.startTime,
    required this.lastUpdateTime,
    this.cpuUsage = 0.0,
    this.memoryUsageMb = 0.0,
    this.threadCount = 0,
    this.openFileCount = 0,
    this.networkConnectionCount = 0,
  });

  /// Da li je proces aktivan
  bool get isActive =>
      status == ProcessStatus.running || status == ProcessStatus.paused;

  /// Kreira kopiju sa ažuriranim vrednostima
  ProcessInfo copyWith({
    String? id,
    String? name,
    ProcessStatus? status,
    ProcessPriority? priority,
    DateTime? startTime,
    DateTime? lastUpdateTime,
    double? cpuUsage,
    double? memoryUsageMb,
    int? threadCount,
    int? openFileCount,
    int? networkConnectionCount,
  }) {
    return ProcessInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startTime: startTime ?? this.startTime,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsageMb: memoryUsageMb ?? this.memoryUsageMb,
      threadCount: threadCount ?? this.threadCount,
      openFileCount: openFileCount ?? this.openFileCount,
      networkConnectionCount:
          networkConnectionCount ?? this.networkConnectionCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          status == other.status &&
          priority == other.priority;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ status.hashCode ^ priority.hashCode;

  @override
  String toString() =>
      'ProcessInfo{id: $id, name: $name, status: $status, priority: $priority}';
}
