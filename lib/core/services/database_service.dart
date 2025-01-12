import 'package:injectable/injectable.dart';
import '../interfaces/base_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Servis za rad sa bazom podataka
@LazySingleton()
class DatabaseService implements IService {
  late final Database _db;
  static const String _databaseName = 'secure_event_app.db';
  static const int _databaseVersion = 1;

  @override
  Future<void> initialize() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  @override
  Future<void> dispose() async {
    await _db.close();
  }

  /// Kreira tabele u bazi
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        sender_id TEXT NOT NULL,
        recipient_id TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        type TEXT NOT NULL,
        priority INTEGER NOT NULL,
        metadata TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE encrypted_messages (
        id TEXT PRIMARY KEY,
        sender_id TEXT NOT NULL,
        recipient_id TEXT NOT NULL,
        content TEXT NOT NULL,
        hash TEXT NOT NULL,
        signature BLOB NOT NULL,
        timestamp INTEGER NOT NULL,
        type TEXT NOT NULL,
        priority INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE public_keys (
        user_id TEXT PRIMARY KEY,
        public_key TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  /// Ažurira bazu
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // TODO: Implementirati migracije kada bude potrebno
  }

  /// Izvršava upit
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return _db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Ubacuje podatke
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return _db.insert(
      table,
      values,
      nullColumnHack: nullColumnHack,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  /// Ažurira podatke
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return _db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  /// Briše podatke
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return _db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Izvršava batch operacije
  Future<List<Object?>> batch(void Function(Batch batch) action) async {
    final batch = _db.batch();
    action(batch);
    return batch.commit();
  }

  /// Izvršava transakciju
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    return _db.transaction(action);
  }
}
