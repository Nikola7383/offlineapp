import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/models/message.dart';
import 'package:secure_event_app/ui/widgets/message_bubble.dart';
import 'package:intl/intl.dart';

void main() {
  group('MessageBubble Widget Tests', () {
    testWidgets('should display message content and time', (tester) async {
      // Arrange
      final message = Message(
        id: '1',
        content: 'Test message',
        senderId: 'user1',
        timestamp: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: message,
              isMe: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test message'), findsOneWidget);
      expect(
        find.text(DateFormat('HH:mm').format(message.timestamp)),
        findsOneWidget,
      );
    });

    testWidgets('should align correctly based on isMe', (tester) async {
      // Arrange
      final message = Message(
        id: '1',
        content: 'Test message',
        senderId: 'user1',
        timestamp: DateTime.now(),
      );

      // Act - Test for my message (right aligned)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: message,
              isMe: true,
            ),
          ),
        ),
      );

      // Assert
      final alignRight = tester.widget<Align>(find.byType(Align));
      expect(alignRight.alignment, equals(Alignment.centerRight));

      // Act - Test for other's message (left aligned)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: message,
              isMe: false,
            ),
          ),
        ),
      );

      // Assert
      final alignLeft = tester.widget<Align>(find.byType(Align));
      expect(alignLeft.alignment, equals(Alignment.centerLeft));
    });
  });
}
