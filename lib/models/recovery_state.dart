class RecoveryState {
  final String peerId;
  final DateTime startedAt;
  final int attemptCount;
  final List<String> failedMessageIds;
  RecoveryStatus status;

  RecoveryState({
    required this.peerId,
    required this.startedAt,
    this.attemptCount = 0,
    List<String>? failedMessageIds,
    this.status = RecoveryStatus.initializing,
  }) : failedMessageIds = failedMessageIds ?? [];

  bool get isRecovering =>
      status == RecoveryStatus.initializing ||
      status == RecoveryStatus.inProgress;
}

enum RecoveryStatus { initializing, inProgress, succeeded, failed, abandoned }
