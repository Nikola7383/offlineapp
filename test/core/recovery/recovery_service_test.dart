import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:your_app/core/recovery/recovery_service.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

class MockLoggerService extends Mock implements LoggerService {}

class MockStorageManager extends Mock implements StorageManager {}

void main() {
  late RecoveryService recoveryService;
  late MockDatabaseService mockDb;
  late MockLoggerService mockLogger;
  late MockStorageManager mockStorage;

  setUp(() {
    mockDb = MockDatabaseService();
    mockLogger = MockLoggerService();
    mockStorage = MockStorageManager();
    recoveryService = RecoveryService(
      db: mockDb,
      logger: mockLogger,
      storage: mockStorage,
    );
  });

  group('RecoveryService Tests', () {
    test('handleCrash should log error and create recovery point', () async {
      // Arrange
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      // Act
      await recoveryService.handleCrash(error, stackTrace);

      // Assert
      verify(mockLogger.error(any, error, stackTrace)).called(1);
      verify(mockStorage.createBackup()).called(1);
    });

    test('recoverFromCrash should check and repair database', () async {
      // Arrange
      when(mockDb.checkIntegrity()).thenAnswer((_) async => false);
      when(mockDb.repair()).thenAnswer((_) async => true);

      // Act
      await recoveryService.recoverFromCrash();

      // Assert
      verify(mockDb.checkIntegrity()).called(1);
      verify(mockDb.repair()).called(1);
    });

    test('verifyMessages should remove corrupted messages', () async {
      // Arrange
      final messages = [
        Message(id: '1', content: 'Valid', timestamp: DateTime.now()),
        Message(id: '2', content: 'Corrupted', timestamp: DateTime.now()),
      ];

      when(mockDb.getAllMessages()).thenAnswer((_) async => messages);
      when(mockDb.deleteMessages(any)).thenAnswer((_) async => {});

      // Act
      await recoveryService.verifyMessages();

      // Assert
      verify(mockDb.getAllMessages()).called(1);
      verify(mockDb.deleteMessages(any)).called(1);
      verify(mockLogger.warning(contains('Obrisano'))).called(1);
    });
  });
}
