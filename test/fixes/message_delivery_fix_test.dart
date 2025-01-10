void main() {
  group('MessageDeliveryFix Tests', () {
    late MessageDeliveryFix fix;
    late MockNetworkService mockNetwork;
    late MockMessageQueue mockQueue;

    setUp(() {
      mockNetwork = MockNetworkService();
      mockQueue = MockMessageQueue();
      fix = MessageDeliveryFix(
        network: mockNetwork,
        queue: mockQueue,
        logger: MockLogger(),
      );
    });

    test('should fix failed deliveries', () async {
      // Arrange
      final failedMessages = _createFailedMessages(100);
      when(mockQueue.getFailedMessages())
          .thenAnswer((_) async => failedMessages);

      // Act
      await fix.fixDeliveryIssues();

      // Assert
      verify(mockNetwork.sendWithResilience(any)).called(100);
      expect(fix.getFixedCount(), equals(100));
    });

    test('should handle redelivery failures gracefully', () async {
      // Arrange
      final message = _createFailedMessage();
      when(mockNetwork.sendWithResilience(any))
          .thenThrow(NetworkException('Failed'));

      // Act
      await fix.fixDeliveryIssues();

      // Assert
      verify(mockQueue.moveToDeadLetter(message)).called(1);
    });

    test('should prioritize older messages', () async {
      // Arrange
      final oldMessage = _createOldFailedMessage();
      final newMessage = _createNewFailedMessage();

      // Act
      await fix.fixDeliveryIssues();

      // Assert
      verifyInOrder([
        mockNetwork.sendWithResilience(oldMessage),
        mockNetwork.sendWithResilience(newMessage),
      ]);
    });
  });
}
