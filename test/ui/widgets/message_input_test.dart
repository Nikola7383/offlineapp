import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/bloc/chat_bloc.dart';
import 'package:secure_event_app/ui/widgets/message_input.dart';

class MockChatBloc extends Mock implements ChatBloc {}

void main() {
  late MockChatBloc mockChatBloc;

  setUp(() {
    mockChatBloc = MockChatBloc();
  });

  group('MessageInput Widget Tests', () {
    testWidgets('should enable send button when text is entered',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: const Scaffold(
              body: MessageInput(),
            ),
          ),
        ),
      );

      // Initial state - button should be disabled
      final initialSendButton = find.byIcon(Icons.send);
      expect(
        tester.widget<IconButton>(initialSendButton).onPressed,
        isNull,
      );

      // Act - enter text
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pump();

      // Assert - button should be enabled
      final enabledSendButton = find.byIcon(Icons.send);
      expect(
        tester.widget<IconButton>(enabledSendButton).onPressed,
        isNotNull,
      );
    });

    testWidgets('should send message when submitted', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: const Scaffold(
              body: MessageInput(),
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Assert
      verify(mockChatBloc.add(any)).called(1);
      expect(
          find.text('Test message'), findsNothing); // Input should be cleared
    });
  });
}
