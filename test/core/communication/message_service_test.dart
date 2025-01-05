import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:your_app/core/communication/message_service.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

class MockMeshNetwork extends Mock implements MeshNetwork {}

class MockEncryptionService extends Mock implements EncryptionService {}

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late MessageService messageService;
  late MockDatabaseService mockDb;
  late MockMeshNetwork mockMesh;
  late MockEncryptionService mockEncryption;
  late MockLoggerService mockLogger;

  setUp(() {
    mockDb = MockDatabaseService();
    mockMesh = MockMeshNetwork();
    mockEncryption = MockEncryptionService();
    mockLogger = MockLoggerService();

    messageService = MessageService(
      db: mockDb,
      mesh: mockMesh,
      encryption: mockEncryption,
      logger: mockLogger,
    );
  });

  group('MessageService Tests', () {
    test('sendMessage should encrypt and save message', () async {
      // Arrange
      final message = Message(
        id: '1',
        content: 'Test message',
        senderId: 'sender1',
        timestamp: DateTime.now(),
      );

      when(mockEncryption.encrypt(any)).thenAnswer((_) async => message);
      when(mockDb.saveMessage(any)).thenAnswer((_) async => {});
      when(mockMesh.broadcast(any)).thenAnswer((_) async => true);

      // Act
      final result = await messageService.sendMessage(
        'Test message',
        'sender1',
      );

      // Assert
      expect(result, true);
      verify(mockEncryption.encrypt(any)).called(1);
      verify(mockDb.saveMessage(any)).called(1);
      verify(mockMesh.broadcast(any)).called(1);
    });

    test('handleIncomingMessage should verify and decrypt message', () async {
      // Arrange
      final message = Message(
        id: '1',
        content: 'Encrypted content',
        senderId: 'sender1',
        timestamp: DateTime.now(),
      );

      when(mockEncryption.verifyMessage(any)).thenAnswer((_) async => true);
      when(mockDb.messageExists(any)).thenAnswer((_) async => false);
      when(mockEncryption.decrypt(any)).thenAnswer((_) async => message);

      // Act
      await messageService.handleIncomingMessage(message);

      // Assert
      verify(mockEncryption.verifyMessage(any)).called(1);
      verify(mockDb.messageExists(any)).called(1);
      verify(mockEncryption.decrypt(any)).called(1);
      verify(mockDb.saveMessage(any)).called(1);
    });
  });
}
