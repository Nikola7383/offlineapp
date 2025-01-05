import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/performance/lazy_message_loader.dart';
import 'package:secure_event_app/core/storage/database_service.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';
import 'package:secure_event_app/core/models/message.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late LazyMessageLoader loader;
  late MockDatabaseService mockStorage;
  late MockLoggerService mockLogger;

  setUp(() {
    mockStorage = MockDatabaseService();
    mockLogger = MockLoggerService();
    loader = LazyMessageLoader(
      storage: mockStorage,
      logger: mockLogger,
    );
  });

  group('LazyMessageLoader Tests', () {
    test('loads initial batch correctly', () async {
      final testMessages = List.generate(
        50,
        (i) => Message(
          id: 'msg_$i',
          content: 'Test $i',
          senderId: 'sender_1',
          timestamp: DateTime.now(),
        ),
      );

      when(mockStorage.getMessages(
        limit: any,
        offset: 0,
      )).thenAnswer((_) async => testMessages);

      final messages = await loader.loadNextBatch();

      expect(messages.length, equals(50));
      expect(loader.hasMoreMessages, isTrue);
    });

    test('handles empty batch correctly', () async {
      when(mockStorage.getMessages(
        limit: any,
        offset: any,
      )).thenAnswer((_) async => []);

      final messages = await loader.loadNextBatch();

      expect(messages.isEmpty, isTrue);
      expect(loader.hasMoreMessages, isFalse);
    });

    test('refresh clears existing messages', () async {
      // Load initial batch
      when(mockStorage.getMessages(
        limit: any,
        offset: 0,
      )).thenAnswer((_) async => [
            Message(
              id: 'test_1',
              content: 'Test',
              senderId: 'sender_1',
              timestamp: DateTime.now(),
            ),
          ]);

      await loader.loadNextBatch();
      expect(loader.currentMessages.length, equals(1));

      // Refresh
      await loader.refreshMessages();
      verify(mockStorage.getMessages(
        limit: any,
        offset: 0,
      )).called(2);
    });
  });
}
