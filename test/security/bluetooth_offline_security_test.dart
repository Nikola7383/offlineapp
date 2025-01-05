void main() {
  group('Bluetooth Offline Security Tests', () {
    late BluetoothOfflineSecurityManager offlineManager;
    late MockBluetoothSecurityManager mockBluetoothSecurity;
    late MockBluetoothIntegrationManager mockIntegrationManager;
    late MockSecurityVault mockVault;
    late MockSyncManager mockSyncManager;

    setUp(() async {
      mockBluetoothSecurity = MockBluetoothSecurityManager();
      mockIntegrationManager = MockBluetoothIntegrationManager();
      mockVault = MockSecurityVault();
      mockSyncManager = MockSyncManager();

      offlineManager = BluetoothOfflineSecurityManager(
          bluetoothSecurity: mockBluetoothSecurity,
          integrationManager: mockIntegrationManager,
          securityVault: mockVault,
          syncManager: mockSyncManager);
    });

    test('Offline Connection Test', () async {
      final mockDevice = MockBluetoothDevice();

      when(mockVault.getSecureData('verified_devices'))
          .thenAnswer((_) async => [
                {
                  'deviceId': 'test_device',
                  'verificationTime': DateTime.now().toIso8601String(),
                  'securityLevel': 'SecurityLevel.maximum'
                }
              ]);

      final result = await offlineManager.secureOfflineConnect(mockDevice);
      expect(result, isTrue);
    });

    test('Operation Queue Test', () async {
      final operation = BluetoothOperation(
          id: 'test_op',
          type: OperationType.dataSend,
          data: [1, 2, 3],
          priority: Priority.high);

      await offlineManager.queueOfflineOperation(operation);

      // Verify queue processing
      await offlineManager._processOfflineQueue();

      verify(mockBluetoothSecurity.executeOperation(any)).called(1);
    });

    test('Offline Verification Test', () async {
      final mockDevice = MockBluetoothDevice();
      final mockConnection = MockBluetoothConnection();

      when(mockConnection.isEncrypted).thenReturn(true);
      when(mockBluetoothSecurity.verifyConnection(any))
          .thenAnswer((_) async => true);

      final isSecure =
          await offlineManager._verifyOfflineConnectionSecurity(mockConnection);

      expect(isSecure, isTrue);
    });

    test('Credential Management Test', () async {
      when(mockVault.getSecureData('offline_credentials'))
          .thenAnswer((_) async => {
                'test_device': {
                  'key': 'test_key',
                  'timestamp': DateTime.now().toIso8601String()
                }
              });

      await offlineManager._loadOfflineCredentials();

      expect(offlineManager._offlineCredentials, isNotEmpty);
    });

    test('Queue Processing Priority Test', () async {
      final highPriorityOp = BluetoothOperation(
          id: 'high_priority',
          type: OperationType.dataSend,
          data: [1, 2, 3],
          priority: Priority.critical);

      final lowPriorityOp = BluetoothOperation(
          id: 'low_priority',
          type: OperationType.dataSend,
          data: [4, 5, 6],
          priority: Priority.low);

      await offlineManager.queueOfflineOperation(lowPriorityOp);
      await offlineManager.queueOfflineOperation(highPriorityOp);

      await offlineManager._processOfflineQueue();

      // Verify high priority operation was processed first
      verifyInOrder([
        mockBluetoothSecurity.executeOperation(highPriorityOp),
        mockBluetoothSecurity.executeOperation(lowPriorityOp)
      ]);
    });
  });
}
