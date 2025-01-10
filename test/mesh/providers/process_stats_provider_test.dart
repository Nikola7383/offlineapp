import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/models/process_info.dart';
import 'package:secure_event_app/mesh/models/process_key.dart';
import 'package:secure_event_app/mesh/models/process_stats.dart';
import 'package:secure_event_app/mesh/process/process_manager.dart';
import 'package:secure_event_app/mesh/providers/process_manager_provider.dart';
import 'package:secure_event_app/mesh/providers/process_stats_provider.dart';

void main() {
  group('ProcessStatsProvider', () {
    late ProviderContainer container;
    late String nodeId;

    setUp(() {
      container = ProviderContainer();
      nodeId = 'test-node';
    });

    tearDown(() {
      container.dispose();
    });

    test('should provide stats for active processes', () async {
      final manager = container.read(processManagerProvider);
      await manager.startProcess(
        nodeId,
        'test_process',
        ProcessPriority.normal,
      );

      final stats = <Map<ProcessKey, ProcessStats>>[];
      final subscription = container.listen(processStatsProvider(nodeId),
          (_, next) => stats.add(next.value ?? {}));

      // Sačekaj da se prikupe statistike
      await Future.delayed(const Duration(milliseconds: 250));

      subscription.close();

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

    test('should not provide stats for stopped processes', () async {
      final manager = container.read(processManagerProvider);
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
      final subscription = container.listen(processStatsProvider(nodeId),
          (_, next) => stats.add(next.value ?? {}));

      // Sačekaj da se prikupe statistike
      await Future.delayed(const Duration(milliseconds: 250));

      subscription.close();

      expect(stats.length, greaterThan(1));
      expect(stats.every((s) => s.isEmpty), true);
    });

    test('should provide stats for multiple processes', () async {
      final manager = container.read(processManagerProvider);
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
      final subscription = container.listen(processStatsProvider(nodeId),
          (_, next) => stats.add(next.value ?? {}));

      // Sačekaj da se prikupe statistike
      await Future.delayed(const Duration(milliseconds: 250));

      subscription.close();

      expect(stats.length, greaterThan(1));
      expect(stats.first.length, 2);
    });

    test('should filter stats by node id', () async {
      final manager = container.read(processManagerProvider);
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
      final subscription = container.listen(processStatsProvider(nodeId),
          (_, next) => stats.add(next.value ?? {}));

      // Sačekaj da se prikupe statistike
      await Future.delayed(const Duration(milliseconds: 250));

      subscription.close();

      expect(stats.length, greaterThan(1));
      expect(stats.first.length, 1);
      expect(stats.first.keys.first.nodeId, nodeId);
    });
  });
}
