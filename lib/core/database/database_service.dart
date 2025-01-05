import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../base/base_service.dart';
import '../models/message.dart';
import '../services/logger_service.dart';
import '../interfaces/database_interface.dart';
import '../database/connection_pool.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:your_app/services/resource_manager.dart';

@injectable
class DatabaseService extends InjectableService
    implements DatabaseInterface, Disposable {
  static Database? _db;
  final _pool = DatabasePool();
  final _statements = DatabaseStatements();
  final BatchProcessor _batchProcessor;

  DatabaseService(
    LoggerService logger,
    this._batchProcessor,
  ) : super(logger);

  @override
  Future<void> initialize() async {
    await super.initialize();
    _db = await _initDatabase();
    ServiceLocator.instance.get<ResourceManager>().register('database', this);
  }

  @override
  Future<void> dispose() async {
    await _pool.dispose();
    await _db?.close();
    _db = null;
    await super.dispose();
  }

  Future<List<Message>> getMessages({
    DateTime? since,
    int limit = 50,
    String? senderId,
  }) async {
    return await _pool.withConnection((db) async {
      final List<Map<String, dynamic>> maps = await db.query(
        'messages',
        where: 'timestamp > ? AND sender_id = COALESCE(?, sender_id)',
        whereArgs: [since?.millisecondsSinceEpoch ?? 0, senderId],
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      return List.generate(maps.length, (i) => Message.fromMap(maps[i]));
    });
  }

  Future<Database> get database async {
    return await _pool.acquire();
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_statements.createMessagesTable);
    await db.execute(_statements.createUsersTable);
    await db.execute(_statements.createIndices);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implementirati kada budemo imali migracije
  }

  Future<void> _runMigrations() async {
    // Implementirati kada budemo imali migracije
  }

  Future<bool> messageExists(String id) async {
    return safeExecute(() async {
      final db = await database;
      final count = Sqflite.firstIntValue(
        await db.query(
          'messages',
          columns: ['COUNT(*)'],
          where: 'id = ?',
          whereArgs: [id],
        ),
      );
      return count! > 0;
    }, errorMessage: 'Greška pri proveri poruke', defaultValue: false);
  }

  void _releaseConnection(Database db) {
    _pool.release(db);
  }
}

class DatabaseStatements {
  final String createMessagesTable = '''
    CREATE TABLE messages(
      id TEXT PRIMARY KEY,
      content TEXT,
      sender_id TEXT,
      timestamp INTEGER,
      status TEXT,
      encrypted_key TEXT,
      signature TEXT,
      is_urgent INTEGER DEFAULT 0
    )
  ''';

  final String createUsersTable = '''
    CREATE TABLE users(
      id TEXT PRIMARY KEY,
      username TEXT UNIQUE,
      password_hash TEXT,
      role TEXT,
      created_at INTEGER
    )
  ''';

  final String createIndices = '''
    CREATE INDEX idx_messages_timestamp ON messages(timestamp);
    CREATE INDEX idx_messages_sender ON messages(sender_id);
    CREATE INDEX idx_users_username ON users(username);
  ''';
}
