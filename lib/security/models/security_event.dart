/// Tipovi sigurnosnih događaja
enum SecurityEventType {
  // Normalni događaji
  nodeJoined,
  nodeLeft,
  messageReceived,
  messageSent,

  // Sumnjivi događaji
  invalidMessage,
  invalidSignature,
  replayAttempt,
  unauthorizedAccess,

  // Pretnje
  potentialThreat,
  confirmedThreat,
  networkAttack,
  dataManipulation,
}

/// Model koji predstavlja sigurnosni događaj u sistemu
class SecurityEvent {
  final SecurityEventType type;
  final String sourceId;
  final DateTime timestamp;
  final double severity;
  final Map<String, dynamic>? details;

  const SecurityEvent({
    required this.type,
    required this.sourceId,
    required this.timestamp,
    required this.severity,
    this.details,
  });

  /// Kreira kopiju događaja sa novim vrednostima
  SecurityEvent copyWith({
    SecurityEventType? type,
    String? sourceId,
    DateTime? timestamp,
    double? severity,
    Map<String, dynamic>? details,
  }) {
    return SecurityEvent(
      type: type ?? this.type,
      sourceId: sourceId ?? this.sourceId,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      details: details ?? this.details,
    );
  }

  /// Kreira događaj iz JSON mape
  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    return SecurityEvent(
      type: SecurityEventType.values.firstWhere(
        (e) => e.toString() == 'SecurityEventType.${json['type']}',
      ),
      sourceId: json['sourceId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      severity: (json['severity'] as num).toDouble(),
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  /// Konvertuje događaj u JSON mapu
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'sourceId': sourceId,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity,
      if (details != null) 'details': details,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecurityEvent &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          sourceId == other.sourceId &&
          timestamp == other.timestamp;

  @override
  int get hashCode => type.hashCode ^ sourceId.hashCode ^ timestamp.hashCode;

  @override
  String toString() {
    return 'SecurityEvent(type: $type, sourceId: $sourceId, '
        'severity: ${severity.toStringAsFixed(2)})';
  }
}
