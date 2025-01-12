import 'message.dart';
import 'message_types.dart';

/// Standardna implementacija Message klase
class StandardMessage extends Message {
  StandardMessage({
    required String id,
    required String topic,
    required dynamic content,
    MessageType type = MessageType.standard,
    MessagePriority priority = MessagePriority.normal,
    required DateTime timestamp,
    Map<String, dynamic> metadata = const {},
  }) : super(
          id: id,
          topic: topic,
          content: content,
          type: type,
          priority: priority,
          timestamp: timestamp,
          metadata: metadata,
        );

  /// Kreira kopiju sa novim vrednostima
  StandardMessage copyWith({
    String? id,
    String? topic,
    dynamic content,
    MessageType? type,
    MessagePriority? priority,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return StandardMessage(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      content: content ?? this.content,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? Map.from(this.metadata),
    );
  }
}
