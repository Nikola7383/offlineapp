import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../lib/mesh/models/node.dart';
import '../../lib/mesh/models/protocol_manager.dart';

// Generisanje mock klasa
@GenerateMocks([ProtocolManager])
import 'node_test.mocks.dart';

void main() {
  late Node node;
  late MockProtocolManager bluetoothManager;
  late MockProtocolManager wifiDirectManager;
  late MockProtocolManager soundManager;

  setUp(() {
    bluetoothManager = MockProtocolManager();
    wifiDirectManager = MockProtocolManager();
    soundManager = MockProtocolManager();

    node = Node(
      'test_node',
      batteryLevel: 1.0,
      signalStrength: 1.0,
      managers: {
        Protocol.bluetooth: bluetoothManager,
        Protocol.wifiDirect: wifiDirectManager,
        Protocol.sound: soundManager,
      },
    );
  });

  group('Node Offline Discovery Tests', () {
    test('Should discover neighbors across all protocols', () async {
      // Arrange
      final mockBluetoothNeighbor =
          Node('bt_neighbor', batteryLevel: 0.8, signalStrength: 0.7);
      final mockWifiNeighbor =
          Node('wifi_neighbor', batteryLevel: 0.9, signalStrength: 0.8);

      when(bluetoothManager.scanForDevices())
          .thenAnswer((_) async => [mockBluetoothNeighbor]);
      when(wifiDirectManager.scanForDevices())
          .thenAnswer((_) async => [mockWifiNeighbor]);
      when(soundManager.scanForDevices()).thenAnswer((_) async => []);

      // Act
      final neighbors = await node.getNeighbors();

      // Assert
      expect(neighbors, contains(mockBluetoothNeighbor));
      expect(neighbors, contains(mockWifiNeighbor));
      expect(neighbors.length, equals(2));

      verify(bluetoothManager.scanForDevices()).called(1);
      verify(wifiDirectManager.scanForDevices()).called(1);
      verify(soundManager.scanForDevices()).called(1);
    });

    test('Should handle failed protocols gracefully', () async {
      // Arrange
      when(bluetoothManager.scanForDevices())
          .thenThrow(Exception('Bluetooth failed'));
      when(wifiDirectManager.scanForDevices()).thenAnswer((_) async => []);
      when(soundManager.scanForDevices()).thenAnswer((_) async => []);

      // Act & Assert
      expect(() => node.getNeighbors(), returnsNormally);
    });

    test('Should update connection strength correctly', () async {
      // Arrange
      final nodeId = 'test_connection';
      final strength = 0.8;

      // Act
      await node.updateConnectionStrength(nodeId, strength);

      // Assert
      expect(node.connections[nodeId]?.strength, equals(strength));
      expect(node.connections[nodeId]?.isActive, isTrue);
    });

    test('Should clean up inactive connections', () async {
      // Arrange
      final nodeId = 'old_connection';
      await node.updateConnectionStrength(nodeId, 0.8);

      // Simulate time passing
      await Future.delayed(Duration(milliseconds: 100));

      // Act
      final activeConnections = node.getActiveConnections();

      // Assert
      expect(activeConnections, isEmpty);
    });
  });
}
