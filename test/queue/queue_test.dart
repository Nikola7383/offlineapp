void main() {
  group('OptimizedMessageQueue Tests', () {
    late OptimizedMessageQueue queue;
    late MockDatabase mockDb;
    late MockCompression mockCompression;

    setUp(() {
      mockDb = MockDatabase();
      mockCompression = MockCompression();
      queue = OptimizedMessageQueue(
        db: mockDb,
        compression: mockCompression,
        logger: MockLogger(),
      );
    });

    test('should handle high priority messages first', () async {
      // Arrange
      final highPriority = Message(priority: MessagePriority.high);
      final lowPriority = Message(priority: MessagePriority.low);

      // Act
      await queue.enqueue(lowPriority);
      await queue.enqueue(highPriority);

      // Assert
      final processed = await queue.getProcessedMessages();
      expect(processed.first.priority, equals(MessagePriority.high));
    });

    test('should compress messages before queuing', () async {
      // Arrange
      final message = Message(content: 'test');

      // Act
      await queue.enqueue(message);

      // Assert
      verify(mockCompression.compressMessage(message)).called(1);
    });

    test('should handle batch processing correctly', () async {
      // Arrange
      final messages = List.generate(150, (i) => Message(content: 'test_$i'));

      // Act
      for (final msg in messages) {
        await queue.enqueue(msg);
      }

      // Wait for batch processing
      await Future.delayed(Duration(milliseconds: 200));

      // Assert
      final metrics = queue.metrics;
      expect(metrics.batchesProcessed, equals(2));
      expect(metrics.totalProcessed, equals(150));
    });
  });
}
