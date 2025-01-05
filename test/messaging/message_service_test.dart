import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/models/message.dart';
import 'package:secure_event_app/core/messaging/message_service.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';
import 'package:secure_event_app/core/security/encryption_service.dart';
import 'package:secure_event_app/core/mesh/mesh_network.dart';

class MockEncryptionService extends Mock implements EncryptionService {}

class MockMeshNetwork extends Mock implements MeshNetwork {}

void main() {
  late MessageService messageService;
  late MockEncryptionService mockEncryption;
  late MockMeshNetwork mockMesh;
  late LoggerService logger;

  setUp(() {
    logger = LoggerService();
    mockEncryption = MockEncryptionService();
    mockMesh = MockMeshNetwork();

    messageService = MessageService(
      logger: logger,
      encryption: mockEncryption,
      mesh: mockMesh,
    );
  });

  group('Message Service Tests', () {
    test('Should send message successfully', () async {
      // Arrange
      final message = Message(
        id: 'test_1',
        content: 'Test message',
        senderId: 'sender_1',
        timestamp: DateTime.now(),
      );

      when(mockMesh.broadcast(any)).thenAnswer((_) async => true);

      // Act
      final result = await messageService.sendMessage(message);

      // Assert
      expect(result, isTrue);
      verify(mockMesh.broadcast(any)).called(1);
    });

    test('Should retrieve recent messages', () async {
      // Arrange
      final message = Message(
        id: 'test_1',
        content: 'Test message',
        senderId: 'sender_1',
        timestamp: DateTime.now(),
      );

      await messageService.sendMessage(message);

      // Act
      final messages = await messageService.getRecentMessages(limit: 1);

      // Assert
      expect(messages.length, equals(1));
      expect(messages.first.id, equals('test_1'));
    });
  });
}
