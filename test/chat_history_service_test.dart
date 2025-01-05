import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/services/chat_history_service.dart';
import 'dart:io';

void main() {
  late ChatHistoryService chatService;

  setUp(() {
    chatService = ChatHistoryService();
  });

  tearDown(() async {
    await chatService.clearHistory();
  });

  group('ChatHistoryService Tests', () {
    test('Save and retrieve message', () async {
      // Arrange
      const testMessage = 'Test message';

      // Act
      await chatService.saveMessage(testMessage, true);
      final messages = chatService.getMessages();

      // Assert
      expect(messages.length, 1);
      expect(messages.first.content, testMessage);
      expect(messages.first.isUser, true);
    });

    test('Search messages', () async {
      // Arrange
      await chatService.saveMessage('Hello world', true);
      await chatService.saveMessage('Testing search', true);

      // Act
      final results = chatService.searchMessages('world');

      // Assert
      expect(results.length, 1);
      expect(results.first.content, 'Hello world');
    });

    test('Filter by date', () async {
      // Arrange
      final now = DateTime.now();
      await chatService.saveMessage('Today message', true);

      // Act
      final messages = chatService.getTodayMessages();

      // Assert
      expect(messages.length, 1);
      expect(messages.first.content, 'Today message');
    });

    test('Encryption and decryption', () async {
      // Arrange
      const secretMessage = 'Secret message';

      // Act
      await chatService.saveMessage(secretMessage, true);
      final fileContent = await chatService.getFileContent();

      // Assert
      expect(fileContent.contains(secretMessage), false); // Should be encrypted

      // Verify we can still read it
      final messages = chatService.getMessages();
      expect(messages.first.content, secretMessage);
    });

    test('Backup and restore', () async {
      // Arrange
      await chatService.saveMessage('Original message', true);

      // Act
      await chatService.createBackup();
      await chatService.clearHistory();
      await chatService.restoreFromBackup();

      // Assert
      final messages = chatService.getMessages();
      expect(messages.length, 1);
      expect(messages.first.content, 'Original message');
    });
  });
}
