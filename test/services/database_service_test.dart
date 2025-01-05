import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:your_app/services/database_service.dart';
import 'package:your_app/models/message.dart';

void main() {
  late DatabaseService db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = DatabaseService();
    // Use in-memory database for testing
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('DatabaseService Tests', () {
    test('saveMessage should store message in database', () async {
      // Arrange
      final message = Message(
        id: '1',
        content: 'Test message',
        sender: 'Test sender',
        timestamp: DateTime.now(),
      );

      // Act
      await db.saveMessage(message);
      final messages = await db.getUnreadMessages();

      // Assert
      expect(messages.length, 1);
      expect(messages.first.id, '1');
      expect(messages.first.content, 'Test message');
    });

    test('getUnreadMessages should return only unread messages', () async {
      // Arrange
      final message1 = Message(
        id: '1',
        content: 'Unread message',
        sender: 'Test sender',
        timestamp: DateTime.now(),
        read: false,
      );
      final message2 = Message(
        id: '2',
        content: 'Read message',
        sender: 'Test sender',
        timestamp: DateTime.now(),
        read: true,
      );

      await db.saveMessage(message1);
      await db.saveMessage(message2);

      // Act
      final unreadMessages = await db.getUnreadMessages();

      // Assert
      expect(unreadMessages.length, 1);
      expect(unreadMessages.first.id, '1');
      expect(unreadMessages.first.read, false);
    });
  });
}
