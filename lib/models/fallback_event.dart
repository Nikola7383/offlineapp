class FallbackEvent {
  final String id;
  final DateTime timestamp;
  final FallbackType type;
  final String description;
  final Map<String, dynamic> metadata;

  FallbackEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.description,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};
}

enum FallbackType {
  transferFailure,
  dataCorruption,
  systemError,
  networkIssue,
  securityBreach,
}
