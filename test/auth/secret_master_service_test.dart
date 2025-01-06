import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/auth/secret_master_service.dart';

class MockSecureStorage extends Mock implements SecureStorage {}

class MockEncryptionService extends Mock implements EncryptionService {}

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late SecretMasterService secretMasterService;
  late MockSecureStorage mockStorage;
  late MockEncryptionService mockEncryption;
  late MockLoggerService mockLogger;

  setUp(() {
    mockStorage = MockSecureStorage();
    mockEncryption = MockEncryptionService();
    mockLogger = MockLoggerService();

    secretMasterService = SecretMasterService(
      storage: mockStorage,
      encryption: mockEncryption,
      logger: mockLogger,
    );
  });

  group('Secret Master Creation Tests', () {
    test('should create new Secret Master when creator is Secret Master',
        () async {
      // Arrange
      const creatorId = 'creator123';
      const newUserId = 'newuser456';
      final secretKey = List<int>.filled(32, 1);

      when(mockStorage.read(key: 'role_$creatorId'))
          .thenAnswer((_) async => AdvancedRole.secretMaster.toString());

      when(mockEncryption.encryptSecretKey(secretKey))
          .thenAnswer((_) async => 'encrypted_key');

      // Act
      final result = await secretMasterService.createSecretMaster(
        creatorId: creatorId,
        newUserId: newUserId,
        secretKey: secretKey,
      );

      // Assert
      expect(result, true);
      verify(mockStorage.write(
        key: 'secret_master_key_$newUserId',
        value: 'encrypted_key',
      )).called(1);
      verify(mockStorage.write(
        key: 'role_$newUserId',
        value: AdvancedRole.secretMaster.toString(),
      )).called(1);
    });

    test('should fail when creator is not Secret Master', () async {
      // Arrange
      const creatorId = 'creator123';
      const newUserId = 'newuser456';
      final secretKey = List<int>.filled(32, 1);

      when(mockStorage.read(key: 'role_$creatorId'))
          .thenAnswer((_) async => AdvancedRole.masterAdmin.toString());

      // Act
      final result = await secretMasterService.createSecretMaster(
        creatorId: creatorId,
        newUserId: newUserId,
        secretKey: secretKey,
      );

      // Assert
      expect(result, false);
      verifyNever(mockStorage.write(
        key: 'secret_master_key_$newUserId',
        value: any,
      ));
    });
  });

  group('Protocol Override Tests', () {
    test('should allow protocol override by Secret Master', () async {
      // Arrange
      const secretMasterId = 'master123';
      const protocol = 'mesh_network';
      final newSettings = {'encryption_level': 'maximum'};

      when(mockStorage.read(key: 'role_$secretMasterId'))
          .thenAnswer((_) async => AdvancedRole.secretMaster.toString());

      // Act
      final result = await secretMasterService.overrideSystemProtocols(
        secretMasterId: secretMasterId,
        protocol: protocol,
        newSettings: newSettings,
      );

      // Assert
      expect(result, true);
    });
  });
}
