import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/models/process_key.dart';

void main() {
  group('ProcessKey', () {
    test('should create instance with required parameters', () {
      final key = ProcessKey(
        nodeId: 'test-node',
        processId: 'test-process',
      );

      expect(key.nodeId, equals('test-node'));
      expect(key.processId, equals('test-process'));
    });

    test('should implement equality correctly', () {
      final key1 = ProcessKey(
        nodeId: 'test-node',
        processId: 'test-process',
      );

      final key2 = ProcessKey(
        nodeId: 'test-node',
        processId: 'test-process',
      );

      final key3 = ProcessKey(
        nodeId: 'other-node',
        processId: 'test-process',
      );

      expect(key1, equals(key2));
      expect(key1.hashCode, equals(key2.hashCode));
      expect(key1, isNot(equals(key3)));
      expect(key1.hashCode, isNot(equals(key3.hashCode)));
    });

    test('should convert to string correctly', () {
      final key = ProcessKey(
        nodeId: 'test-node',
        processId: 'test-process',
      );

      expect(
        key.toString(),
        equals('ProcessKey{nodeId: test-node, processId: test-process}'),
      );
    });
  });
}
