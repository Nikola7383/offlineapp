import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/app/app_service.dart';
import 'package:secure_event_app/core/models/message.dart';

// Mock klase
class MockAuthService extends Mock implements AuthService {}

class MockMeshNetwork extends Mock implements MeshNetwork {}

class MockMessageService extends Mock implements MessageService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockNotificationService extends Mock implements NotificationService {}

class MockSettingsService extends Mock implements SettingsService {}

class MockEncryptionService extends Mock implements EncryptionService {}

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late AppService appService;
  late MockAuthService mockAuth;
  late MockMeshNetwork mockMesh;
  late MockMessageService mockMessaging;
  late MockDatabaseService mockStorage;
  late MockNotificationService mockNotifications;
  late MockSettingsService mockSettings;
  late MockEncryptionService mockEncryption;
  late MockLoggerService mockLogger;

  setUp(() {
    mockAuth = MockAuthService();
    mockMesh = MockMeshNetwork();
    mockMessaging = MockMessageService();
    mockStorage = MockDatabaseService();
    mockNotifications = MockNotificationService();
    mockSettings = MockSettingsService();
    mockEncryption = MockEncryptionService();
    mockLogger = MockLoggerService();

    // Setup mock responses
    when(mockAuth.initialize()).thenAnswer((_) async => true);
    when(mockStorage.initialize()).thenAnswer((_) async => true);
    when(mockSettings.initialize()).thenAnswer((_) async => true);
    when(mockNotifications.initialize()).thenAnswer((_) async => true);
    when(mockMesh.messageStream).thenAnswer((_) => Stream<Message>.empty());

    appService = AppService(
      auth: mockAuth,
      mesh: mockMesh,
      messaging: mockMessaging,
      storage: mockStorage,
      notifications: mockNotifications,
      settings: mockSettings,
      encryption: mockEncryption,
      logger: mockLogger,
    );
  });

  group('AppService Tests', () {
    test('should initialize successfully', () async {
      // Act
      final result = await appService.initialize();

      // Assert
      expect(result, isTrue);
      verify(mockSettings.initialize()).called(1);
      verify(mockAuth.initialize()).called(1);
      verify(mockStorage.initialize()).called(1);
      verify(mockNotifications.initialize()).called(1);
    });

    test('should send message successfully', () async {
      // Arrange
      await appService.initialize();

      when(mockAuth.currentUser).thenReturn(
        User(
          id: 'user1',
          username: 'test',
          email: 'test@example.com',
          publicKey: 'key',
        ),
      );

      when(mockMesh.broadcast(any)).thenAnswer((_) async => true);
      when(mockStorage.saveMessage(any)).thenAnswer((_) async => true);

      // Act
      final result = await appService.sendMessage('Test message');

      // Assert
      expect(result, isTrue);
      verify(mockStorage.saveMessage(any)).called(1);
      verify(mockMesh.broadcast(any)).called(1);
    });

    test('should handle incoming messages', () async {
      // Arrange
      await appService.initialize();

      final testMessage = Message(
        id: '1',
        content: 'Test message',
        senderId: 'user2',
        timestamp: DateTime.now(),
      );

      when(mockSettings.getSetting<bool>('notifications_enabled'))
          .thenReturn(true);

      // Act & Assert
      expect(
        appService.messageStream,
        emits(testMessage),
      );

      // Simuliraj dolaznu poruku
      mockMesh.messageStream.listen((message) {
        appService._handleIncomingMessage(message);
      });
    });
  });
}
