import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/services/message_handler_impl.dart';
import '../test_setup.dart';

void main() {
  late MessageHandlerImpl handler;
  late MockLogger mockLogger;

  setUp(() {
    mockLogger = MockLogger();
    handler = MessageHandlerImpl(mockLogger);
  });

  tearDown(() async {
    await handler.dispose();
  });

  group('MessageHandler Tests', () {
    test('should initialize correctly', () async {
      // Act
      await handler.initialize();

      // Assert
      expect(handler.isInitialized, true);
      verify(mockLogger.info(any)).called(greaterThanOrEqualTo(1));
    });

    test('should handle single message', () async {
      // Arrange
      await handler.initialize();
      final message = TestSetup.createTestMessage();

      // Act
      final result = await handler.handleMessage(message);

      // Assert
      expect(result.isSuccess, true);
      verify(mockLogger.info(any)).called(greaterThanOrEqualTo(1));
    });

    test('should handle batch of messages', () async {
      // Arrange
      await handler.initialize();
      final batch = TestSetup.createTestBatch();

      // Act
      final result = await handler.handleBatch(batch);

      // Assert
      expect(result.isSuccess, true);
      verify(mockLogger.info(any)).called(greaterThanOrEqualTo(batch.length));
    });

    test('should emit status updates', () async {
      // Arrange
      await handler.initialize();
      final message = TestSetup.createTestMessage();
      final statusUpdates = <MessageStatus>[];

      handler.messageStream.listen((msg) {
        statusUpdates.add(msg.status);
      });

      // Act
      await handler.handleMessage(message);
      await delay();

      // Assert
      expect(statusUpdates, contains(MessageStatus.pending));
      expect(statusUpdates, contains(MessageStatus.sent));
    });
  });
}
