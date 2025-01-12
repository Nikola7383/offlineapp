import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:secure_event_app/security/biometric_manager.dart';
import 'package:secure_event_app/security/encryption_manager.dart';
import 'package:secure_event_app/models/biometric_types.dart';
import 'package:secure_event_app/models/encryption_types.dart';
import '../mocks/security_mocks.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late BiometricManager biometricManager;
  late EncryptionManager encryptionManager;

  setUp(() {
    mockLogger = MockILoggerService();
    biometricManager = BiometricManager(mockLogger);
    encryptionManager = EncryptionManager(mockLogger);
  });

  group('Biometric and Encryption Integration Tests', () {
    test('Should successfully authenticate and encrypt sensitive data',
        () async {
      // Inicijalizacija menadžera
      await biometricManager.initialize();
      await encryptionManager.initialize();

      // Verifikacija biometrije
      final verificationResult = await biometricManager.verifyBiometrics(
        userId: 'test_user',
        type: BiometricType.fingerprint,
      );
      expect(verificationResult.isSuccessful, true);

      // Generisanje ključeva nakon uspešne biometrijske verifikacije
      final keyPair = await encryptionManager.generateKeyPair();
      expect(keyPair, isNotNull);

      // Enkripcija osetljivih podataka
      final sensitiveData = utf8.encode('Osetljivi podaci');
      final config = EncryptionConfig(
        type: EncryptionType.aes256,
        level: EncryptionLevel.high,
        keyRotationInterval: const Duration(days: 30),
        requireIntegrityCheck: true,
      );
      final encryptedData =
          await encryptionManager.encrypt(sensitiveData, config);
      expect(encryptedData, isNotNull);

      // Dekripcija i verifikacija
      final decryptedData = await encryptionManager.decrypt(encryptedData);
      final decryptedString = utf8.decode(decryptedData);
      expect(decryptedString, equals('Osetljivi podaci'));

      // Verifikacija logovanja
      verify(mockLogger.info('Initializing BiometricManager')).called(1);
      verify(mockLogger.info('BiometricManager initialized successfully'))
          .called(1);
      verify(mockLogger.info('Inicijalizacija EncryptionManager-a')).called(1);
      verify(mockLogger.info(
              'Verifying biometrics for user: test_user, type: ${BiometricType.fingerprint}'))
          .called(1);
      verify(mockLogger.info('Generisanje para ključeva')).called(1);
      verify(mockLogger.info('Enkripcija podataka')).called(1);
      verify(mockLogger.info('Dekripcija podataka')).called(1);
    });

    test('Should handle failed biometric verification gracefully', () async {
      // Inicijalizacija
      await biometricManager.initialize();
      await encryptionManager.initialize();

      // Simulacija neuspešne biometrijske verifikacije
      when(mockLogger.warning(any)).thenAnswer((_) => Future.value());
      when(mockLogger.info(any)).thenAnswer((_) => Future.value());

      final verificationResult = await biometricManager.verifyBiometrics(
        userId: 'test_user',
        type: BiometricType.fingerprint,
        options: BiometricVerificationOptions(
          timeoutSeconds: 10,
          maxAttempts: 1,
          localizedReason: 'Test verification',
        ),
      );

      // Verifikacija da enkripcija nije dozvoljena nakon neuspešne biometrije
      if (!verificationResult.isSuccessful) {
        expect(() => encryptionManager.generateKeyPair(),
            throwsA(isA<StateError>()));
      }

      // Verifikacija inicijalizacije i pokušaja verifikacije
      verify(mockLogger.info('Initializing BiometricManager')).called(1);
      verify(mockLogger.info('BiometricManager initialized successfully'))
          .called(1);
      verify(mockLogger.info('Inicijalizacija EncryptionManager-a')).called(1);
      verify(mockLogger.info(
              'Verifying biometrics for user: test_user, type: ${BiometricType.fingerprint}'))
          .called(1);
    });

    test('Should maintain security state across multiple operations', () async {
      // Inicijalizacija
      await biometricManager.initialize();
      await encryptionManager.initialize();

      // Praćenje stanja biometrijske autentifikacije
      final biometricEvents = <BiometricEvent>[];
      final subscription = biometricManager.biometricEvents.listen(
        biometricEvents.add,
      );

      // Izvršavanje više operacija
      await biometricManager.verifyBiometrics(
        userId: 'test_user',
        type: BiometricType.fingerprint,
      );

      final keyPair = await encryptionManager.generateKeyPair();

      // Verifikacija stanja
      expect(biometricEvents, isNotEmpty);
      expect(biometricEvents.last.isSuccessful, true);
      expect(keyPair, isNotNull);

      // Čišćenje
      await subscription.cancel();
    });

    test('Should rotate encryption keys after biometric verification',
        () async {
      // Inicijalizacija
      await biometricManager.initialize();
      await encryptionManager.initialize();

      // Verifikacija biometrije
      final verificationResult = await biometricManager.verifyBiometrics(
        userId: 'test_user',
        type: BiometricType.fingerprint,
      );
      expect(verificationResult.isSuccessful, true);

      // Generisanje inicijalnog para ključeva
      final initialKeyPair = await encryptionManager.generateKeyPair();
      expect(initialKeyPair, isNotNull);

      // Enkripcija test podataka sa inicijalnim ključem
      final testData = utf8.encode('Test podaci');
      final config = EncryptionConfig(
        type: EncryptionType.aes256,
        level: EncryptionLevel.high,
        keyRotationInterval: const Duration(days: 30),
        requireIntegrityCheck: true,
      );
      final encryptedData = await encryptionManager.encrypt(testData, config);

      // Rotacija ključeva
      await encryptionManager.rotateKeys();

      // Pokušaj dekripcije sa rotiranim ključevima
      final decryptedData = await encryptionManager.decrypt(encryptedData);
      final decryptedString = utf8.decode(decryptedData);
      expect(decryptedString, equals('Test podaci'));

      // Verifikacija logovanja
      verify(mockLogger.info('Initializing BiometricManager')).called(1);
      verify(mockLogger.info('BiometricManager initialized successfully'))
          .called(1);
      verify(mockLogger.info('Inicijalizacija EncryptionManager-a')).called(1);
      verify(mockLogger.info(
              'Verifying biometrics for user: test_user, type: ${BiometricType.fingerprint}'))
          .called(1);
      verify(mockLogger.info('Generisanje para ključeva'))
          .called(2); // Jednom za inicijalni par, jednom za rotaciju
      verify(mockLogger.info('Rotacija ključeva')).called(1);
      verify(mockLogger.info('Enkripcija podataka')).called(1);
      verify(mockLogger.info('Dekripcija podataka')).called(1);
    });

    test('Should handle expired encryption keys correctly', () async {
      // Inicijalizacija
      await biometricManager.initialize();
      await encryptionManager.initialize();

      // Verifikacija biometrije
      final verificationResult = await biometricManager.verifyBiometrics(
        userId: 'test_user',
        type: BiometricType.fingerprint,
      );
      expect(verificationResult.isSuccessful, true);

      // Generisanje para ključeva koji će brzo isteći
      final keyPair = await encryptionManager
          .generateKeyPair(DateTime.now().add(const Duration(seconds: 1)));
      expect(keyPair, isNotNull);
      expect(keyPair.expiresAt.isAfter(DateTime.now()), true);

      // Enkripcija test podataka
      final testData = utf8.encode('Test podaci');
      final config = EncryptionConfig(
        type: EncryptionType.aes256,
        level: EncryptionLevel.high,
        keyRotationInterval:
            const Duration(seconds: 1), // Kratak interval za test
        requireIntegrityCheck: true,
      );
      final encryptedData = await encryptionManager.encrypt(testData, config);

      // Čekamo da ključ istekne
      await Future.delayed(const Duration(seconds: 2));

      // Pokušaj dekripcije sa isteklim ključem treba da baci izuzetak
      expect(encryptionManager.decrypt(encryptedData),
          throwsA(isA<SecurityException>()));

      // Verifikacija logovanja
      verify(mockLogger.info('Initializing BiometricManager')).called(1);
      verify(mockLogger.info('BiometricManager initialized successfully'))
          .called(1);
      verify(mockLogger.info('Inicijalizacija EncryptionManager-a')).called(1);
      verify(mockLogger.info(
              'Verifying biometrics for user: test_user, type: ${BiometricType.fingerprint}'))
          .called(1);
      verify(mockLogger.info('Generisanje para ključeva')).called(1);
      verify(mockLogger.info('Enkripcija podataka')).called(1);
    });
  });
}
