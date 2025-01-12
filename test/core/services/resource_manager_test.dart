import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/interfaces/resource_manager_interface.dart';
import 'package:secure_event_app/core/services/resource_manager.dart';
import '../../test_helper.dart';
import '../../test_helper.mocks.dart';

void main() {
  group('ResourceManager', () {
    late ResourceManager manager;
    late MockSecureStorage mockStorage;
    late MockILoggerService mockLogger;

    setUp(() {
      mockStorage = MockSecureStorage();
      mockLogger = MockILoggerService();
      manager = ResourceManager(mockLogger, mockStorage);
    });

    test('should initialize service', () async {
      // Arrange
      when(mockStorage.read(any)).thenAnswer((_) => Future.value(null));

      // Act
      await manager.initialize();

      // Assert
      verify(mockLogger.info(any)).called(2);
      verify(mockStorage.read(any)).called(1);
    });

    test('should get current resource usage', () async {
      // Arrange
      await manager.initialize();

      // Act
      final usage = await manager.getCurrentUsage(ResourceType.cpu);

      // Assert
      expect(usage.type, equals(ResourceType.cpu));
      expect(usage.currentValue, equals(50.0));
      expect(usage.maxValue, equals(100.0));
      expect(usage.status, equals(ResourceStatus.available));
      verify(mockLogger.info(any)).called(3);
    });

    test('should get usage history', () async {
      // Arrange
      await manager.initialize();
      final startTime = DateTime.now().subtract(const Duration(hours: 1));
      final endTime = DateTime.now().add(const Duration(hours: 1));

      // Act
      final history = await manager.getUsageHistory(
        ResourceType.cpu,
        startTime: startTime,
        endTime: endTime,
      );

      // Assert
      expect(history, isEmpty);
      verify(mockLogger.info(any)).called(3);
    });

    test('should optimize resource', () async {
      // Arrange
      await manager.initialize();

      // Act
      await manager.optimizeResource(ResourceType.cpu);

      // Assert
      verify(mockLogger.info(any)).called(4);
    });

    test('should release resource', () async {
      // Arrange
      await manager.initialize();

      // Act
      await manager.releaseResource(ResourceType.cpu);

      // Assert
      verify(mockLogger.info(any)).called(5);
    });

    test('should reserve resource', () async {
      // Arrange
      await manager.initialize();

      // Act
      final reserved = await manager.reserveResource(
        ResourceType.cpu,
        amount: 30.0,
      );

      // Assert
      expect(reserved, isTrue);
      verify(mockLogger.info(any)).called(4);
    });

    test('should not reserve resource when insufficient', () async {
      // Arrange
      await manager.initialize();

      // Act
      final reserved = await manager.reserveResource(
        ResourceType.cpu,
        amount: 150.0,
      );

      // Assert
      expect(reserved, isFalse);
      verify(mockLogger.info(any)).called(3);
      verify(mockLogger.warning(any)).called(1);
    });

    test('should set resource limit', () async {
      // Arrange
      when(mockStorage.write(any, any)).thenAnswer((_) => Future.value());
      await manager.initialize();

      // Act
      await manager.setResourceLimit(
        ResourceType.cpu,
        maxValue: 200.0,
      );

      // Assert
      verify(mockLogger.info(any)).called(4);
      verify(mockStorage.write(any, any)).called(1);
    });

    test('should get resource status', () async {
      // Arrange
      await manager.initialize();

      // Act
      final status = await manager.getResourceStatus(ResourceType.cpu);

      // Assert
      expect(status, equals(ResourceStatus.available));
    });

    test('should report resource issue', () async {
      // Arrange
      await manager.initialize();
      const issue = 'High CPU usage';

      // Act
      await manager.reportResourceIssue(
        ResourceType.cpu,
        issue: issue,
      );

      // Assert
      verify(mockLogger.warning(any)).called(1);
      verify(mockLogger.info(any)).called(3);
    });

    test('should load configuration', () async {
      // Arrange
      final config = {
        'limits': {
          'cpu': 200.0,
          'memory': 2048.0,
        },
      };
      when(mockStorage.read(any))
          .thenAnswer((_) => Future.value(jsonEncode(config)));

      // Act
      await manager.initialize();

      // Assert
      verify(mockLogger.info(any)).called(2);
      verify(mockStorage.read(any)).called(1);
    });

    test('should handle configuration load error', () async {
      // Arrange
      when(mockStorage.read(any)).thenThrow(Exception('Test error'));

      // Act
      await manager.initialize();

      // Assert
      verify(mockLogger.info(any)).called(2);
      verify(mockLogger.error(any, any)).called(1);
    });

    test('should emit resource usage updates', () async {
      // Arrange
      await manager.initialize();
      final updates = <ResourceUsage>[];
      manager.resourceStream.listen(updates.add);

      // Act
      await manager.getCurrentUsage(ResourceType.cpu);
      await manager.getCurrentUsage(ResourceType.memory);

      // Assert
      expect(updates.length, equals(2));
      expect(updates[0].type, equals(ResourceType.cpu));
      expect(updates[1].type, equals(ResourceType.memory));
    });

    test('should cleanup old history entries', () async {
      // Arrange
      await manager.initialize();

      // Act
      await manager.getCurrentUsage(ResourceType.cpu);
      await Future.delayed(const Duration(milliseconds: 100));
      await manager.getCurrentUsage(ResourceType.cpu);

      // Assert
      final history = await manager.getUsageHistory(
        ResourceType.cpu,
        startTime: DateTime.now().subtract(const Duration(days: 8)),
        endTime: DateTime.now(),
      );
      expect(history.length, equals(2));
    });
  });
}
