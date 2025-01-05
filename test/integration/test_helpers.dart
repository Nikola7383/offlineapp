import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/models/message.dart';
import 'package:secure_event_app/core/interfaces/message_handler.dart';

class MessageTestHelper {
  static Future<List<Message>> collectMessages(
    MessageHandler handler,
    int expectedCount, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final messages = <Message>[];
    final completer = Completer<List<Message>>();

    handler.messageStream.listen((message) {
      messages.add(message);
      if (messages.length >= expectedCount) {
        completer.complete(messages);
      }
    });

    return completer.future.timeout(
      timeout,
      onTimeout: () => messages,
    );
  }

  static Future<List<MessageStatus>> collectStatuses(
    MessageHandler handler,
    String messageId, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final statuses = <MessageStatus>[];
    final completer = Completer<List<MessageStatus>>();

    handler.messageStream.where((m) => m.id == messageId).listen((message) {
      statuses.add(message.status);
      if (message.status == MessageStatus.sent ||
          message.status == MessageStatus.failed) {
        completer.complete(statuses);
      }
    });

    return completer.future.timeout(
      timeout,
      onTimeout: () => statuses,
    );
  }
}
