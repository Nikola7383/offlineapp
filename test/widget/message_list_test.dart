import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/models/message.dart';
import 'package:secure_event_app/core/services/service_locator.dart';
import 'package:secure_event_app/ui/widgets/message_list.dart';
import 'package:secure_event_app/ui/widgets/message_tile.dart';

void main() {
  setUp(() async {
    await ServiceLocator.instance.initialize();
  });

  tearDown(() async {
    await ServiceLocator.instance.dispose();
  });

  group('MessageList Widget', () {
    testWidgets('displays messages in offline mode', (tester) async {
      // Add test messages
      final messages = List.generate(
        3,
        (i) => Message(
          id: 'test_msg_$i',
          content: 'Test message $i',
          senderId: 'test_sender',
          timestamp: DateTime.now(),
          status: MessageStatus.pending,
        ),
      );

      for (final msg in messages) {
        await ServiceLocator.instance.get<IStorageService>().saveMessage(msg);
      }

      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MessageList(),
          ),
        ),
      );

      // Verify messages are displayed
      expect(find.byType(MessageTile), findsNWidgets(3));
      expect(find.text('Test message 0'), findsOneWidget);
      expect(find.text('Test message 1'), findsOneWidget);
      expect(find.text('Test message 2'), findsOneWidget);
    });

    testWidgets('shows sync status for messages', (tester) async {
      // Add a test message
      final message = Message(
        id: 'sync_test_1',
        content: 'Sync test message',
        senderId: 'test_sender',
        timestamp: DateTime.now(),
        status: MessageStatus.pending,
      );

      await ServiceLocator.instance.get<IStorageService>().saveMessage(message);
      await ServiceLocator.instance.get<ISyncService>().queueMessage(message);

      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MessageList(),
          ),
        ),
      );

      // Verify pending status is shown
      expect(find.byIcon(Icons.pending), findsOneWidget);

      // Simulate successful sync
      await ServiceLocator.instance.get<ISyncService>().sync();
      await tester.pump();

      // Verify status is updated
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
