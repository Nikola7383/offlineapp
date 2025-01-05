import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/models/message.dart';
import 'package:secure_event_app/core/models/result.dart';
import 'package:secure_event_app/core/services/service_locator.dart';
import 'helpers/test_helpers.mocks.dart';

class TestSetup {
  late MockIMeshService mockMesh;
  late MockIStorageService mockStorage;
  late MockIDatabaseService mockDatabase;
  late MockILoggerService mockLogger;
  late TestServiceLocator locator;

  Future<void> setUp() async {
    // Initialize mocks
    mockMesh = MockIMeshService();
    mockStorage = MockIStorageService();
    mockDatabase = MockIDatabaseService();
    mockLogger = MockILoggerService();

    // Setup default behaviors
    _setupMockMesh();
    _setupMockStorage();
    _setupMockDatabase();
    _setupMockLogger();

    // Initialize service locator
    locator = TestServiceLocator();
    await locator.initializeWithMocks(
      meshService: mockMesh,
      storageService: mockStorage,
      databaseService: mockDatabase,
      loggerService: mockLogger,
    );
  }

  Future<void> tearDown() async {
    await locator.dispose();
  }

  void _setupMockMesh() {
    when(mockMesh.initialize()).thenAnswer((_) async {});
    when(mockMesh.dispose()).thenAnswer((_) async {});
    when(mockMesh.sendMessage(any)).thenAnswer((_) async => Result.success());
  }

  void _setupMockStorage() {
    when(mockStorage.initialize()).thenAnswer((_) async {});
    when(mockStorage.dispose()).thenAnswer((_) async {});
    when(mockStorage.saveMessage(any))
        .thenAnswer((_) async => Result.success());
    when(mockStorage.getMessages()).thenAnswer((_) async => Result.success([]));
  }

  void _setupMockDatabase() {
    when(mockDatabase.initialize()).thenAnswer((_) async {});
    when(mockDatabase.dispose()).thenAnswer((_) async {});
    when(mockDatabase.set(any, any)).thenAnswer((_) async => Result.success());
    when(mockDatabase.get(any)).thenAnswer((_) async => Result.success(null));
    when(mockDatabase.getAll(any)).thenAnswer(
      (_) async => Result.success(<String, dynamic>{}),
    );
  }

  void _setupMockLogger() {
    when(mockLogger.initialize()).thenAnswer((_) async {});
    when(mockLogger.dispose()).thenAnswer((_) async {});
    when(mockLogger.info(any, any)).thenAnswer((_) async {});
    when(mockLogger.error(any, any)).thenAnswer((_) async {});
  }

  Message createTestMessage({
    String? id,
    String? content,
    String? senderId,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? 'test_id',
      content: content ?? 'test_content',
      senderId: senderId ?? 'test_sender',
      timestamp: timestamp ?? DateTime.now(),
      status: status ?? MessageStatus.pending,
    );
  }
}
