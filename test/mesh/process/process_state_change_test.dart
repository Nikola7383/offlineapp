import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/models/process_info.dart';
import 'package:secure_event_app/mesh/process/process_manager.dart';

void main() {
  group('ProcessStateChange', () {
    test('should create process state change', () {
      const change = ProcessStateChange(
        nodeId: 'test-node',
        processId: 'test-process',
        status: ProcessStatus.running,
      );

      expect(change.nodeId, 'test-node');
      expect(change.processId, 'test-process');
      expect(change.status, ProcessStatus.running);
    });

    test('should create process state change for all statuses', () {
      for (final status in ProcessStatus.values) {
        final change = ProcessStateChange(
          nodeId: 'test-node',
          processId: 'test-process',
          status: status,
        );

        expect(change.status, status);
      }
    });

    test('should create process state change with different node ids', () {
      const nodeId1 = 'test-node-1';
      const nodeId2 = 'test-node-2';

      final change1 = ProcessStateChange(
        nodeId: nodeId1,
        processId: 'test-process',
        status: ProcessStatus.running,
      );

      final change2 = ProcessStateChange(
        nodeId: nodeId2,
        processId: 'test-process',
        status: ProcessStatus.running,
      );

      expect(change1.nodeId, nodeId1);
      expect(change2.nodeId, nodeId2);
    });

    test('should create process state change with different process ids', () {
      const processId1 = 'test-process-1';
      const processId2 = 'test-process-2';

      final change1 = ProcessStateChange(
        nodeId: 'test-node',
        processId: processId1,
        status: ProcessStatus.running,
      );

      final change2 = ProcessStateChange(
        nodeId: 'test-node',
        processId: processId2,
        status: ProcessStatus.running,
      );

      expect(change1.processId, processId1);
      expect(change2.processId, processId2);
    });
  });
}
