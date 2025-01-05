import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/batch/batch_operation_manager.dart';
import 'package:secure_event_app/core/models/message.dart';
import '../test_helper.dart';
import '../test_config.dart';
import '../test_bootstrap.dart';

void main() async {
  await bootstrapTests();

  late BatchOperationManager manager;
  late MockMeshNetwork mockMesh;
  late MockLoggerService mockLogger;

  setUp(() async {
    mockMesh = MockMeshNetwork();
    mockLogger = MockLoggerService();

    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.error(any, any)).thenAnswer((_) => Future.value());
    when(mockMesh.sendBatch(any)).thenAnswer((_) => Future.value());

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
}
