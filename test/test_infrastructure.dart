import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/models/message.dart';
import 'package:secure_event_app/core/models/result.dart';
import 'package:secure_event_app/core/services/sync_service.dart';
import 'package:secure_event_app/core/services/storage_service.dart';
import 'test_core.mocks.dart';

class TestInfrastructure {
  // Services
  late MockILoggerService logger;
  late MockIDatabaseService database;
  late MockIMeshService mesh;
  late MockIStorageService storage;
  late MockISyncService sync;

  // Real Services (for integration tests)
  late StorageService realStorage;
  late SyncService realSync;

  // Test Data
  final testMessages = <String, Message>{};
  final testData = <String, dynamic>{};
  bool isOffline = false;

  Future<void> setUp() async {
    _setupMocks();
    _setupTestData();
    _setupRealServices();
    await _initializeMocks();
    await _initializeRealServices();
  }

  void _setupMocks() {
    logger = MockILoggerService();
    database = MockIDatabaseService();
    mesh = MockIMeshService();
    storage = MockIStorageService();
    sync = MockISyncService();

    // Logger Setup
    when(logger.initialize()).thenAnswer((_) async {});
    when(logger.dispose()).thenAnswer((_) async {});
    when(logger.info(any, any)).thenAnswer((_) async {});
    when(logger.error(any, any)).thenAnswer((_) async {});

    // Database Setup
    when(database.initialize()).thenAnswer((_) async {});
    when(database.dispose()).thenAnswer((_) async {});
    when(database.set(any, any)).thenAnswer((inv) async {
      final key = inv.positionalArguments[0] as String;
      final value = inv.positionalArguments[1];
      testData[key] = value;
      return Result.success();
    });
    when(database.get(any)).thenAnswer((inv) async {
      final key = inv.positionalArguments[0] as String;
      return Result.success(testData[key]);
    });
    when(database.getAll(any)).thenAnswer((inv) async {
      final prefix = inv.positionalArguments[0] as String;
      final filtered = Map.fromEntries(
          testData.entries.where((e) => e.key.startsWith(prefix)));
      return Result.success(filtered);
    });

    // Mesh Setup
    when(mesh.initialize()).thenAnswer((_) async {});
    when(mesh.dispose()).thenAnswer((_) async {});
    when(mesh.sendMessage(any)).thenAnswer((inv) async {
      if (isOffline) return Result.failure('Network error');
      final msg = inv.positionalArguments[0] as Message;
      testMessages[msg.id] = msg.copyWith(status: MessageStatus.sent);
      return Result.success();
    });
  }

  void _setupRealServices() {
    realStorage = StorageService(database);
    realSync = SyncService(mesh, realStorage);
  }

  Future<void> _initializeRealServices() async {
    await realStorage.initialize();
    await realSync.initialize();
  }

  void setOffline(bool offline) {
    isOffline = offline;
  }

  Message createTestMessage({
    String? id,
    String? content,
    String? senderId,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    final newId = id ?? 'test_${testMessages.length + 1}';
    final message = Message(
      id: newId,
      content: content ?? 'Test content $newId',
      senderId: senderId ?? 'test_sender',
      timestamp: timestamp ?? DateTime.now(),
      status: status ?? MessageStatus.pending,
    );
    return message;
  }

  Future<void> tearDown() async {
    await realSync.dispose();
    await realStorage.dispose();
    await sync.dispose();
    await storage.dispose();
    await mesh.dispose();
    await database.dispose();
    await logger.dispose();
    testMessages.clear();
    testData.clear();
    isOffline = false;
  }
}
