import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/models/result.dart';
import 'package:secure_event_app/core/services/database_service.dart';
import '../../helpers/test_helpers.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late DatabaseService database;

  setUp(() {
    mockLogger = MockILoggerService();
    database = DatabaseService(
      mockLogger,
      const DatabaseConfig(
        name: 'test_db',
        encryptionEnabled: false,
      ),
    );
  });

  test('should initialize database', () async {
    // Act
    await database.initialize();

    // Assert
    expect(database.isInitialized, true);
  });

  test('should store and retrieve data', () async {
    // Arrange
    await database.initialize();
    const testKey = 'test_key';
    const testData = {'test': 'value'};

    // Act
    final saveResult = await database.set(testKey, testData);
    final loadResult = await database.get<Map<String, dynamic>>(testKey);

    // Assert
    expect(saveResult.isSuccess, true);
    expect(loadResult.isSuccess, true);
    expect(loadResult.data, testData);
  });

  test('should handle batch operations', () async {
    // Arrange
    await database.initialize();
    final operations = [
      BatchOperation(
        type: BatchOperationType.set,
        key: 'key1',
        value: 'value1',
      ),
      BatchOperation(
        type: BatchOperationType.set,
        key: 'key2',
        value: 'value2',
      ),
    ];

    // Act
    final result = await database.batch(operations);

    // Assert
    expect(result.isSuccess, true);

    final key1Result = await database.get<String>('key1');
    final key2Result = await database.get<String>('key2');
    expect(key1Result.data, 'value1');
    expect(key2Result.data, 'value2');
  });
}
