import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:your_app/core/storage/storage_manager.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

class MockLoggerService extends Mock implements LoggerService {}

class MockFile extends Mock implements File {}

void main() {
  late StorageManager storageManager;
  late MockDatabaseService mockDb;
  late MockLoggerService mockLogger;

  setUp(() {
    mockDb = MockDatabaseService();
    mockLogger = MockLoggerService();
    storageManager = StorageManager(
      db: mockDb,
      logger: mockLogger,
    );
  });

  group('StorageManager Tests', () {
    test('manageStorage should cleanup when size exceeds limit', () async {
      // Arrange
      when(mockDb.getDatabaseSize())
          .thenAnswer((_) async => 150 * 1024 * 1024); // 150MB
      when(mockDb.getMessagesBefore(any)).thenAnswer((_) async => [
            Message(id: '1', content: 'Old message', timestamp: DateTime.now()),
          ]);

      // Act
      await storageManager.manageStorage();

      // Assert
      verify(mockDb.deleteMessagesBefore(any)).called(1);
    });

    test('createBackup should backup database and config', () async {
      // Arrange
      final mockDbFile = MockFile();
      when(mockDb.getDatabaseFile()).thenAnswer((_) async => mockDbFile);
      when(mockDbFile.copy(any)).thenAnswer((_) async => MockFile());

      // Act
      await storageManager.createBackup();

      // Assert
      verify(mockDbFile.copy(any)).called(1);
      verify(mockLogger.info(any)).called(1);
    });

    test('restoreFromBackup should restore database and config', () async {
      // Arrange
      final timestamp = DateTime.now().toIso8601String();
      final mockBackupFile = MockFile();
      when(mockBackupFile.exists()).thenAnswer((_) async => true);
      when(mockDb.getDatabaseFile()).thenAnswer((_) async => MockFile());

      // Act
      await storageManager.restoreFromBackup(timestamp);

      // Assert
      verify(mockDb.close()).called(1);
      verify(mockLogger.info(contains('Backup vraćen'))).called(1);
    });
  });
}
