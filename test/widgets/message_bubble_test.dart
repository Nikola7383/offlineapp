import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/widgets/message_bubble.dart';

void main() {
  testWidgets('MessageBubble displays correct content', (tester) async {
    final message = Message(
      id: '1',
      content: 'Test message',
      sender: 'Test sender',
      timestamp: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: message,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test message'), findsOneWidget);
    expect(find.text('Test sender'), findsOneWidget);

    // Test tap interaction
    await tester.tap(find.byType(InkWell));
    await tester.pump();
  });

  testWidgets('MessageBubble shows unread indicator', (tester) async {
    final message = Message(
      id: '1',
      content: 'Test message',
      sender: 'Test sender',
      timestamp: DateTime.now(),
      read: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: message,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(
        find.byType(Container), findsNWidgets(3)); // Including unread indicator
  });
}
