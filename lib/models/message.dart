class Message {
  final String id;
  final String content;
  final String sender;
  final DateTime timestamp;
  bool read;
  bool synced;

  Message({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.read = false,
    this.synced = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'sender': sender,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'read': read ? 1 : 0,
      'synced': synced ? 1 : 0,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      content: map['content'],
      sender: map['sender'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      read: map['read'] == 1,
      synced: map['synced'] == 1,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      sender: json['sender'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
