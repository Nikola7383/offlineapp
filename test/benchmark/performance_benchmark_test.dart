import 'package:flutter_test/flutter_test.dart';
import 'package:benchmark/benchmark.dart';
import 'package:your_app/main.dart';

void main() {
  group('Performance Benchmark Tests', () {
    test('Message Processing Speed', () async {
      final benchmark = PerformanceBenchmark();
      
      // 1. Benchmark slanja poruka
      final messagingSpeed = await benchmark.measure(() async {
        for (var i = 0; i < 1000; i++) {
          await messageService.sendMessage('Benchmark message $i', 'sender1');
        }
      });

      expect(messagingSpeed.operationsPerSecond, greaterThan(100));
      expect(messagingSpeed.averageLatency, lessThan(const Duration(milliseconds: 10)));

      // 2. Benchmark mesh propagacije
      final meshSpeed = await benchmark.measure(() async {
        await meshNetwork.propagateToAllPeers(TestMessage.large());
      });

      expect(meshSpeed.throughput, greaterThan(5 * 1024 * 1024)); // Min 5MB/s
      expect(meshSpeed.propagationDelay, lessThan(const Duration(milliseconds: 100)));

      // 3. Benchmark enkripcije
      final encryptionSpeed = await benchmark.measure(() async {
        await encryptionService.encryptBatch(TestMessage.batch(1000));
      });

      expect(encryptionSpeed.operationsPerSecond, greaterThan(1000));
    });

    test('Database Performance', () async {
      final benchmark = DatabaseBenchmark();
      
      // 1. Write performance
      final writeSpeed = await benchmark.measureWrites(
        operations: 10000,
        messageSize: 1024, // 1KB
      );

      expect(writeSpeed.writesPerSecond, greaterThan(1000));
      expect(writeSpeed.averageLatency, lessThan(const Duration(milliseconds: 5)));

      // 2. Read performance
      final readSpeed = await benchmark.measureReads(
        operations: 10000,
        randomAccess: true,
      );

      expect(readSpeed.readsPerSecond, greaterThan(5000));
      expect(readSpeed.queryLatency, lessThan(const Duration(milliseconds: 2)));
    });

    test('UI Rendering Performance', () async {
      final benchmark = UIBenchmark();
      
      // 1. Message list scrolling
      final scrollPerformance = await benchmark.measureScrolling(
        itemCount: 1000,
        scrollDuration: const Duration(seconds: 5),
      );

      expect(scrollPerformance.framesDropped, lessThan(5));
      expect(scrollPerformance.averageFPS, greaterThanOrEqualTo(58));

      // 2. Message composition
      final compositionPerformance = await benchmark.measureComposition(
        messageLength: 1000,
        withAttachments: true,
      );

      expect(compositionPerformance.inputLatency, lessThan(const Duration(milliseconds: 16)));
    });
  });
} 