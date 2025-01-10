import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/models/process_stats.dart';

void main() {
  group('ProcessStats', () {
    test('should create instance with required parameters', () {
      final now = DateTime.now();
      final stats = ProcessStats(
        cpuUsage: 50.0,
        memoryUsageMb: 100.0,
        threadCount: 5,
        openFileCount: 10,
        networkConnectionCount: 3,
        timestamp: now,
      );

      expect(stats.cpuUsage, equals(50.0));
      expect(stats.memoryUsageMb, equals(100.0));
      expect(stats.threadCount, equals(5));
      expect(stats.openFileCount, equals(10));
      expect(stats.networkConnectionCount, equals(3));
      expect(stats.timestamp, equals(now));
    });

    test('should create copy with updated values', () {
      final now = DateTime.now();
      final stats = ProcessStats(
        cpuUsage: 50.0,
        memoryUsageMb: 100.0,
        threadCount: 5,
        openFileCount: 10,
        networkConnectionCount: 3,
        timestamp: now,
      );

      final updated = stats.copyWith(
        cpuUsage: 75.0,
        memoryUsageMb: 200.0,
        threadCount: 8,
      );

      expect(updated.cpuUsage, equals(75.0));
      expect(updated.memoryUsageMb, equals(200.0));
      expect(updated.threadCount, equals(8));
      expect(updated.openFileCount, equals(stats.openFileCount));
      expect(
          updated.networkConnectionCount, equals(stats.networkConnectionCount));
      expect(updated.timestamp, equals(stats.timestamp));
    });

    test('should implement equality correctly', () {
      final now = DateTime.now();
      final stats1 = ProcessStats(
        cpuUsage: 50.0,
        memoryUsageMb: 100.0,
        threadCount: 5,
        openFileCount: 10,
        networkConnectionCount: 3,
        timestamp: now,
      );

      final stats2 = ProcessStats(
        cpuUsage: 50.0,
        memoryUsageMb: 100.0,
        threadCount: 5,
        openFileCount: 10,
        networkConnectionCount: 3,
        timestamp: now,
      );

      final stats3 = ProcessStats(
        cpuUsage: 75.0,
        memoryUsageMb: 200.0,
        threadCount: 8,
        openFileCount: 15,
        networkConnectionCount: 5,
        timestamp: now,
      );

      expect(stats1, equals(stats2));
      expect(stats1.hashCode, equals(stats2.hashCode));
      expect(stats1, isNot(equals(stats3)));
      expect(stats1.hashCode, isNot(equals(stats3.hashCode)));
    });

    test('should convert to string correctly', () {
      final now = DateTime.now();
      final stats = ProcessStats(
        cpuUsage: 50.0,
        memoryUsageMb: 100.0,
        threadCount: 5,
        openFileCount: 10,
        networkConnectionCount: 3,
        timestamp: now,
      );

      expect(
        stats.toString(),
        equals(
            'ProcessStats{cpuUsage: 50.0, memoryUsageMb: 100.0, threadCount: 5, openFileCount: 10, networkConnectionCount: 3, timestamp: $now}'),
      );
    });
  });
}
