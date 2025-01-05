import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/models/connection_models.dart';
import 'package:secure_event_app/core/services/connection_service.dart';
import '../../helpers/test_helpers.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late ConnectionService connection;
  late ConnectionConfig config;

  setUp(() {
    mockLogger = MockILoggerService();
    config = const ConnectionConfig(
      checkInterval: Duration(seconds: 1),
      enabledTypes: {ConnectionType.wifi, ConnectionType.cellular},
    );
    connection = ConnectionService(mockLogger, config);
  });

  tearDown(() async {
    await connection.dispose();
  });

  group('ConnectionService', () {
    test('initializes with offline status', () async {
      // Arrange
      when(mockLogger.info(any)).thenAnswer((_) => Future.value());

      // Act
      await connection.initialize();

      // Assert
      expect(connection.isInitialized, true);
      expect(connection.currentStatus.isConnected, false);
      verify(mockLogger.info(any)).called(2);
    });

    test('reports correct available types', () async {
      // Arrange
      await connection.initialize();

      // Act
      final types = connection.availableTypes;

      // Assert
      expect(types, equals({ConnectionType.wifi, ConnectionType.cellular}));
    });

    test('handles connection status changes', () async {
      // Arrange
      await connection.initialize();
      final statusUpdates = <ConnectionStatus>[];
      connection.statusStream.listen(statusUpdates.add);

      // Act
      await connection.checkConnection();

      // Assert
      expect(statusUpdates, isNotEmpty);
      expect(statusUpdates.last.timestamp, isNotNull);
    });
  });
}
