void main() {
  group('WiFi Security Tests', () {
    late WifiSecurityManager securityManager;
    late MockWifiDirectManager mockDirectManager;
    late MockWifiMeshManager mockMeshManager;
    late MockSecurityStateManager mockStateManager;
    late MockEncryptionManager mockEncryptionManager;

    setUp(() {
      mockDirectManager = MockWifiDirectManager();
      mockMeshManager = MockWifiMeshManager();
      mockStateManager = MockSecurityStateManager();
      mockEncryptionManager = MockEncryptionManager();

      securityManager = WifiSecurityManager(
          directManager: mockDirectManager,
          meshManager: mockMeshManager,
          stateManager: mockStateManager,
          encryptionManager: mockEncryptionManager);
    });

    test('Direct Connection Test', () async {
      final mockPeer = MockWifiPeer();
      final mockChannel = MockSecureChannel();

      when(mockDirectManager.establishSecureChannel(any))
          .thenAnswer((_) async => mockChannel);

      final result =
          await securityManager.establishSecureDirectConnection(mockPeer);

      expect(result, isTrue);
      verify(mockDirectManager.establishSecureChannel(mockPeer)).called(1);
    });

    test('Mesh Network Join Test', () async {
      final mockMeshConnection = MockMeshConnection();
      final mockNodes = [MockMeshNode(), MockMeshNode()];

      when(mockMeshManager.joinMeshNetwork())
          .thenAnswer((_) async => mockMeshConnection);
      when(mockMeshManager.getAvailableNodes())
          .thenAnswer((_) async => mockNodes);

      final result = await securityManager.joinSecureMeshNetwork();

      expect(result, isTrue);
      verify(mockMeshManager.joinMeshNetwork()).called(1);
    });

    test('Secure Data Transfer Test', () async {
      final testData = 'Test Data';
      final mockPeer = MockWifiPeer();
      final encryptedData = 'Encrypted Data';

      when(mockEncryptionManager.encryptData(testData, EncryptionLevel.maximum))
          .thenAnswer((_) async => encryptedData);

      await securityManager.sendSecureData(testData, peerId: mockPeer.id);

      verify(mockEncryptionManager.encryptData(
              testData, EncryptionLevel.maximum))
          .called(1);
    });

    test('Security Monitoring Test', () async {
      final mockPeer = MockWifiPeer();
      final mockChannel = MockSecureChannel();

      when(mockDirectManager.connectionStream)
          .thenAnswer((_) => Stream.fromIterable([
                WifiConnectionEvent(
                    type: ConnectionEventType.connected,
                    peer: mockPeer,
                    channel: mockChannel)
              ]));

      // Trigger monitoring
      await Future.delayed(Duration(seconds: 1));

      verify(mockDirectManager.connectionStream).called(1);
    });

    test('Mesh Node Verification Test', () async {
      final mockNode = MockMeshNode();
      final mockChannel = MockSecureChannel();

      when(mockMeshManager.establishNodeChannel(any))
          .thenAnswer((_) async => mockChannel);

      await securityManager._establishMeshSecureChannels(MockMeshConnection());

      verify(mockMeshManager.establishNodeChannel(any)).called(1);
    });
  });
}
