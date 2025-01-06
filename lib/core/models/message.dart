import 'dart:convert';
import 'package:uuid/uuid.dart';

/// Model za poruke u sistemu
@immutable
class Message {
  final String id;
  final String content;
  final String senderId;
  final Priority priority;
  final DateTime timestamp;
  final List<String> attachments;

  const Message({
    required this.id,
    required this.content,
    required this.senderId,
    this.priority = Priority.medium,
    DateTime? timestamp,
    this.attachments = const [],
  }) : timestamp = timestamp ?? DateTime.now();

  bool get hasAttachments => attachments.isNotEmpty;
}

class MessageAttachment {
  final String id;
  final String type;
  final int size;
  final String path;

  const MessageAttachment({
    required this.id,
    required this.type,
    required this.size,
    required this.path,
  });
}
