import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import '../interfaces/logger_service.dart';
import '../models/database_config.dart';
import '../models/message.dart';

abstract class IDatabaseService {
  Future<void> initialize();
  Future<List<Message>> getMessages();
  Future<void> saveMessage(Message message);
  Future<void> deleteMessage(String id);
  Future<void> close();
}

@injectable
class DatabaseService implements IDatabaseService {
  final ILoggerService _logger;
  final DatabaseConfig _config;
  late Database _db;

  DatabaseService(
    this._logger,
    this._config,
  );

  @override
  Future<void> initialize() async {
    try {
      _logger.info('Initializing database...');

      final path = '${_config.path}/${_config.name}';
      _db = await openDatabase(
        path,
        version: _config.version,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE messages (
              id TEXT PRIMARY KEY,
              content TEXT NOT NULL,
              sender_id TEXT NOT NULL,
              timestamp INTEGER NOT NULL,
              status TEXT NOT NULL,
              encrypted_key TEXT,
              signature TEXT,
              is_urgent INTEGER NOT NULL
            )
          ''');
        },
      );

      _logger.info('Database initialized successfully');
    } catch (e) {
      _logger.error('Failed to initialize database: $e');
      rethrow;
    }
  }

  @override
  Future<List<Message>> getMessages() async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query('messages');
      return List.generate(maps.length, (i) => Message.fromMap(maps[i]));
    } catch (e) {
      _logger.error('Failed to get messages: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveMessage(Message message) async {
    try {
      await _db.insert(
        'messages',
        message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.info('Message saved successfully: ${message.id}');
    } catch (e) {
      _logger.error('Failed to save message: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteMessage(String id) async {
    try {
      await _db.delete(
        'messages',
        where: 'id = ?',
        whereArgs: [id],
      );
      _logger.info('Message deleted successfully: $id');
    } catch (e) {
      _logger.error('Failed to delete message: $e');
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    try {
      await _db.close();
      _logger.info('Database closed successfully');
    } catch (e) {
      _logger.error('Failed to close database: $e');
      rethrow;
    }
  }
}
