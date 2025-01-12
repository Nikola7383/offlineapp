import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/models/node.dart';
import '../../test_helper.dart';
import '../../test_helper.mocks.dart';

void main() {
  group('Node', () {
    late MockIMessageService messageService;

    setUp(() {
      messageService = MockIMessageService();
    });

    test('should create node with valid data', () {
      final node = Node(
        id: 'test_node',
        address: '192.168.1.1',
        port: 8080,
        isActive: true,
        batteryLevel: 0.8,
        type: NodeType.standard,
        lastSeen: DateTime.now(),
        status: NodeStatus.active,
      );

      expect(node.id, equals('test_node'));
      expect(node.address, equals('192.168.1.1'));
      expect(node.port, equals(8080));
      expect(node.isActive, isTrue);
      expect(node.batteryLevel, equals(0.8));
      expect(node.type, equals(NodeType.standard));
      expect(node.status, equals(NodeStatus.active));
    });

    test('should update last seen time', () {
      final initialTime = DateTime.now();
      final node = Node(
        id: 'test_node',
        address: '192.168.1.1',
        port: 8080,
        isActive: true,
        batteryLevel: 0.8,
        type: NodeType.standard,
        lastSeen: initialTime,
        status: NodeStatus.active,
      );

      final newTime = DateTime.now().add(const Duration(minutes: 5));
      node.updateLastSeen(newTime);

      expect(node.lastSeen, equals(newTime));
    });

    test('should update status', () {
      final node = Node(
        id: 'test_node',
        address: '192.168.1.1',
        port: 8080,
        isActive: true,
        batteryLevel: 0.8,
        type: NodeType.standard,
        lastSeen: DateTime.now(),
        status: NodeStatus.active,
      );

      node.updateStatus(NodeStatus.inactive);

      expect(node.status, equals(NodeStatus.inactive));
    });

    test('should calculate time since last seen', () {
      final lastSeen = DateTime.now().subtract(const Duration(minutes: 5));
      final node = Node(
        id: 'test_node',
        address: '192.168.1.1',
        port: 8080,
        isActive: true,
        batteryLevel: 0.8,
        type: NodeType.standard,
        lastSeen: lastSeen,
        status: NodeStatus.active,
      );

      final timeSinceLastSeen = node.getTimeSinceLastSeen();

      expect(timeSinceLastSeen.inMinutes, greaterThanOrEqualTo(4));
      expect(timeSinceLastSeen.inMinutes, lessThanOrEqualTo(6));
    });

    test('should be equal when ids match', () {
      final node1 = Node(
        id: 'test_node',
        address: '192.168.1.1',
        port: 8080,
        isActive: true,
        batteryLevel: 0.8,
        type: NodeType.standard,
        lastSeen: DateTime.now(),
        status: NodeStatus.active,
      );

      final node2 = Node(
        id: 'test_node',
        address: '192.168.1.2',
        port: 8081,
        isActive: false,
        batteryLevel: 0.5,
        type: NodeType.relay,
        lastSeen: DateTime.now(),
        status: NodeStatus.inactive,
      );

      expect(node1, equals(node2));
      expect(node1.hashCode, equals(node2.hashCode));
    });
  });
}
