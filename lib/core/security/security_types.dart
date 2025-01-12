import 'dart:typed_data';

class EncryptedData {
  final Uint8List data;
  final Uint8List sessionKey;
  final Uint8List iv;

  EncryptedData({
    required this.data,
    required this.sessionKey,
    required this.iv,
  });
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}

enum SessionEventType { established, refreshed, invalidated }

class SessionEvent {
  final SessionEventType type;
  final String sessionId;
  final String peerId;

  SessionEvent({
    required this.type,
    required this.sessionId,
    required this.peerId,
  });
}

/// Nivo ozbiljnosti upozorenja
enum AlertSeverity {
  /// Nizak nivo
  low,

  /// Srednji nivo
  medium,

  /// Visok nivo
  high,

  /// Kritičan nivo
  critical
}

/// Upozorenje o performansama
class PerformanceAlert {
  /// Nivo ozbiljnosti
  final AlertSeverity severity;

  /// Poruka
  final String message;

  /// Metrika koja je izazvala upozorenje
  final String metric;

  /// Vrednost metrike
  final Duration value;

  /// Kreira novo upozorenje
  const PerformanceAlert({
    required this.severity,
    required this.message,
    required this.metric,
    required this.value,
  });
}
