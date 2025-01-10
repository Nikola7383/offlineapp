import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/models/process_info.dart';
import 'package:secure_event_app/mesh/models/process_key.dart';
import 'package:secure_event_app/mesh/models/process_state_change.dart';

void main() {
  group('ProcessStateChange', () {
    test('should create instance with required parameters', () {
      final now = DateTime.now();
      final key = ProcessKey(
        nodeId: 'test-node',
        processId: 'test-process',
      );

      final stateChange = ProcessStateChange(
        key: key,
        oldStatus: ProcessStatus.running,
        newStatus: ProcessStatus.paused,
        timestamp: now,
      );

      expect(stateChange.key, equals(key));
      expect(stateChange.oldStatus, equals(ProcessStatus.running));
      expect(stateChange.newStatus, equals(ProcessStatus.paused));
      expect(stateChange.timestamp, equals(now));
    });

    test('should implement equality correctly', () {
      final now = DateTime.now();
      final key = ProcessKey(
        nodeId: 'test-node',
        processId: 'test-process',
      );

      final stateChange1 = ProcessStateChange(
        key: key,
        oldStatus: ProcessStatus.running,
        newStatus: ProcessStatus.paused,
        timestamp: now,
      );

      final stateChange2 = ProcessStateChange(
        key: key,
        oldStatus: ProcessStatus.running,
        newStatus: ProcessStatus.paused,
        timestamp: now,
      );

      final stateChange3 = ProcessStateChange(
        key: ProcessKey(
          nodeId: 'other-node',
          processId: 'test-process',
        ),
        oldStatus: ProcessStatus.running,
        newStatus: ProcessStatus.paused,
        timestamp: now,
      );

      expect(stateChange1, equals(stateChange2));
      expect(stateChange1.hashCode, equals(stateChange2.hashCode));
      expect(stateChange1, isNot(equals(stateChange3)));
      expect(stateChange1.hashCode, isNot(equals(stateChange3.hashCode)));
    });

    test('should convert to string correctly', () {
      final now = DateTime.now();
      final key = ProcessKey(
        nodeId: 'test-node',
        processId: 'test-process',
      );

      final stateChange = ProcessStateChange(
        key: key,
        oldStatus: ProcessStatus.running,
        newStatus: ProcessStatus.paused,
        timestamp: now,
      );

      expect(
        stateChange.toString(),
        equals(
            'ProcessStateChange{key: ProcessKey{nodeId: test-node, processId: test-process}, oldStatus: ProcessStatus.running, newStatus: ProcessStatus.paused, timestamp: $now}'),
      );
    });
  });
}
