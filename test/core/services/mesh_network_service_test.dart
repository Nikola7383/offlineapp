import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/interfaces/mesh_network_interface.dart';
import 'package:secure_event_app/core/services/mesh_network_service.dart';
import '../../test_helper.dart';
import '../../test_helper.mocks.dart';

void main() {
  group('MeshNetworkService', () {
    late MeshNetworkService service;
    late MockSecureStorage mockStorage;
    late MockILoggerService mockLogger;

    setUp(() {
      mockStorage = MockSecureStorage();
      mockLogger = MockILoggerService();
      service = MeshNetworkService(mockLogger, mockStorage);
    });

    test('should initialize service', () async {
      // Arrange
      when(mockStorage.read(any)).thenAnswer((_) => Future.value(null));

      // Act
      await service.initialize();

      // Assert
      expect(service.status, equals(MeshNetworkStatus.inactive));
      verify(mockLogger.info(any)).called(2);
    });

    test('should connect to network', () async {
      // Act
      await service.connect();

      // Assert
      expect(service.status, equals(MeshNetworkStatus.active));
      verify(mockLogger.info(any)).called(2);
    });

    test('should disconnect from network', () async {
      // Arrange
      await service.connect();

      // Act
      await service.disconnect();

      // Assert
      expect(service.status, equals(MeshNetworkStatus.inactive));
      verify(mockLogger.info(any)).called(4);
    });

    test('should send message to available node', () async {
      // Arrange
      const nodeId = 'test_node';
      await service.connect();

      // Act & Assert
      expect(
        () => service.sendMessage(
          'test message',
          recipientId: nodeId,
          connectionType: ConnectionType.direct,
        ),
        throwsException,
      );
    });

    test('should discover nodes', () async {
      // Arrange
      await service.connect();

      // Act
      final nodes = await service.discoverNodes();

      // Assert
      expect(nodes, isEmpty);
      verify(mockLogger.info(any)).called(3);
    });

    test('should check node availability', () async {
      // Arrange
      const nodeId = 'test_node';
      await service.connect();

      // Act
      final isAvailable = await service.isNodeAvailable(nodeId);

      // Assert
      expect(isAvailable, isFalse);
    });

    test('should get node info', () async {
      // Arrange
      const nodeId = 'test_node';
      await service.connect();

      // Act
      final info = await service.getNodeInfo(nodeId);

      // Assert
      expect(info, isEmpty);
    });

    test('should get network stats', () async {
      // Arrange
      await service.connect();

      // Act
      final stats = await service.getNetworkStats();

      // Assert
      expect(stats, isNotEmpty);
      expect(stats['status'], equals(MeshNetworkStatus.active.toString()));
      expect(stats['activeNodes'], equals(0));
      expect(stats['totalMessages'], equals(0));
      expect(stats['uptime'], equals('0'));
    });

    test('should backup configuration', () async {
      // Arrange
      when(mockStorage.write(any, any)).thenAnswer((_) => Future.value());
      await service.connect();

      // Act
      await service.backupConfiguration();

      // Assert
      verify(mockStorage.write(any, any)).called(1);
      verify(mockLogger.info(any)).called(4);
    });

    test('should restore configuration', () async {
      // Arrange
      when(mockStorage.read(any)).thenAnswer((_) => Future.value(null));
      await service.connect();

      // Act
      await service.restoreConfiguration();

      // Assert
      verify(mockStorage.read(any)).called(1);
      verify(mockLogger.info(any)).called(3);
    });

    test('should report network issue', () async {
      // Arrange
      const nodeId = 'test_node';
      const issue = 'Connection lost';
      await service.connect();

      // Act
      await service.reportIssue(issue, nodeId: nodeId);

      // Assert
      verify(mockLogger.warning(any)).called(1);
    });

    test('should emit status changes', () async {
      // Arrange
      final statuses = <MeshNetworkStatus>[];
      service.statusStream.listen(statuses.add);

      // Act
      await service.connect();
      await service.disconnect();

      // Assert
      expect(statuses, [
        MeshNetworkStatus.initializing,
        MeshNetworkStatus.active,
        MeshNetworkStatus.inactive,
      ]);
    });

    test('should handle connection errors', () async {
      // Arrange
      when(mockLogger.error(any, any)).thenAnswer((_) => Future.value());

      // Act & Assert
      expect(
        () => service.sendMessage(
          'test message',
          recipientId: 'invalid_node',
          connectionType: ConnectionType.direct,
        ),
        throwsException,
      );
      verify(mockLogger.error(any, any)).called(1);
    });
  });
}
