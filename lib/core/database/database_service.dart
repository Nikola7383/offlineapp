import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/user/guest_user.dart';
import '../../models/broadcast/broadcast_message.dart';
import '../interfaces/base_service.dart';

class DatabaseService extends BaseService {
  static const String _databaseName = 'secure_event_app.db';
  static const int _databaseVersion = 1;

  Database? _database;
  bool _isInitialized = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    await database;
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) return;
    await _database?.close();
    _database = null;
    _isInitialized = false;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Guest table
    await db.execute('''
      CREATE TABLE guests (
        id TEXT PRIMARY KEY,
        device_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 0,
        received_broadcast_ids TEXT NOT NULL DEFAULT '[]'
      )
    ''');

    // Broadcast table
    await db.execute('''
      CREATE TABLE broadcasts (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_urgent INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        received_by_ids TEXT NOT NULL DEFAULT '[]'
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implementirati migracije kada bude potrebno
  }

  // Guest methods
  Future<void> saveGuest(GuestUser guest) async {
    final db = await database;
    await db.insert(
      'guests',
      {
        'id': guest.id,
        'device_id': guest.deviceId,
        'created_at': guest.createdAt.millisecondsSinceEpoch,
        'updated_at': guest.updatedAt.millisecondsSinceEpoch,
        'expires_at': guest.expiresAt.millisecondsSinceEpoch,
        'is_active': guest.isActive ? 1 : 0,
        'received_broadcast_ids': guest.receivedBroadcastIds.join(','),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<GuestUser?> getGuest(String guestId) async {
    final db = await database;
    final results = await db.query(
      'guests',
      where: 'id = ?',
      whereArgs: [guestId],
    );

    if (results.isEmpty) return null;

    final row = results.first;
    return GuestUser(
      id: row['id'] as String,
      deviceId: row['device_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(row['expires_at'] as int),
      isActive: (row['is_active'] as int) == 1,
      receivedBroadcastIds: (row['received_broadcast_ids'] as String)
          .split(',')
          .where((id) => id.isNotEmpty)
          .toList(),
    );
  }

  Future<List<GuestUser>> getAllGuests() async {
    final db = await database;
    final results = await db.query('guests');
    return results
        .map((row) => GuestUser(
              id: row['id'] as String,
              deviceId: row['device_id'] as String,
              createdAt:
                  DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
              updatedAt:
                  DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
              expiresAt:
                  DateTime.fromMillisecondsSinceEpoch(row['expires_at'] as int),
              isActive: (row['is_active'] as int) == 1,
              receivedBroadcastIds: (row['received_broadcast_ids'] as String)
                  .split(',')
                  .where((id) => id.isNotEmpty)
                  .toList(),
            ))
        .toList();
  }

  // Broadcast methods
  Future<void> saveBroadcast(BroadcastMessage broadcast) async {
    final db = await database;
    await db.insert(
      'broadcasts',
      {
        'id': broadcast.id,
        'content': broadcast.content,
        'sender_id': broadcast.senderId,
        'created_at': broadcast.createdAt.millisecondsSinceEpoch,
        'updated_at': broadcast.updatedAt.millisecondsSinceEpoch,
        'is_urgent': broadcast.isUrgent ? 1 : 0,
        'is_active': broadcast.isActive ? 1 : 0,
        'received_by_ids': broadcast.receivedByIds.join(','),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<BroadcastMessage?> getBroadcast(String broadcastId) async {
    final db = await database;
    final results = await db.query(
      'broadcasts',
      where: 'id = ?',
      whereArgs: [broadcastId],
    );

    if (results.isEmpty) return null;

    final row = results.first;
    return BroadcastMessage(
      id: row['id'] as String,
      content: row['content'] as String,
      senderId: row['sender_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
      isUrgent: (row['is_urgent'] as int) == 1,
      isActive: (row['is_active'] as int) == 1,
      receivedByIds: (row['received_by_ids'] as String)
          .split(',')
          .where((id) => id.isNotEmpty)
          .toList(),
    );
  }

  Future<List<BroadcastMessage>> getActiveBroadcasts() async {
    final db = await database;
    final results = await db.query(
      'broadcasts',
      where: 'is_active = 1',
      orderBy: 'created_at DESC',
    );
    return results.map(_broadcastFromRow).toList();
  }

  Future<List<BroadcastMessage>> getUrgentBroadcasts() async {
    final db = await database;
    final results = await db.query(
      'broadcasts',
      where: 'is_active = 1 AND is_urgent = 1',
      orderBy: 'created_at DESC',
    );
    return results.map(_broadcastFromRow).toList();
  }

  Future<List<BroadcastMessage>> getAllBroadcasts() async {
    final db = await database;
    final results = await db.query(
      'broadcasts',
      orderBy: 'created_at DESC',
    );
    return results.map(_broadcastFromRow).toList();
  }

  BroadcastMessage _broadcastFromRow(Map<String, dynamic> row) {
    return BroadcastMessage(
      id: row['id'] as String,
      content: row['content'] as String,
      senderId: row['sender_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
      isUrgent: (row['is_urgent'] as int) == 1,
      isActive: (row['is_active'] as int) == 1,
      receivedByIds: (row['received_by_ids'] as String)
          .split(',')
          .where((id) => id.isNotEmpty)
          .toList(),
    );
  }
}

// Provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});
