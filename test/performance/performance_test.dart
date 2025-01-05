import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/services/service_registry.dart';
import 'package:secure_event_app/core/interfaces/message_handler.dart';
import 'package:secure_event_app/core/models/message.dart';
import '../core/test_setup.dart';
import 'performance_metrics.dart';

void main() {
  late ServiceRegistry registry;
  late MessageHandler messageHandler;
  late PerformanceMetrics metrics;

  setUp(() async {
    registry = ServiceRegistry.instance;
    await registry.initialize();
    messageHandler = registry.get<MessageHandler>();
    metrics = PerformanceMetrics();
  });

  tearDown(() async {
    await registry.dispose();
    await metrics.saveReport();
  });

  group('Performance Tests', () {
    test('message processing throughput', () async {
      // Arrange
      const messageCount = 1000;
      final messages = TestSetup.createTestBatch(size: messageCount);
      final stopwatch = Stopwatch()..start();

      // Act
      await messageHandler.handleBatch(messages);
      await metrics.waitForProcessing(messageHandler, messageCount);
      stopwatch.stop();

      // Assert & Record Metrics
      final throughput = messageCount / stopwatch.elapsedMilliseconds * 1000;
      metrics.recordMetric(
        'message_throughput',
        throughput,
        'messages/second',
      );

      expect(throughput, greaterThan(100)); // At least 100 msgs/sec
    });

    test('memory usage under load', () async {
      // Arrange
      const batchSize = 10000;
      final messages = TestSetup.createTestBatch(size: batchSize);

      // Act & Measure
      final memoryBefore = await metrics.getCurrentMemoryUsage();
      await messageHandler.handleBatch(messages);
      await metrics.waitForProcessing(messageHandler, batchSize);
      final memoryAfter = await metrics.getCurrentMemoryUsage();

      // Assert & Record Metrics
      final memoryPerMessage = (memoryAfter - memoryBefore) / batchSize;
      metrics.recordMetric(
        'memory_per_message',
        memoryPerMessage,
        'bytes/message',
      );

      expect(memoryPerMessage, lessThan(1000)); // Less than 1KB per message
    });

    test('concurrent processing efficiency', () async {
      // Arrange
      const concurrentBatches = 5;
      const messagesPerBatch = 200;
      final stopwatch = Stopwatch()..start();

      // Act
      final futures = List.generate(concurrentBatches, (i) {
        final batch = TestSetup.createTestBatch(
          size: messagesPerBatch,
          prefix: 'batch_${i}_',
        );
        return messageHandler.handleBatch(batch);
      });

      await Future.wait(futures);
      await metrics.waitForProcessing(
        messageHandler,
        concurrentBatches * messagesPerBatch,
      );
      stopwatch.stop();

      // Assert & Record Metrics
      final totalMessages = concurrentBatches * messagesPerBatch;
      final throughput = totalMessages / stopwatch.elapsedMilliseconds * 1000;
      metrics.recordMetric(
        'concurrent_throughput',
        throughput,
        'messages/second',
      );

      expect(throughput, greaterThan(50)); // At least 50 msgs/sec under load
    });

    test('message size impact', () async {
      // Arrange
      const messageCount = 100;
      const contentSizes = [10, 100, 1000, 10000]; // bytes
      final results = <int, double>{};

      // Act
      for (final size in contentSizes) {
        final messages = List.generate(
          messageCount,
          (i) => TestSetup.createTestMessage(
            content: 'A' * size,
            id: 'size_${size}_msg_$i',
          ),
        );

        final stopwatch = Stopwatch()..start();
        await messageHandler.handleBatch(messages);
        await metrics.waitForProcessing(messageHandler, messageCount);
        stopwatch.stop();

        results[size] = messageCount / stopwatch.elapsedMilliseconds * 1000;
      }

      // Assert & Record Metrics
      results.forEach((size, throughput) {
        metrics.recordMetric(
          'throughput_size_$size',
          throughput,
          'messages/second',
        );
      });

      // Verify degradation is not too severe
      final maxDegradation =
          results[contentSizes.first]! * 0.1; // Allow 90% degradation
      expect(results[contentSizes.last], greaterThan(maxDegradation));
    });
  });
}
