class TestMessage {
  final String id;
  final String content;
  final int sizeInKB;
  final DateTime timestamp;

  TestMessage({
    required this.id,
    required this.content,
    required this.sizeInKB,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sizeInKB': sizeInKB,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TestMessage.fromJson(Map<String, dynamic> json) {
    return TestMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      sizeInKB: json['sizeInKB'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
