import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/process/process_manager.dart';

void main() {
  group('ProcessKey', () {
    test('should create process key', () {
      const key = ProcessKey(
        nodeId: 'test-node',
        processId: 'test-process',
      );

      expect(key.nodeId, 'test-node');
      expect(key.processId, 'test-process');
    });

    test('should be equal when values are equal', () {
      const key1 = ProcessKey(
        nodeId: 'test-node',
        processId: 'test-process',
      );

      const key2 = ProcessKey(
        nodeId: 'test-node',
        processId: 'test-process',
      );

      expect(key1, equals(key2));
      expect(key1.hashCode, equals(key2.hashCode));
    });

    test('should not be equal when values are different', () {
      const key1 = ProcessKey(
        nodeId: 'test-node-1',
        processId: 'test-process-1',
      );

      const key2 = ProcessKey(
        nodeId: 'test-node-2',
        processId: 'test-process-2',
      );

      expect(key1, isNot(equals(key2)));
      expect(key1.hashCode, isNot(equals(key2.hashCode)));
    });

    test('should not be equal when nodeId is different', () {
      const key1 = ProcessKey(
        nodeId: 'test-node-1',
        processId: 'test-process',
      );

      const key2 = ProcessKey(
        nodeId: 'test-node-2',
        processId: 'test-process',
      );

      expect(key1, isNot(equals(key2)));
      expect(key1.hashCode, isNot(equals(key2.hashCode)));
    });

    test('should not be equal when processId is different', () {
      const key1 = ProcessKey(
        nodeId: 'test-node',
        processId: 'test-process-1',
      );

      const key2 = ProcessKey(
        nodeId: 'test-node',
        processId: 'test-process-2',
      );

      expect(key1, isNot(equals(key2)));
      expect(key1.hashCode, isNot(equals(key2.hashCode)));
    });
  });
}
