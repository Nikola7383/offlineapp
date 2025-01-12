import 'package:injectable/injectable.dart';
import '../interfaces/message_service_interface.dart';
import '../../messaging/transport/message_service.dart';
import '../models/message.dart';
import '../models/encrypted_message.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';
import 'dart:convert';

/// Repozitorijum za poruke
@LazySingleton()
class MessageRepository {
  final IMessageService _messageService;
  late final Database _db;

  MessageRepository(this._messageService);

  /// Inicijalizuje repozitorijum
  Future<void> initialize() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'messages.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
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
      },
    );
  }

  /// Zatvara repozitorijum
  Future<void> dispose() async {
    await _db.close();
  }

  /// Čuva poruku
  Future<void> saveMessage(Message message) async {
    await _db.insert(
      'messages',
      {
        'id': message.id,
        'sender_id': message.senderId,
        'recipient_id': message.recipientId,
        'content': message.content,
        'timestamp': message.timestamp.millisecondsSinceEpoch,
        'type': message.type,
        'priority': message.priority,
        'metadata': json.encode(message.metadata),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Čuva enkriptovanu poruku
  Future<void> saveEncryptedMessage(EncryptedMessage message) async {
    await _db.insert(
      'encrypted_messages',
      {
        'id': message.id,
        'sender_id': message.senderId,
        'recipient_id': message.recipientId,
        'content': message.content,
        'hash': message.hash,
        'signature': message.signature,
        'timestamp': message.timestamp.millisecondsSinceEpoch,
        'type': message.type,
        'priority': message.priority,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Vraća poruku po ID-u
  Future<Message?> getMessage(String id) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    final map = maps.first;
    return Message(
      id: map['id'] as String,
      senderId: map['sender_id'] as String,
      recipientId: map['recipient_id'] as String,
      content: map['content'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      type: map['type'] as String,
      priority: map['priority'] as int,
      metadata: _deserializeMetadata(map['metadata'] as String?),
    );
  }

  /// Vraća enkriptovanu poruku po ID-u
  Future<EncryptedMessage?> getEncryptedMessage(String id) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'encrypted_messages',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    final map = maps.first;
    return EncryptedMessage(
      id: map['id'] as String,
      senderId: map['sender_id'] as String,
      recipientId: map['recipient_id'] as String,
      content: map['content'] as String,
      hash: map['hash'] as String,
      signature: Uint8List.fromList(map['signature'] as List<int>),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      type: map['type'] as String,
      priority: map['priority'] as int,
    );
  }

  /// Vraća sve poruke
  Future<List<Message>> getAllMessages() async {
    final List<Map<String, dynamic>> maps = await _db.query('messages');
    return List.generate(maps.length, (i) {
      final map = maps[i];
      return Message(
        id: map['id'] as String,
        senderId: map['sender_id'] as String,
        recipientId: map['recipient_id'] as String,
        content: map['content'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        type: map['type'] as String,
        priority: map['priority'] as int,
        metadata: _deserializeMetadata(map['metadata'] as String?),
      );
    });
  }

  /// Vraća sve enkriptovane poruke
  Future<List<EncryptedMessage>> getAllEncryptedMessages() async {
    final List<Map<String, dynamic>> maps =
        await _db.query('encrypted_messages');
    return List.generate(maps.length, (i) {
      final map = maps[i];
      return EncryptedMessage(
        id: map['id'] as String,
        senderId: map['sender_id'] as String,
        recipientId: map['recipient_id'] as String,
        content: map['content'] as String,
        hash: map['hash'] as String,
        signature: Uint8List.fromList(map['signature'] as List<int>),
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        type: map['type'] as String,
        priority: map['priority'] as int,
      );
    });
  }

  /// Briše poruku
  Future<void> deleteMessage(String id) async {
    await _db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Briše enkriptovanu poruku
  Future<void> deleteEncryptedMessage(String id) async {
    await _db.delete(
      'encrypted_messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Briše sve poruke
  Future<void> deleteAllMessages() async {
    await _db.delete('messages');
    await _db.delete('encrypted_messages');
  }

  /// Deserijalizuje metapodatke
  Map<String, dynamic> _deserializeMetadata(String? metadata) {
    if (metadata == null || metadata.isEmpty) {
      return {};
    }
    try {
      return json.decode(metadata) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
}
