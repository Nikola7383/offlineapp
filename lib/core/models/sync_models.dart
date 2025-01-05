/// Status sinhronizacije
enum SyncStatus { idle, syncing, error, offline }

/// Događaji tokom sinhronizacije
class SyncEvent {
  final SyncEventType type;
  final String? messageId;
  final String? error;
  final DateTime timestamp;

  const SyncEvent({
    required this.type,
    this.messageId,
    this.error,
    required this.timestamp,
  });

  factory SyncEvent.started() {
    return SyncEvent(
      type: SyncEventType.started,
      timestamp: DateTime.now(),
    );
  }

  factory SyncEvent.completed() {
    return SyncEvent(
      type: SyncEventType.completed,
      timestamp: DateTime.now(),
    );
  }

  factory SyncEvent.messageSynced(String messageId) {
    return SyncEvent(
      type: SyncEventType.messageSynced,
      messageId: messageId,
      timestamp: DateTime.now(),
    );
  }

  factory SyncEvent.error(String error) {
    return SyncEvent(
      type: SyncEventType.error,
      error: error,
      timestamp: DateTime.now(),
    );
  }
}

/// Tipovi sinhronizacionih događaja
enum SyncEventType { started, messageSynced, completed, error }

/// Konfiguracija za sync service
class SyncConfig {
  final Duration syncInterval;
  final int maxRetries;
  final Duration retryDelay;
  final int batchSize;
  final bool autoSync;

  const SyncConfig({
    this.syncInterval = const Duration(minutes: 15),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 30),
    this.batchSize = 50,
    this.autoSync = true,
  });
}
