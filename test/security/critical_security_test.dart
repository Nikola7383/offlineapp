void main() {
  group('Critical Security Layer Tests', () {
    late CriticalSecurityLayer criticalLayer;
    late MockEmergencySystem mockEmergencySystem;
    late MockCriticalVault mockCriticalVault;
    late MockHSM mockHSM;
    late MockBiometric mockBiometric;
    late MockEncryptionCore mockEncryptionCore;

    setUp(() {
      mockEmergencySystem = MockEmergencySystem();
      mockCriticalVault = MockCriticalVault();
      mockHSM = MockHSM();
      mockBiometric = MockBiometric();
      mockEncryptionCore = MockEncryptionCore();

      criticalLayer = CriticalSecurityLayer(
          emergencySystem: mockEmergencySystem,
          criticalVault: mockCriticalVault);
    });

    test('Hardware Security Initialization Test', () async {
      when(mockHSM.initialize(
              securityLevel: SecurityLevel.maximum,
              verificationMode: VerificationMode.continuous))
          .thenAnswer((_) async => true);

      await criticalLayer._initializeHardwareSecurity();

      verify(mockHSM.initialize(
              securityLevel: SecurityLevel.maximum,
              verificationMode: VerificationMode.continuous))
          .called(1);
    });

    test('Critical Event Handling Test', () async {
      final event = CriticalEvent(
          type: CriticalEventType.securityBreach,
          severity: Severity.critical,
          source: 'test_source',
          timestamp: DateTime.now());

      await criticalLayer.handleCriticalEvent(event);

      verify(mockEmergencySystem.activateEmergencyMode(any)).called(1);
    });

    test('Immediate Response Execution Test', () async {
      final response = CriticalResponse(
          level: ResponseLevel.immediate,
          actions: [SecurityAction.isolate, SecurityAction.encrypt],
          priority: Priority.critical);

      await criticalLayer._executeImmediateResponse(response);

      verify(mockHSM.activateProtection()).called(1);
      verify(mockEncryptionCore.encryptCritical()).called(1);
    });

    test('Critical System Monitoring Test', () async {
      final statusStream = criticalLayer.monitorCriticalStatus();

      await expectLater(
          statusStream,
          emitsThrough(predicate<CriticalSystemStatus>((status) =>
              status.hsm.isSecure &&
              status.biometric.isValid &&
              status.encryption.isEncrypted)));
    });

    test('Hardware Security Breach Test', () async {
      final breachStatus = HSMStatus(
          isSecure: false,
          breachType: BreachType.tampering,
          timestamp: DateTime.now());

      when(mockHSM.status).thenAnswer((_) => Stream.value(breachStatus));

      await criticalLayer._monitorCriticalSystems();

      verify(mockEmergencySystem.activateEmergencyMode(any)).called(1);
    });

    test('Biometric Verification Failure Test', () async {
      final failureResult = BiometricResult(
          isValid: false,
          failureReason: 'unauthorized_attempt',
          timestamp: DateTime.now());

      when(mockBiometric.verificationStream)
          .thenAnswer((_) => Stream.value(failureResult));

      await criticalLayer._monitorCriticalSystems();

      verify(mockEmergencySystem.activateEmergencyMode(any)).called(1);
    });

    test('Critical Error Handling Test', () async {
      final error = SecurityException('Critical test error');
      final event = CriticalEvent(
          type: CriticalEventType.systemFailure,
          severity: Severity.critical,
          source: 'test');

      await criticalLayer._handleCriticalError(error, event);

      verify(mockEmergencySystem.activateEmergencyMode(any)).called(1);
    });
  });
}
