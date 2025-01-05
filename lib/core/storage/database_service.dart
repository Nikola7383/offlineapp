import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/message.dart';
import '../logging/logger_service.dart';

abstract class DatabaseService {
  Future<void> initialize();
  Future<List<Message>> getMessages({required int limit, required int offset});
  Future<void> saveMessage(Message message);
  Future<void> deleteMessage(String messageId);
}

class DatabaseServiceImpl implements DatabaseService {
  final LoggerService _logger;
  
  DatabaseServiceImpl({
    required LoggerService logger,
  }) : _logger = logger;

  @override
  Future<void> initialize() async {
    try {
      // Inicijalizacija baze
      await _logger.info('Database initialized');
    } catch (e) {
      await _logger.error('Failed to initialize database', e);
      rethrow;
    }
  }

  @override
  Future<List<Message>> getMessages({
    required int limit,
    required int offset,
  }) async {
    try {
      // Implementacija će doći kasnije
      return [];
    } catch (e) {
      await _logger.error('Failed to get messages', e);
      rethrow;
    }
  }

  @override
  Future<void> saveMessage(Message message) async {
    try {
      // Implementacija će doći kasnije
      await _logger.info('Message saved: ${message.id}');
    } catch (e) {
      await _logger.error('Failed to save message', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      // Implementacija će doći kasnije
      await _logger.info('Message deleted: $messageId');
    } catch (e) {
      await _logger.error('Failed to delete message', e);
      rethrow;
    }
  }
}

  Message _mapToMessage(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      content: map['content'],
      senderId: map['senderId'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => MessageType.text,
      ),
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
