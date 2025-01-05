import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:your_app/core/mesh/mesh_network.dart';

class MockNearbyConnections extends Mock implements Nearby {}

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late MeshNetwork meshNetwork;
  late MockNearbyConnections mockNearby;
  late MockLoggerService mockLogger;

  setUp(() {
    mockNearby = MockNearbyConnections();
    mockLogger = MockLoggerService();
    meshNetwork = MeshNetwork(logger: mockLogger);
  });

  group('MeshNetwork Tests', () {
    test('start should initialize advertising and discovery', () async {
      // Arrange
      when(mockNearby.startAdvertising(any, any)).thenAnswer((_) async => {});
      when(mockNearby.startDiscovery(any, any)).thenAnswer((_) async => {});

      // Act
      await meshNetwork.start();

      // Assert
      verify(mockNearby.startAdvertising(any, any)).called(1);
      verify(mockNearby.startDiscovery(any, any)).called(1);
    });

    test('broadcast should send message to all connected peers', () async {
      // Arrange
      final message = Message(
        id: '1',
        content: 'Test message',
        senderId: 'sender1',
        timestamp: DateTime.now(),
      );

      when(mockNearby.sendPayload(any, any)).thenAnswer((_) async => {});

      // Act
      final result = await meshNetwork.broadcast(message);

      // Assert
      expect(result, true);
      verify(mockNearby.sendPayload(any, any))
          .called(meshNetwork.connectedPeers.length);
    });
  });
}
