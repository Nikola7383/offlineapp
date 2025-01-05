import 'dart:async';
import 'package:test/test.dart';
import '../../lib/mesh/mesh_network.dart';
import '../../lib/mesh/models/node.dart';
import '../../lib/mesh/models/protocol.dart';
import '../../lib/mesh/models/protocol_manager.dart';
import '../../lib/mesh/routing/mesh_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';

class MockProtocolManager implements ProtocolManager {
  final List<Node> _mockNodes;
  final bool _shouldFail;
  bool isListening = false;
  final List<String> receivedMessages = [];

  MockProtocolManager(this._mockNodes, {bool shouldFail = false})
      : _shouldFail = shouldFail;

  @override
  Future<List<Node>> scanForDevices() async {
    if (_shouldFail) return [];
    return List.from(_mockNodes);
  }

  @override
  Future<bool> sendData(String nodeId, List<int> data) async {
    if (_shouldFail) return false;
    receivedMessages.add('$nodeId: ${String.fromCharCodes(data)}');
    return true;
  }

  @override
  Future<void> startListening() async {
    if (_shouldFail) throw Exception('Failed to start listening');
    isListening = true;
  }

  @override
  Future<void> stopListening() async {
    isListening = false;
  }
}

void main() {
  late MeshNetwork mesh;

  setUp(() {
    mesh = MeshNetwork(
      logger: LoggerService(),
      deviceId: 'test_device',
    );
  });

  group('Mesh Network Tests', () {
    test('Should handle new peer connections', () async {
      // Act
      final result = await mesh.handleNewPeer('peer_1');

      // Assert
      expect(result, isTrue);
      expect(mesh.connectedPeers, contains('peer_1'));
    });

    test('Should handle peer disconnections', () async {
      // Arrange
      await mesh.handleNewPeer('peer_1');

      // Act
      await mesh.handlePeerDisconnection('peer_1');

      // Assert
      expect(mesh.connectedPeers, isEmpty);
    });

    test('Should broadcast messages to all peers', () async {
      // Arrange
      await mesh.handleNewPeer('peer_1');
      await mesh.handleNewPeer('peer_2');

      final message = Message(
        id: 'test_msg',
        content: 'Test content',
        timestamp: DateTime.now(),
      );

      // Act
      final result = await mesh.broadcast(message);

      // Assert
      expect(result, isTrue);
    });
  });
}
