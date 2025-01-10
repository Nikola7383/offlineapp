import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/models/process_info.dart';

void main() {
  group('ProcessInfo', () {
    test('should create instance with required parameters', () {
      final now = DateTime.now();
      final process = ProcessInfo(
        id: 'test-id',
        name: 'test-process',
        status: ProcessStatus.running,
        priority: ProcessPriority.normal,
        startTime: now,
        lastUpdateTime: now,
      );

      expect(process.id, equals('test-id'));
      expect(process.name, equals('test-process'));
      expect(process.status, equals(ProcessStatus.running));
      expect(process.priority, equals(ProcessPriority.normal));
      expect(process.startTime, equals(now));
      expect(process.lastUpdateTime, equals(now));
      expect(process.cpuUsage, equals(0.0));
      expect(process.memoryUsageMb, equals(0.0));
      expect(process.threadCount, equals(0));
      expect(process.openFileCount, equals(0));
      expect(process.networkConnectionCount, equals(0));
    });

    test('should create instance with all parameters', () {
      final now = DateTime.now();
      final process = ProcessInfo(
        id: 'test-id',
        name: 'test-process',
        status: ProcessStatus.running,
        priority: ProcessPriority.normal,
        startTime: now,
        lastUpdateTime: now,
        cpuUsage: 50.0,
        memoryUsageMb: 100.0,
        threadCount: 5,
        openFileCount: 10,
        networkConnectionCount: 3,
      );

      expect(process.cpuUsage, equals(50.0));
      expect(process.memoryUsageMb, equals(100.0));
      expect(process.threadCount, equals(5));
      expect(process.openFileCount, equals(10));
      expect(process.networkConnectionCount, equals(3));
    });

    test('should check if process is active', () {
      final now = DateTime.now();
      final runningProcess = ProcessInfo(
        id: 'test-id',
        name: 'test-process',
        status: ProcessStatus.running,
        priority: ProcessPriority.normal,
        startTime: now,
        lastUpdateTime: now,
      );

      final pausedProcess = ProcessInfo(
        id: 'test-id',
        name: 'test-process',
        status: ProcessStatus.paused,
        priority: ProcessPriority.normal,
        startTime: now,
        lastUpdateTime: now,
      );

      final stoppedProcess = ProcessInfo(
        id: 'test-id',
        name: 'test-process',
        status: ProcessStatus.stopped,
        priority: ProcessPriority.normal,
        startTime: now,
        lastUpdateTime: now,
      );

      expect(runningProcess.isActive, isTrue);
      expect(pausedProcess.isActive, isTrue);
      expect(stoppedProcess.isActive, isFalse);
    });

    test('should create copy with updated values', () {
      final now = DateTime.now();
      final process = ProcessInfo(
        id: 'test-id',
        name: 'test-process',
        status: ProcessStatus.running,
        priority: ProcessPriority.normal,
        startTime: now,
        lastUpdateTime: now,
      );

      final updated = process.copyWith(
        status: ProcessStatus.paused,
        cpuUsage: 75.0,
        memoryUsageMb: 200.0,
      );

      expect(updated.id, equals(process.id));
      expect(updated.name, equals(process.name));
      expect(updated.status, equals(ProcessStatus.paused));
      expect(updated.priority, equals(process.priority));
      expect(updated.startTime, equals(process.startTime));
      expect(updated.cpuUsage, equals(75.0));
      expect(updated.memoryUsageMb, equals(200.0));
      expect(updated.threadCount, equals(process.threadCount));
      expect(updated.openFileCount, equals(process.openFileCount));
      expect(updated.networkConnectionCount,
          equals(process.networkConnectionCount));
    });

    test('should implement equality correctly', () {
      final now = DateTime.now();
      final process1 = ProcessInfo(
        id: 'test-id',
        name: 'test-process',
        status: ProcessStatus.running,
        priority: ProcessPriority.normal,
        startTime: now,
        lastUpdateTime: now,
      );

      final process2 = ProcessInfo(
        id: 'test-id',
        name: 'test-process',
        status: ProcessStatus.running,
        priority: ProcessPriority.normal,
        startTime: now,
        lastUpdateTime: now,
      );

      final process3 = ProcessInfo(
        id: 'different-id',
        name: 'test-process',
        status: ProcessStatus.running,
        priority: ProcessPriority.normal,
        startTime: now,
        lastUpdateTime: now,
      );

      expect(process1, equals(process2));
      expect(process1.hashCode, equals(process2.hashCode));
      expect(process1, isNot(equals(process3)));
      expect(process1.hashCode, isNot(equals(process3.hashCode)));
    });

    test('should convert to string correctly', () {
      final now = DateTime.now();
      final process = ProcessInfo(
        id: 'test-id',
        name: 'test-process',
        status: ProcessStatus.running,
        priority: ProcessPriority.normal,
        startTime: now,
        lastUpdateTime: now,
      );

      expect(
        process.toString(),
        equals(
            'ProcessInfo{id: test-id, name: test-process, status: ProcessStatus.running, priority: ProcessPriority.normal}'),
      );
    });
  });
}
