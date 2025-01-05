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
