void main() {
  group('Emergency Data Manager Tests', () {
    late EmergencyDataManager dataManager;
    late MockSecureStorage mockSecureStorage;
    late MockLocalDatabase mockLocalDatabase;
    late MockDataCompressor mockDataCompressor;
    late MockDataEncryptor mockDataEncryptor;

    setUp(() {
      mockSecureStorage = MockSecureStorage();
      mockLocalDatabase = MockLocalDatabase();
      mockDataCompressor = MockDataCompressor();
      mockDataEncryptor = MockDataEncryptor();

      dataManager = EmergencyDataManager();
    });

    group('Data Storage Tests', () {
      test('Save Data Test', () async {
        final testData = EmergencyData(
            id: 'test_data',
            content: 'Test content',
            priority: DataPriority.high,
            timestamp: DateTime.now());

        await dataManager.saveData(testData);

        verify(mockSecureStorage.saveData(any)).called(1);
        verify(mockDataCompressor.compressData(any, any)).called(1);
        verify(mockDataEncryptor.encryptData(any, any)).called(1);
      });

      test('Get Data Test', () async {
        final testId = 'test_data';

        when(mockSecureStorage.getData(testId)).thenAnswer((_) async =>
            StoredData(
                data: EncryptedData([]),
                encryptionLevel: EncryptionLevel.high,
                compressionLevel: CompressionLevel.high));

        final data = await dataManager.getData(testId);
        expect(data, isNotNull);
      });
    });

    group('Data Processing Tests', () {
      test('Data Compression Test', () async {
        final testData = EmergencyData(
            id: 'test_data',
            content: 'Test content',
            priority: DataPriority.high,
            timestamp: DateTime.now());

        final processedData =
            await dataManager._processDataForStorage(testData);
        expect(processedData.priority, DataPriority.high);
      });

      test('Data Encryption Test', () async {
        final testData = EmergencyData(
            id: 'test_data',
            content: 'Test content',
            priority: DataPriority.critical,
            timestamp: DateTime.now());

        final processedData =
            await dataManager._processDataForStorage(testData);
        expect(processedData.processedData, isNotNull);
      });
    });

    group('Space Management Tests', () {
      test('Space Check Test', () async {
        when(mockSecureStorage.getAvailableSpace())
            .thenAnswer((_) async => 1024 * 1024); // 1MB

        await dataManager._ensureSpaceAvailable(512 * 1024); // 512KB

        verify(mockSecureStorage.getAvailableSpace()).called(1);
      });

      test('Space Cleanup Test', () async {
        when(mockSecureStorage.getAvailableSpace())
            .thenAnswer((_) async => 100 * 1024); // 100KB

        await dataManager._freeUpSpace(512 * 1024); // Need 512KB

        verify(mockSecureStorage.clearOldData()).called(1);
      });
    });

    group('Sync Tests', () {
      test('Sync Process Test', () async {
        await dataManager.syncData();

        verify(dataManager._changeTracker.getUnsynedChanges()).called(1);
        verify(dataManager._conflictResolver.resolveConflicts(any)).called(1);
      });

      test('Conflict Resolution Test', () async {
        final changes = [
          DataChange(id: 'change1', type: ChangeType.update),
          DataChange(id: 'change2', type: ChangeType.delete)
        ];

        when(dataManager._changeTracker.getUnsynedChanges())
            .thenAnswer((_) async => changes);

        await dataManager.syncData();

        verify(dataManager._conflictResolver.resolveConflicts(changes))
            .called(1);
      });
    });

    group('Monitoring Tests', () {
      test('Data Event Stream Test', () async {
        final events = dataManager.monitorData();

        final dataEvent = DataEvent(
            type: DataEventType.saved,
            dataId: 'test_data',
            timestamp: DateTime.now());

        await expectLater(events, emits(dataEvent));
      });

      test('Status Check Test', () async {
        final status = await dataManager.checkStatus();
        expect(status.isHealthy, isTrue);
      });
    });

    group('Error Handling Tests', () {
      test('Invalid Data Test', () async {
        final invalidData = EmergencyData(
            id: '',
            content: '',
            priority: DataPriority.low,
            timestamp: DateTime.now());

        expect(() => dataManager.saveData(invalidData),
            throwsA(isA<DataValidationException>()));
      });

      test('Storage Error Test', () async {
        when(mockSecureStorage.saveData(any))
            .thenThrow(StorageException('Storage error'));

        final testData = EmergencyData(
            id: 'test_data',
            content: 'Test content',
            priority: DataPriority.medium,
            timestamp: DateTime.now());

        expect(() => dataManager.saveData(testData),
            throwsA(isA<StorageException>()));
      });
    });

    group('Integration Tests', () {
      test('Full Data Lifecycle Test', () async {
        // 1. Save data
        final testData = EmergencyData(
            id: 'test_data',
            content: 'Test content',
            priority: DataPriority.high,
            timestamp: DateTime.now());

        await dataManager.saveData(testData);

        // 2. Get data
        final retrievedData = await dataManager.getData(testData.id);
        expect(retrievedData.id, testData.id);

        // 3. Sync data
        await dataManager.syncData();

        // 4. Check status
        final status = await dataManager.checkStatus();
        expect(status.isHealthy, isTrue);
      });

      test('Recovery Test', () async {
        // 1. Simulate error
        when(mockSecureStorage.saveData(any))
            .thenThrow(StorageException('Storage error'));

        // 2. Try save
        final testData = EmergencyData(
            id: 'test_data',
            content: 'Test content',
            priority: DataPriority.high,
            timestamp: DateTime.now());

        expect(() => dataManager.saveData(testData),
            throwsA(isA<StorageException>()));

        // 3. Verify recovery
        final status = await dataManager.checkStatus();
        expect(status.isHealthy, isTrue);

        // 4. Try again with fixed storage
        when(mockSecureStorage.saveData(any)).thenAnswer((_) async => true);

        await dataManager.saveData(testData);
        final retrievedData = await dataManager.getData(testData.id);
        expect(retrievedData.id, testData.id);
      });
    });
  });
}
