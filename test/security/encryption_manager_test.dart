import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/interfaces/logger_service_interface.dart';
import 'package:secure_event_app/models/encryption_types.dart';
import 'package:secure_event_app/security/encryption_manager.dart';
import '../mocks/security_mocks.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late EncryptionManager encryptionManager;
  late EncryptionConfig testConfig;

  setUp(() {
    mockLogger = MockILoggerService();
    encryptionManager = EncryptionManager(mockLogger);
    testConfig = const EncryptionConfig(
      type: EncryptionType.aes256,
      level: EncryptionLevel.high,
      keyRotationInterval: Duration(days: 30),
      requireIntegrityCheck: true,
    );

    when(mockLogger.info(any)).thenAnswer((_) async {});
    when(mockLogger.warning(any)).thenAnswer((_) async {});
  });

  group('EncryptionManager Tests', () {
    test('initialize() postavlja isInitialized na true', () async {
      expect(encryptionManager.isInitialized, isFalse);
      await encryptionManager.initialize();
      expect(encryptionManager.isInitialized, isTrue);
      verify(mockLogger.info(any)).called(1);
    });

    test('initialize() ne inicijalizuje već inicijalizovan menadžer', () async {
      await encryptionManager.initialize();
      await encryptionManager.initialize();
      verify(mockLogger.warning(any)).called(1);
    });

    test('dispose() čisti resurse i postavlja isInitialized na false',
        () async {
      await encryptionManager.initialize();
      await encryptionManager.dispose();
      expect(encryptionManager.isInitialized, isFalse);
      verify(mockLogger.info(any)).called(2);
    });

    test('dispose() ne gasi neinicijalizovan menadžer', () async {
      await encryptionManager.dispose();
      verify(mockLogger.warning(any)).called(1);
    });

    test('encrypt() enkriptuje podatke', () async {
      await encryptionManager.initialize();
      await encryptionManager.generateKeyPair();

      final testData = [1, 2, 3, 4, 5];
      final encryptedData =
          await encryptionManager.encrypt(testData, testConfig);

      expect(encryptedData.data, isNotEmpty);
      expect(encryptedData.algorithm, contains(testConfig.type.toString()));
      verify(mockLogger.info(any)).called(greaterThan(1));
    });

    test('decrypt() dekriptuje podatke', () async {
      await encryptionManager.initialize();
      final keyPair = await encryptionManager.generateKeyPair();

      final testData = [1, 2, 3, 4, 5];
      final encryptedData =
          await encryptionManager.encrypt(testData, testConfig);
      final decryptedData = await encryptionManager.decrypt(encryptedData);

      expect(decryptedData, equals(testData));
      verify(mockLogger.info(any)).called(greaterThan(2));
    });

    test('generateKeyPair() generiše par ključeva', () async {
      await encryptionManager.initialize();
      final keyPair = await encryptionManager.generateKeyPair();

      expect(keyPair.id, isNotEmpty);
      expect(keyPair.publicKey, startsWith('public_'));
      expect(keyPair.privateKey, startsWith('private_'));
      expect(keyPair.state, equals(KeyState.active));
      verify(mockLogger.info(any)).called(2);
    });

    test('rotateKeys() rotira ključeve', () async {
      await encryptionManager.initialize();
      await encryptionManager.generateKeyPair();
      await encryptionManager.rotateKeys();

      final status = await encryptionManager.checkStatus();
      expect(status.activeKeys, equals(1));
      verify(mockLogger.info(any)).called(greaterThan(2));
    });

    test('verifyIntegrity() verifikuje integritet', () async {
      await encryptionManager.initialize();
      await encryptionManager.generateKeyPair();

      final testData = [1, 2, 3, 4, 5];
      final encryptedData =
          await encryptionManager.encrypt(testData, testConfig);
      final isValid = await encryptionManager.verifyIntegrity(encryptedData);

      expect(isValid, isTrue);
      verify(mockLogger.info(any)).called(greaterThan(2));
    });

    test('manageKeys() upravlja ključevima', () async {
      await encryptionManager.initialize();
      final keyPair = await encryptionManager.generateKeyPair();

      final operation = KeyOperation(
        id: 'op1',
        type: KeyOperationType.revoke,
        keyId: keyPair.id,
        timestamp: DateTime.now(),
      );

      await encryptionManager.manageKeys(operation);
      final status = await encryptionManager.checkStatus();
      expect(status.activeKeys, equals(0));
      verify(mockLogger.info(any)).called(greaterThan(2));
    });

    test('generateReport() generiše izveštaj', () async {
      await encryptionManager.initialize();
      await encryptionManager.generateKeyPair();

      final report = await encryptionManager.generateReport();
      expect(report.activeKeys, equals(1));
      expect(report.warnings, isEmpty);
      verify(mockLogger.info(any)).called(greaterThan(1));
    });

    test('configure() konfiguriše parametre', () async {
      await encryptionManager.initialize();
      await encryptionManager.configure(testConfig);

      final status = await encryptionManager.checkStatus();
      expect(status.currentType, equals(testConfig.type));
      expect(status.currentLevel, equals(testConfig.level));
      verify(mockLogger.info(any)).called(greaterThan(1));
    });

    test('checkStatus() vraća status', () async {
      await encryptionManager.initialize();
      await encryptionManager.generateKeyPair();
      await encryptionManager.configure(testConfig);

      final status = await encryptionManager.checkStatus();
      expect(status.isInitialized, isTrue);
      expect(status.activeKeys, equals(1));
      expect(status.currentType, equals(testConfig.type));
      verify(mockLogger.info(any)).called(greaterThan(2));
    });

    test('encryptionEvents emituje događaje', () async {
      await encryptionManager.initialize();
      await encryptionManager.generateKeyPair();

      expectLater(
        encryptionManager.encryptionEvents,
        emitsThrough(predicate<EncryptionEvent>(
          (event) => event.severity == EncryptionLevel.high,
        )),
      );
    });

    test('keyStatus emituje status ključeva', () async {
      await encryptionManager.initialize();
      await encryptionManager.generateKeyPair();

      expectLater(
        encryptionManager.keyStatus,
        emitsThrough(predicate<KeyStatus>(
          (status) => status.state == KeyState.active,
        )),
      );
    });
  });
}
