import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/models/process_info.dart';
import 'package:secure_event_app/mesh/models/process_key.dart';
import 'package:secure_event_app/mesh/models/process_stats.dart';
import 'package:secure_event_app/mesh/process/process_manager.dart';
import 'package:secure_event_app/mesh/process/process_stats_collector.dart';

void main() {
  group('ProcessStatsCollector', () {
    late ProcessManager manager;
    late ProcessStatsCollector collector;
    late String nodeId;

    setUp(() {
      manager = ProcessManager();
      collector = ProcessStatsCollector(manager: manager);
      nodeId = 'test-node';
    });

    tearDown(() {
      collector.dispose();
      manager.dispose();
    });

    test('should collect stats for active processes', () async {
      await manager.startProcess(
        nodeId,
        'test_process',
        ProcessPriority.normal,
      );

      final stats = <Map<ProcessKey, ProcessStats>>[];
      final subscription = collector.stats.listen((s) => stats.add(s));

      collector.start();

      // Sačekaj da se prikupe statistike
      await Future.delayed(const Duration(milliseconds: 250));

      subscription.cancel();
      collector.stop();

      expect(stats.length, greaterThan(1));
      expect(stats.first.length, 1);

      final firstStats = stats.first.values.first;
      expect(firstStats.cpuUsage, greaterThanOrEqualTo(0));
      expect(firstStats.cpuUsage, lessThanOrEqualTo(100));
      expect(firstStats.memoryUsageMb, greaterThan(0));
      expect(firstStats.threadCount, greaterThan(0));
      expect(firstStats.openFileCount, greaterThanOrEqualTo(0));
      expect(firstStats.networkConnectionCount, greaterThanOrEqualTo(0));
    });

    test('should not collect stats for stopped processes', () async {
      await manager.startProcess(
        nodeId,
        'test_process',
        ProcessPriority.normal,
      );

      final processes = await manager.getActiveProcesses(nodeId);
      final key = ProcessKey(
        nodeId: nodeId,
        processId: processes.first.id,
      );

      await manager.stopProcess(key);

      final stats = <Map<ProcessKey, ProcessStats>>[];
      final subscription = collector.stats.listen((s) => stats.add(s));

      collector.start();

      // Sačekaj da se prikupe statistike
      await Future.delayed(const Duration(milliseconds: 250));

      subscription.cancel();
      collector.stop();

      expect(stats.length, greaterThan(1));
      expect(stats.every((s) => s.isEmpty), true);
    });

    test('should collect stats for multiple processes', () async {
      await manager.startProcess(
        nodeId,
        'test_process_1',
        ProcessPriority.normal,
      );

      await manager.startProcess(
        nodeId,
        'test_process_2',
        ProcessPriority.high,
      );

      final stats = <Map<ProcessKey, ProcessStats>>[];
      final subscription = collector.stats.listen((s) => stats.add(s));

      collector.start();

      // Sačekaj da se prikupe statistike
      await Future.delayed(const Duration(milliseconds: 250));

      subscription.cancel();
      collector.stop();

      expect(stats.length, greaterThan(1));
      expect(stats.first.length, 2);
    });

    test('should filter stats by node id', () async {
      await manager.startProcess(
        nodeId,
        'test_process_1',
        ProcessPriority.normal,
      );

      await manager.startProcess(
        'other-node',
        'test_process_2',
        ProcessPriority.high,
      );

      final stats = <Map<ProcessKey, ProcessStats>>[];
      final subscription = collector.stats.listen((s) => stats.add(s));

      collector.start();

      // Sačekaj da se prikupe statistike
      await Future.delayed(const Duration(milliseconds: 250));

      subscription.cancel();
      collector.stop();

      expect(stats.length, greaterThan(1));
      expect(stats.first.length, 1);
      expect(stats.first.keys.first.nodeId, nodeId);
    });
  });
}
