import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/bloc/chat_bloc.dart';
import 'package:secure_event_app/core/models/message.dart';
import 'package:secure_event_app/ui/screens/chat_screen.dart';

class MockChatBloc extends Mock implements ChatBloc {}

void main() {
  late MockChatBloc mockChatBloc;

  setUp(() {
    mockChatBloc = MockChatBloc();
  });

  group('ChatScreen Tests', () {
    testWidgets('should show loading indicator when loading', (tester) async {
      // Arrange
      when(mockChatBloc.state).thenReturn(ChatLoading());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: const ChatScreen(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show messages when loaded', (tester) async {
      // Arrange
      final messages = [
        Message(
          id: '1',
          content: 'Test message',
          senderId: 'user1',
          timestamp: DateTime.now(),
        ),
      ];

      when(mockChatBloc.state).thenReturn(ChatLoaded(messages: messages));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: const ChatScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('should show error when error occurs', (tester) async {
      // Arrange
      when(mockChatBloc.state).thenReturn(ChatError('Test error'));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: const ChatScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text('Error: Test error'), findsOneWidget);
    });
  });
}
