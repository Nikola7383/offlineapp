import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

class MockApiService extends Mock implements ApiService {}

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late OfflineService offlineService;
  late MockDatabaseService mockDb;
  late MockApiService mockApi;
  late MockLoggerService mockLogger;

  setUp(() {
    mockDb = MockDatabaseService();
    mockApi = MockApiService();
    mockLogger = MockLoggerService();
    offlineService = OfflineService(
      db: mockDb,
      api: mockApi,
      logger: mockLogger,
    );
  });

  test('Message should be saved locally when offline', () async {
    // Arrange
    final message = Message(
      id: '1',
      content: 'Test offline message',
      sender: 'Test User',
      timestamp: DateTime.now(),
    );

    when(mockDb.saveMessage(any)).thenAnswer((_) async {});

    // Act
    await offlineService.sendMessage(message);

    // Assert
    verify(mockDb.saveMessage(any)).called(1);
    verifyNever(mockApi.sendMessage(any));
  });

  test('Should sync messages when coming online', () async {
    // Arrange
    final unsynced = [
      Message(
          id: '1',
          content: 'Test 1',
          sender: 'User',
          timestamp: DateTime.now()),
      Message(
          id: '2',
          content: 'Test 2',
          sender: 'User',
          timestamp: DateTime.now()),
    ];

    when(mockDb.getUnsyncedMessages()).thenAnswer((_) async => unsynced);
    when(mockApi.sendMessage(any)).thenAnswer((_) async {});

    // Act
    await offlineService.syncMessages();

    // Assert
    verify(mockDb.getUnsyncedMessages()).called(1);
    verify(mockApi.sendMessage(any)).called(2);
  });
}
