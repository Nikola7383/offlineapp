import 'dart:convert';
import 'package:uuid/uuid.dart';

/// Model za poruke u sistemu
@immutable
class Message {
  final String id;
  final String content;
  final List<MessageAttachment> attachments;
  final DateTime timestamp;
  final String senderId;

  const Message({
    required this.id,
    required this.content,
    this.attachments = const [],
    required this.timestamp,
    required this.senderId,
  });

  bool get hasAttachments => attachments.isNotEmpty;

  int getTotalAttachmentSize() {
    return attachments.fold<int>(0, (sum, attachment) => sum + attachment.size);
  }
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
