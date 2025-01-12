import 'base_service.dart';

abstract class ITransferMonitor implements IService {
  Future<void> recordAttempt(int attempt);
  Future<void> recordFailure(int attempt, Object error);
  Future<bool> shouldSwitchToQr();
  Future<TransferStats> getStats();
  Stream<TransferEvent> get transferEvents;
}

class TransferStats {
  final int totalAttempts;
  final int failedAttempts;
  final Duration averageAttemptDuration;
  final DateTime lastAttemptTime;
  final bool isStable;

  TransferStats({
    required this.totalAttempts,
    required this.failedAttempts,
    required this.averageAttemptDuration,
    required this.lastAttemptTime,
    required this.isStable,
  });
}

class TransferEvent {
  final TransferEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  TransferEvent({
    required this.type,
    required this.data,
  }) : timestamp = DateTime.now();
}

enum TransferEventType {
  attemptStarted,
  attemptCompleted,
  attemptFailed,
  switchingMethod,
  error,
}
