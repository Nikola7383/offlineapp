import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/sync/sync_service.dart';
import 'package:secure_event_app/core/models/message.dart';
import 'package:secure_event_app/core/storage/database_service.dart';
import 'package:secure_event_app/core/mesh/mesh_network.dart';
import 'package:secure_event_app/core/security/encryption_service.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

class MockMeshNetwork extends Mock implements MeshNetwork {}

class MockEncryptionService extends Mock implements EncryptionService {}

void main() {
  late SyncService syncService;
  late MockDatabaseService mockStorage;
  late MockMeshNetwork mockMesh;
  late MockEncryptionService mockEncryption;
  late LoggerService logger;

  setUp(() {
    mockStorage = MockDatabaseService();
    mockMesh = MockMeshNetwork();
    mockEncryption = MockEncryptionService();
    logger = LoggerService();

    syncService = SyncService(
      storage: mockStorage,
      mesh: mockMesh,
      encryption: mockEncryption,
      logger: logger,
    );
  });

  group('Sync Service Tests', () {
    test('Should handle successful sync', () async {
      // Arrange
      final localMessage = Message(
        id: 'local_1',
        content: 'Local message',
        senderId: 'sender_1',
        timestamp: DateTime.now(),
      );

      when(mockStorage.getMessages(since: any))
          .thenAnswer((_) async => [localMessage]);

      when(mockEncryption.encrypt(any))
          .thenAnswer((_) async => EncryptedMessage(
                id: 'encrypted_1',
                content: 'encrypted',
                signature: 'sig',
                timestamp: DateTime.now(),
              ));

      when(mockMesh.broadcast(any)).thenAnswer((_) async => true);

      // Act
      final result = await syncService.synchronize();

      // Assert
      expect(result.success, isTrue);
      expect(result.messagesSent, equals(1));
      verify(mockMesh.broadcast(any)).called(1);
    });

    test('Should handle sync conflicts', () async {
      // Arrange
      final now = DateTime.now();
      final localMessage = Message(
        id: 'conflict_1',
        content: 'Local version',
        senderId: 'sender_1',
        timestamp: now,
      );

      final networkMessage = Message(
        id: 'conflict_1',
        content: 'Network version',
        senderId: 'sender_1',
        timestamp: now.add(const Duration(minutes: 1)),
      );

      when(mockStorage.getMessages(since: any))
          .thenAnswer((_) async => [localMessage]);

      when(mockStorage.saveMessage(any)).thenAnswer((_) async {});

      // Act
      final result = await syncService.synchronize();

      // Assert
      expect(result.success, isTrue);
      verify(mockStorage.saveMessage(any)).called(greaterThan(0));
    });
  });
}
