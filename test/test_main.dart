import 'test_imports.dart';

void main() {
  group('BatchOperationManager Tests', () {
    late BatchOperationManager manager;
    late MockMeshNetwork mockMesh;
    late MockLoggerService mockLogger;

    setUp(() async {
      await bootstrapTests();

      // Koristimo helper funkcije za kreiranje mockova
      mockMesh = getMockMeshNetwork();
      mockLogger = getMockLogger();

      manager = BatchOperationManager(
        meshNetwork: mockMesh,
        logger: mockLogger,
      );
    });

    tearDown(() async {
      manager.dispose();
      await tearDownTests();
    });

    test(
      'queues and processes messages in batches',
      () async {
        final messages = List.generate(
          TestConfig.batchSize,
          (i) => Message(
            id: 'test_$i',
            content: 'Test message $i',
            senderId: 'sender_1',
            timestamp: DateTime.now(),
          ),
        );

        for (final message in messages) {
          await manager.queueMessage(message);
        }

        await Future.delayed(TestConfig.messageProcessingDelay);

        verify(mockLogger.info(any))
            .called(greaterThanOrEqualTo(TestConfig.batchSize));
        verify(mockMesh.sendBatch(any)).called(1);
      },
      timeout: Timeout(TestConfig.timeout),
    );

    test(
      'handles send failures gracefully',
      () async {
        when(mockMesh.sendBatch(any)).thenThrow('Network error');

        await manager.queueMessage(
          Message(
            id: 'test_1',
            content: 'Test message',
            senderId: 'sender_1',
            timestamp: DateTime.now(),
          ),
        );

        await Future.delayed(TestConfig.messageProcessingDelay);

        verify(mockLogger.error(any, any)).called(1);
      },
      timeout: Timeout(TestConfig.timeout),
    );
  });
}
