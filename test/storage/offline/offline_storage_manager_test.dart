void main() {
  group('Offline Storage Manager Tests', () {
    late OfflineStorageManager storageManager;
    late MockNetworkDiscoveryManager mockDiscoveryManager;
    late MockEmergencyMessageSystem mockMessageSystem;
    late MockEmergencySecurityGuard mockSecurityGuard;
    late MockSecureStorage mockSecureStorage;

    setUp(() {
      mockDiscoveryManager = MockNetworkDiscoveryManager();
      mockMessageSystem = MockEmergencyMessageSystem();
      mockSecurityGuard = MockEmergencySecurityGuard();
      mockSecureStorage = MockSecureStorage();

      storageManager = OfflineStorageManager(
          discoveryManager: mockDiscoveryManager,
          messageSystem: mockMessageSystem,
          securityGuard: mockSecurityGuard);
    });

    group('Message Storage Tests', () {
      test('Valid Message Storage Test', () async {
        final message = SecureMessage(
            id: 'test_message',
            content: Uint8List.fromList([1, 2, 3]),
            timestamp: DateTime.now());

        when(mockSecurityGuard.validateMessageForStorage(any))
            .thenAnswer((_) async => true);

        final result = await storageManager.storeMessage(message);

        expect(result.success, isTrue);
        verify(mockSecurityGuard.validateMessageForStorage(any)).called(1);
      });

      test('Invalid Message Test', () async {
        final invalidMessage = SecureMessage(
            id: 'invalid_message',
            content: Uint8List.fromList([]),
            timestamp: DateTime.now());

        when(mockSecurityGuard.validateMessageForStorage(any))
            .thenAnswer((_) async => false);

        expect(() => storageManager.storeMessage(invalidMessage),
            throwsA(isA<StorageException>()));
      });

      test('Message Retrieval Test', () async {
        final messageId = 'test_message';
        final encryptedData = EncryptedData(
            data: Uint8List.fromList([1, 2, 3]),
            iv: Uint8List.fromList([4, 5, 6]));

        when(mockSecureStorage.retrieve(any))
            .thenAnswer((_) async => encryptedData);

        final message = await storageManager.retrieveMessage(messageId);
        expect(message, isNotNull);
      });
    });

    group('Storage Maintenance Tests', () {
      test('Maintenance Execution Test', () async {
        await storageManager.performMaintenance();

        verify(mockSecureStorage.getSpaceStatus()).called(1);
      });

      test('Storage Cleanup Test', () async {
        when(mockSecureStorage.getSpaceStatus()).thenAnswer((_) async =>
            SpaceStatus(
                available: 1000, total: 10000, timestamp: DateTime.now()));

        await storageManager.performMaintenance();

        verify(mockSecureStorage.cleanOldData(any)).called(1);
      });
    });

    group('Encryption Tests', () {
      test('Data Encryption Test', () async {
        final testData = Uint8List.fromList([1, 2, 3]);

        final preparedData = await storageManager._prepareForStorage(
            SecureMessage(
                id: 'test', content: testData, timestamp: DateTime.now()));

        expect(preparedData.data, isNot(equals(testData)));
      });

      test('Data Decryption Test', () async {
        final encryptedData = EncryptedData(
            data: Uint8List.fromList([1, 2, 3]),
            iv: Uint8List.fromList([4, 5, 6]));

        final message =
            await storageManager._processRetrievedData(encryptedData);

        expect(message, isNotNull);
      });
    });

    group('Monitoring Tests', () {
      test('Storage Event Stream Test', () async {
        final events = storageManager.monitorStorage();

        final storageEvent = StorageEvent(
            type: StorageEventType.dataStored,
            size: 100,
            timestamp: DateTime.now());

        await expectLater(events, emits(storageEvent));
      });

      test('Status Check Test', () async {
        when(mockSecureStorage.getSpaceStatus()).thenAnswer((_) async =>
            SpaceStatus(
                available: 1000, total: 10000, timestamp: DateTime.now()));

        final status = await storageManager.checkStorageStatus();
        expect(status.isHealthy, isTrue);
      });
    });

    group('Integration Tests', () {
      test('Full Storage Lifecycle Test', () async {
        // 1. Store message
        final message = SecureMessage(
            id: 'lifecycle_test',
            content: Uint8List.fromList([1, 2, 3]),
            timestamp: DateTime.now());

        when(mockSecurityGuard.validateMessageForStorage(any))
            .thenAnswer((_) async => true);

        final storeResult = await storageManager.storeMessage(message);
        expect(storeResult.success, isTrue);

        // 2. Retrieve message
        final retrievedMessage =
            await storageManager.retrieveMessage(message.id);
        expect(retrievedMessage, isNotNull);

        // 3. Perform maintenance
        await storageManager.performMaintenance();

        // 4. Check status
        final status = await storageManager.checkStorageStatus();
        expect(status.isHealthy, isTrue);
      });

      test('Recovery Test', () async {
        // 1. Simulate storage error
        when(mockSecureStorage.store(any, any))
            .thenThrow(Exception('Storage error'));

        final message = SecureMessage(
            id: 'error_test',
            content: Uint8List.fromList([1, 2, 3]),
            timestamp: DateTime.now());

        expect(() => storageManager.storeMessage(message), throwsException);

        // 2. Verify recovery
        final status = await storageManager.checkStorageStatus();
        expect(status.isHealthy, isTrue);

        // 3. Try new storage
        when(mockSecureStorage.store(any, any))
            .thenAnswer((_) async => 'new_key');

        final newMessage = SecureMessage(
            id: 'new_message',
            content: Uint8List.fromList([1, 2, 3]),
            timestamp: DateTime.now());

        final result = await storageManager.storeMessage(newMessage);
        expect(result.success, isTrue);
      });
    });
  });
}
