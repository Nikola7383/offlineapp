import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/models/process_info.dart';
import 'package:secure_event_app/mesh/process/process_manager.dart';

void main() {
  group('ProcessManager', () {
    late ProcessManager manager;
    late String nodeId;

    setUp(() {
      manager = ProcessManager();
      nodeId = 'test-node';
    });

    tearDown(() {
      manager.dispose();
    });

    test('should start process', () async {
      await manager.startProcess(
        nodeId,
        'test_process',
        ProcessPriority.normal,
      );

      final processes = await manager.getActiveProcesses(nodeId);
      expect(processes.length, 1);
      expect(processes.first.name, 'test_process');
      expect(processes.first.status, ProcessStatus.running);
      expect(processes.first.priority, ProcessPriority.normal);
    });

    test('should stop process', () async {
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

      final updatedProcesses = await manager.getActiveProcesses(nodeId);
      expect(updatedProcesses.isEmpty, true);
    });

    test('should pause process', () async {
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

      await manager.pauseProcess(key);

      final updatedProcesses = await manager.getActiveProcesses(nodeId);
      expect(updatedProcesses.first.status, ProcessStatus.paused);
    });

    test('should resume process', () async {
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

      await manager.pauseProcess(key);
      await manager.resumeProcess(key);

      final updatedProcesses = await manager.getActiveProcesses(nodeId);
      expect(updatedProcesses.first.status, ProcessStatus.running);
    });

    test('should emit state changes', () async {
      final stateChanges = <ProcessStateChange>[];
      final subscription = manager.processStateChanges.listen(stateChanges.add);

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

      await manager.pauseProcess(key);
      await manager.resumeProcess(key);
      await manager.stopProcess(key);

      await subscription.cancel();

      expect(stateChanges.length, 4);
      expect(stateChanges[0].status, ProcessStatus.running);
      expect(stateChanges[1].status, ProcessStatus.paused);
      expect(stateChanges[2].status, ProcessStatus.running);
      expect(stateChanges[3].status, ProcessStatus.stopped);
    });
  });
}
