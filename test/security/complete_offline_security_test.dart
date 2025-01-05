void main() {
  group('Complete Offline Security Tests', () {
    late CompleteOfflineSecurityLayer offlineLayer;
    late MockCriticalLayer mockCriticalLayer;
    late MockLocalVault mockLocalVault;
    late MockAirGapController mockAirGap;
    late MockLocalHardware mockHardware;
    late MockLocalBiometric mockBiometric;

    setUp(() {
      mockCriticalLayer = MockCriticalLayer();
      mockLocalVault = MockLocalVault();
      mockAirGap = MockAirGapController();
      mockHardware = MockLocalHardware();
      mockBiometric = MockLocalBiometric();

      offlineLayer = CompleteOfflineSecurityLayer(
          criticalLayer: mockCriticalLayer, localVault: mockLocalVault);
    });

    test('Air Gap Verification Test', () async {
      when(mockAirGap.verifyCompleteIsolation()).thenAnswer((_) async => true);
      when(mockAirGap.enforceNetworkIsolation()).thenAnswer((_) async => true);

      await offlineLayer._verifyAirGap();

      verify(mockAirGap.verifyCompleteIsolation()).called(1);
      verify(mockAirGap.enforceNetworkIsolation()).called(1);
    });

    test('Offline Operation Handling Test', () async {
      final operation = SecurityOperation(
          type: OperationType.authentication,
          data: {'user_id': 'test_user'},
          priority: Priority.high);

      when(mockAirGap.isFullyIsolated()).thenAnswer((_) async => true);
      when(mockHardware.authenticate()).thenAnswer((_) async => true);
      when(mockBiometric.verify()).thenAnswer((_) async => true);

      await offlineLayer.handleSecurityOperation(operation);

      verify(mockAirGap.isFullyIsolated()).called(1);
      verify(mockHardware.authenticate()).called(1);
      verify(mockBiometric.verify()).called(1);
    });

    test('Isolated Execution Test', () async {
      final operation = SecurityOperation(
          type: OperationType.dataAccess,
          data: {'file': 'secure_data.dat'},
          priority: Priority.critical);

      final isolatedContext = MockIsolatedContext();

      when(mockAirGap.isFullyIsolated()).thenAnswer((_) async => true);

      await offlineLayer._executeInIsolation(operation);

      verify(isolatedContext.execute(any)).called(1);
      verify(isolatedContext.dispose()).called(1);
    });

    test('Local Monitoring Test', () async {
      final statusStream = offlineLayer.monitorOfflineSecurity();

      await expectLater(
          statusStream,
          emitsThrough(predicate<OfflineSecurityStatus>((status) =>
              status.airGap.isIsolated &&
              status.hardware.isSecure &&
              status.biometric.isValid)));
    });

    test('Security Issue Handling Test', () async {
      final issue = SecurityIssue(
          type: IssueType.hardwareAnomaly,
          severity: Severity.high,
          source: 'local_hardware');

      await offlineLayer._handleSecurityIssue(issue);

      verify(mockCriticalLayer.handleCriticalEvent(any)).called(1);
    });

    test('Network Isolation Breach Test', () async {
      when(mockAirGap.isFullyIsolated()).thenAnswer((_) async => false);

      expect(
          () => offlineLayer.handleSecurityOperation(SecurityOperation(
              type: OperationType.authentication,
              data: {},
              priority: Priority.normal)),
          throwsA(isA<SecurityException>()));
    });
  });
}
