class SecureMessage {
  final Message originalMessage;
  final String encryptedContent;
  final String encryptedKey;
  final String signature;
  final DateTime timestamp;

  SecureMessage({
    required this.originalMessage,
    required this.encryptedContent,
    required this.encryptedKey,
    required this.signature,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'originalMessage': originalMessage.toMap(),
      'encryptedContent': encryptedContent,
      'encryptedKey': encryptedKey,
      'signature': signature,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory SecureMessage.fromMap(Map<String, dynamic> map) {
    return SecureMessage(
      originalMessage: Message.fromMap(map['originalMessage']),
      encryptedContent: map['encryptedContent'],
      encryptedKey: map['encryptedKey'],
      signature: map['signature'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}
