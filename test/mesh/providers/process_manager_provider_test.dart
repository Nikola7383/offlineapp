import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/models/process_info.dart';
import 'package:secure_event_app/mesh/models/process_key.dart';
import 'package:secure_event_app/mesh/process/process_manager.dart';
import 'package:secure_event_app/mesh/providers/process_manager_provider.dart';

void main() {
  group('ProcessManagerProvider', () {
    late ProviderContainer container;
    late String nodeId;

    setUp(() {
      container = ProviderContainer();
      nodeId = 'test-node';
    });

    tearDown(() {
      container.dispose();
    });

    test('should provide ProcessManager instance', () {
      final manager = container.read(processManagerProvider);
      expect(manager, isA<ProcessManager>());
    });

    test('should manage active processes', () async {
      final manager = container.read(processManagerProvider);

      // Start process
      await manager.startProcess(
        nodeId,
        'test_process',
        ProcessPriority.normal,
      );

      var processes = await manager.getActiveProcesses(nodeId);
      expect(processes.length, 1);
      expect(processes.first.name, 'test_process');
      expect(processes.first.status, ProcessStatus.running);

      // Stop process
      final key = ProcessKey(
        nodeId: nodeId,
        processId: processes.first.id,
      );
      await manager.stopProcess(key);

      processes = await manager.getActiveProcesses(nodeId);
      expect(processes.isEmpty, true);
    });

    test('should manage process states', () async {
      final manager = container.read(processManagerProvider);

      // Start process
      await manager.startProcess(
        nodeId,
        'test_process',
        ProcessPriority.normal,
      );

      var processes = await manager.getActiveProcesses(nodeId);
      final key = ProcessKey(
        nodeId: nodeId,
        processId: processes.first.id,
      );

      // Pause process
      await manager.pauseProcess(key);
      processes = await manager.getActiveProcesses(nodeId);
      expect(processes.first.status, ProcessStatus.paused);

      // Resume process
      await manager.resumeProcess(key);
      processes = await manager.getActiveProcesses(nodeId);
      expect(processes.first.status, ProcessStatus.running);
    });

    test('should handle multiple processes', () async {
      final manager = container.read(processManagerProvider);

      // Start multiple processes
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

      var processes = await manager.getActiveProcesses(nodeId);
      expect(processes.length, 2);
      expect(
        processes.map((p) => p.name),
        containsAll(['test_process_1', 'test_process_2']),
      );
    });

    test('should filter processes by node id', () async {
      final manager = container.read(processManagerProvider);

      // Start processes on different nodes
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

      var processes = await manager.getActiveProcesses(nodeId);
      expect(processes.length, 1);
      expect(processes.first.name, 'test_process_1');

      processes = await manager.getActiveProcesses('other-node');
      expect(processes.length, 1);
      expect(processes.first.name, 'test_process_2');
    });
  });
}
