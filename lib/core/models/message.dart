import 'dart:convert';
import 'package:uuid/uuid.dart';

/// Model za poruke u sistemu
@immutable
class Message {
  final String id;
  final String content;
  final String senderId;
  final DateTime timestamp;
  final MessageStatus status;
  final String? encryptedKey;
  final String? signature;
  final bool isUrgent;

  const Message._({
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
    required this.status,
    this.encryptedKey,
    this.signature,
    this.isUrgent = false,
  });

  factory Message.create({
    required String content,
    required String senderId,
    bool isUrgent = false,
  }) {
    return Message._(
      id: const Uuid().v4(),
      content: content,
      senderId: senderId,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      isUrgent: isUrgent,
    );
  }

  Message copyWith({
    String? content,
    MessageStatus? status,
    String? encryptedKey,
    String? signature,
  }) {
    return Message._(
      id: id,
      content: content ?? this.content,
      senderId: senderId,
      timestamp: timestamp,
      status: status ?? this.status,
      encryptedKey: encryptedKey ?? this.encryptedKey,
      signature: signature ?? this.signature,
      isUrgent: isUrgent,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'content': content,
        'senderId': senderId,
        'timestamp': timestamp.toIso8601String(),
        'status': status.toString(),
        'encryptedKey': encryptedKey,
        'signature': signature,
        'isUrgent': isUrgent,
      };

  static Message fromMap(Map<String, dynamic> map) => Message._(
        id: map['id'] as String,
        content: map['content'] as String,
        senderId: map['senderId'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        status: MessageStatus.values.firstWhere(
          (e) => e.toString() == map['status'],
          orElse: () => MessageStatus.sending,
        ),
        encryptedKey: map['encryptedKey'] as String?,
        signature: map['signature'] as String?,
        isUrgent: map['isUrgent'] as bool? ?? false,
      );
}

/// Status poruke u sistemu
enum MessageStatus {
  sending,
  sent,
  failed,
}
