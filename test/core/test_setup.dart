import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/interfaces/logger.dart';
import 'package:secure_event_app/core/interfaces/message_handler.dart';
import 'package:secure_event_app/core/models/message.dart';
import 'package:secure_event_app/core/models/result.dart';
import 'package:secure_event_app/core/config/app_config.dart';

// Test configuration
class TestSetup {
  static const timeout = Duration(seconds: 30);
  static const messageDelay = Duration(milliseconds: 100);

  static Message createTestMessage({
    String? id,
    String? content,
    String? senderId,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? 'test_id',
      content: content ?? 'test_content',
      senderId: senderId ?? 'test_sender',
      timestamp: timestamp ?? DateTime.now(),
      status: status ?? MessageStatus.pending,
    );
  }

  static List<Message> createTestBatch({
    int size = AppConfig.messageBatchSize,
    String prefix = 'test_message_',
  }) {
    return List.generate(
      size,
      (i) => createTestMessage(
        id: '${prefix}$i',
        content: 'Test message $i',
      ),
    );
  }
}

// Mock classes
class MockLogger extends Mock implements Logger {
  @override
  Future<void> info(String message, [Map<String, dynamic>? context]) async {
    return super.noSuchMethod(
      Invocation.method(#info, [message, context]),
      returnValue: Future<void>.value(),
    );
  }

  @override
  Future<void> error(String message,
      [dynamic error, StackTrace? stackTrace]) async {
    return super.noSuchMethod(
      Invocation.method(#error, [message, error, stackTrace]),
      returnValue: Future<void>.value(),
    );
  }
}

class MockMessageHandler extends Mock implements MessageHandler {
  @override
  Future<Result<void>> handleMessage(Message message) async {
    return super.noSuchMethod(
      Invocation.method(#handleMessage, [message]),
      returnValue: Future.value(Result.success()),
    );
  }

  @override
  Future<Result<void>> handleBatch(List<Message> messages) async {
    return super.noSuchMethod(
      Invocation.method(#handleBatch, [messages]),
      returnValue: Future.value(Result.success()),
    );
  }
}

// Test helpers
Future<void> delay([Duration? duration]) async {
  await Future.delayed(duration ?? TestSetup.messageDelay);
}

extension MessageMatchers on Message {
  bool matchesTest(Message other) {
    return id == other.id &&
        content == other.content &&
        senderId == other.senderId;
  }
}
