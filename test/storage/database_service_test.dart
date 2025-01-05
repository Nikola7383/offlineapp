import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/storage/database_service.dart';
import 'package:secure_event_app/core/models/message.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseService db;

  setUpAll(() {
    // Inicijalizacija FFI za testiranje
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = DatabaseService(logger: LoggerService());
    await db.initialize();
  });

  tearDown(() async {
    await db.close();
  });

  group('Database Service Tests', () {
    test('Should save and retrieve message', () async {
      // Arrange
      final message = Message(
        id: 'test_1',
        content: 'Test message',
        senderId: 'sender_1',
        timestamp: DateTime.now(),
        type: MessageType.text,
        metadata: {'test': 'data'},
      );

      // Act
      await db.saveMessage(message);
      final messages = await db.getMessages(limit: 1);

      // Assert
      expect(messages.length, equals(1));
      expect(messages.first.id, equals(message.id));
      expect(messages.first.content, equals(message.content));
    });

    test('Should handle message deletion', () async {
      // Arrange
      final message = Message(
        id: 'test_delete',
        content: 'Delete me',
        senderId: 'sender_1',
        timestamp: DateTime.now(),
      );

      // Act
      await db.saveMessage(message);
      await db.deleteMessage(message.id);
      final messages = await db.getMessages();

      // Assert
      expect(messages.where((m) => m.id == message.id), isEmpty);
    });

    test('Should retrieve messages since timestamp', () async {
      // Arrange
      final now = DateTime.now();
      final oldMessage = Message(
        id: 'old',
        content: 'Old message',
        senderId: 'sender_1',
        timestamp: now.subtract(const Duration(days: 1)),
      );

      final newMessage = Message(
        id: 'new',
        content: 'New message',
        senderId: 'sender_1',
        timestamp: now,
      );

      // Act
      await db.saveMessage(oldMessage);
      await db.saveMessage(newMessage);

      final messages = await db.getMessages(
        since: now.subtract(const Duration(hours: 1)),
      );

      // Assert
      expect(messages.length, equals(1));
      expect(messages.first.id, equals('new'));
    });
  });
}
