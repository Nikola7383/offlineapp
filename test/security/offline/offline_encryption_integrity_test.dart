void main() {
  group('Offline Security Integration Tests', () {
    late OfflineDataEncryption encryption;
    late OfflineIntegrityManager integrity;
    late MockSecureStorage mockStorage;
    late MockKeyManager mockKeyManager;
    late MockIntegrityValidator mockValidator;

    setUp(() {
      mockStorage = MockSecureStorage();
      mockKeyManager = MockKeyManager();
      mockValidator = MockIntegrityValidator();

      encryption = OfflineDataEncryption();
      integrity = OfflineIntegrityManager();
    });

    group('Encryption Tests', () {
      test('Data Encryption and Decryption Test', () async {
        final testData = OfflineData(
            content: 'Sensitive test data',
            metadata: {'type': 'test', 'priority': 'high'});

        // Enkripcija
        final encryptedData = await encryption.encryptOfflineData(testData,
            level: EncryptionLevel.high);

        expect(encryptedData, isNotNull);
        expect(encryptedData.metadata.level, equals(EncryptionLevel.high));

        // Dekripcija
        final decryptedData =
            await encryption.decryptOfflineData(encryptedData);

        expect(decryptedData.content, equals(testData.content));
        expect(decryptedData.metadata, equals(testData.metadata));
      });

      test('Key Rotation Test', () async {
        // Setup test data
        final initialData = await encryption
            .encryptOfflineData(OfflineData(content: 'Test content'));

        // Rotacija ključeva
        await encryption.rotateEncryptionKeys();

        // Provera da li stari podaci mogu biti dekriptovani
        final decryptedAfterRotation =
            await encryption.decryptOfflineData(initialData);

        expect(decryptedAfterRotation, isNotNull);
      });

      test('Encryption Status Check', () async {
        final status = await encryption.checkEncryptionStatus();

        expect(status.keyStatus.isValid, isTrue);
        expect(status.storageStatus.isSecure, isTrue);
        expect(status.backupStatus.isAvailable, isTrue);
      });
    });

    group('Integrity Tests', () {
      test('System Integrity Check', () async {
        final status = await integrity.checkSystemIntegrity();

        expect(status.isValid, isTrue);
        expect(status.anomalies, isEmpty);
      });

      test('Data Integrity Verification', () async {
        final testData = OfflineData(
            content: 'Test content', metadata: {'checksum': 'valid_hash'});

        final isValid = await integrity.verifyDataIntegrity(testData);
        expect(isValid, isTrue);
      });

      test('Corruption Recovery Test', () async {
        final detection = CorruptionDetection(
            type: ViolationType.dataCorruption,
            affectedData: 'corrupted_data',
            timestamp: DateTime.now());

        final result = await integrity.recoverFromCorruption(detection);

        expect(result.isSuccessful, isTrue);
        expect(result.recoveredData, isNotNull);
      });

      test('Integrity Violation Handling', () async {
        final violation = IntegrityViolation(
            type: ViolationType.hashMismatch,
            description: 'Hash verification failed',
            severity: SecuritySeverity.high,
            metadata: {'source': 'test'});

        await integrity.handleIntegrityViolation(violation);

        final status = await integrity.checkSystemIntegrity();
        expect(status.isValid, isTrue);
      });
    });

    group('Integration Tests', () {
      test('Encrypted Data Integrity Test', () async {
        // 1. Kreiranje i enkripcija podataka
        final originalData =
            OfflineData(content: 'Sensitive data for integrity test');

        final encrypted = await encryption.encryptOfflineData(originalData,
            level: EncryptionLevel.maximum);

        // 2. Provera integriteta enkriptovanih podataka
        final isValid = await integrity.verifyDataIntegrity(OfflineData(
            content: encrypted.content.toString(),
            metadata: encrypted.metadata.toMap()));

        expect(isValid, isTrue);

        // 3. Dekripcija i ponovna provera
        final decrypted = await encryption.decryptOfflineData(encrypted);
        final decryptedIntegrity =
            await integrity.verifyDataIntegrity(decrypted);

        expect(decryptedIntegrity, isTrue);
      });

      test('Recovery After Corruption Test', () async {
        // 1. Priprema test podataka
        final testData = OfflineData(content: 'Test data');
        final encrypted = await encryption.encryptOfflineData(testData);

        // 2. Simulacija korupcije
        final corruptedContent = Uint8List.fromList([...encrypted.content, 0]);
        final corrupted = EncryptedData(
            content: corruptedContent, metadata: encrypted.metadata);

        // 3. Detekcija i recovery
        final detection = await integrity.detectCorruption(corrupted);
        final recovered = await integrity.recoverFromCorruption(detection);

        // 4. Validacija oporavljenih podataka
        final decrypted =
            await encryption.decryptOfflineData(recovered.recoveredData);

        expect(decrypted.content, equals(testData.content));
      });

      test('Stress Test', () async {
        final testData =
            List.generate(100, (i) => OfflineData(content: 'Test data $i'));

        // Paralelna enkripcija i provera integriteta
        await Future.wait(testData.map((data) async {
          final encrypted = await encryption.encryptOfflineData(data);
          final isValid = await integrity.verifyDataIntegrity(OfflineData(
              content: encrypted.content.toString(),
              metadata: encrypted.metadata.toMap()));
          expect(isValid, isTrue);
        }));
      });
    });
  });
}
