class Message {
  final String id;
  final String content;
  final String senderId;
  final DateTime timestamp;
  final bool encrypted;
  final String? signature;
  final String? encryptedKey;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
    this.encrypted = false,
    this.signature,
    this.encryptedKey,
  });

  Message copyWith({
    String? content,
    bool? encrypted,
    String? signature,
    String? encryptedKey,
  }) {
    return Message(
      id: id,
      content: content ?? this.content,
      senderId: senderId,
      timestamp: timestamp,
      encrypted: encrypted ?? this.encrypted,
      signature: signature ?? this.signature,
      encryptedKey: encryptedKey ?? this.encryptedKey,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'encrypted': encrypted,
      'signature': signature,
      'encryptedKey': encryptedKey,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      content: map['content'],
      senderId: map['senderId'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      encrypted: map['encrypted'] ?? false,
      signature: map['signature'],
      encryptedKey: map['encryptedKey'],
    );
  }
}
