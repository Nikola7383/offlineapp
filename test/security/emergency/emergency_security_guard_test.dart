void main() {
  group('Emergency Security Guard Tests', () {
    late EmergencySecurityGuard guard;
    late MockEmergencyBootstrapSystem mockBootstrap;
    late MockEmergencyEncryption mockEncryption;
    late MockIsolationEnforcer mockIsolation;
    late MockThreatScanner mockThreatScanner;

    setUp(() {
      mockBootstrap = MockEmergencyBootstrapSystem();
      mockEncryption = MockEmergencyEncryption();
      mockIsolation = MockIsolationEnforcer();
      mockThreatScanner = MockThreatScanner();

      guard = EmergencySecurityGuard(bootstrapSystem: mockBootstrap);
    });

    group('Activation Tests', () {
      test('Security Activation Test', () async {
        when(mockThreatScanner.scanForThreats()).thenAnswer((_) async => []);

        final status = await guard.activateEmergencySecurity();

        expect(status.isActive, isTrue);
        expect(status.securityLevel, equals(SecurityLevel.maximum));
      });

      test('Unsafe System Test', () async {
        when(mockThreatScanner.scanForThreats())
            .thenAnswer((_) async => [SecurityThreat()]);

        expect(() => guard.activateEmergencySecurity(),
            throwsA(isA<EmergencySecurityException>()));
      });

      test('Isolation Test', () async {
        await guard.activateEmergencySecurity();

        verify(mockIsolation.enforceNetworkIsolation()).called(1);
        verify(mockIsolation.restrictCommunication(any)).called(1);
      });
    });

    group('Protection Tests', () {
      test('Threat Detection Test', () async {
        final threat = SecurityThreat(
            type: ThreatType.maliciousActivity, severity: ThreatSeverity.high);

        await guard.handleSecurityThreat(threat);

        verify(mockThreatScanner.assessThreat(threat)).called(1);
      });

      test('Message Validation Test', () async {
        final message = EmergencyMessage(
            content: 'Test message',
            sender: LocalUser(id: 'test_user'),
            timestamp: DateTime.now());

        final isValid = await guard.validateMessage(message);
        expect(isValid, isTrue);
      });

      test('Malicious Message Test', () async {
        final maliciousMessage = EmergencyMessage(
            content: 'Malicious content',
            sender: LocalUser(id: 'suspicious_user'),
            timestamp: DateTime.now());

        when(mockThreatScanner.scanMessageContent(any))
            .thenAnswer((_) async => true);

        final isValid = await guard.validateMessage(maliciousMessage);
        expect(isValid, isFalse);
      });
    });

    group('Monitoring Tests', () {
      test('Security Event Monitoring Test', () async {
        final events = guard.monitorSecurity();

        final securityEvent = SecurityEvent(
            type: SecurityEventType.normal,
            source: EventSource.system,
            timestamp: DateTime.now());

        await expectLater(events, emits(securityEvent));
      });

      test('Anomaly Detection Test', () async {
        final anomalousEvent = SecurityEvent(
            type: SecurityEventType.suspicious,
            source: EventSource.user,
            timestamp: DateTime.now());

        when(mockThreatScanner.isEventThreatening(any))
            .thenAnswer((_) async => true);

        final events = guard.monitorSecurity();

        await expectLater(events, neverEmits(anomalousEvent));
      });
    });

    group('Integration Tests', () {
      test('Full Security Lifecycle Test', () async {
        // 1. Aktivacija
        final status = await guard.activateEmergencySecurity();
        expect(status.isSecure, isTrue);

        // 2. Message handling
        final message = EmergencyMessage(
            content: 'Test message',
            sender: LocalUser(id: 'test_user'),
            timestamp: DateTime.now());

        final isValid = await guard.validateMessage(message);
        expect(isValid, isTrue);

        // 3. Threat handling
        final threat = SecurityThreat(
            type: ThreatType.suspiciousActivity,
            severity: ThreatSeverity.medium);

        await guard.handleSecurityThreat(threat);

        // 4. Status provera
        final finalStatus = await guard.checkSecurityStatus();
        expect(finalStatus.isSecure, isTrue);
      });

      test('Recovery Test', () async {
        // 1. Simulacija pretnje
        final threat = SecurityThreat(
            type: ThreatType.maliciousActivity,
            severity: ThreatSeverity.critical);

        await guard.handleSecurityThreat(threat);

        // 2. Provera recovery-ja
        final status = await guard.checkSecurityStatus();
        expect(status.isSecure, isTrue);

        // 3. Validation nakon recovery-ja
        final message = EmergencyMessage(
            content: 'Post-recovery message',
            sender: LocalUser(id: 'test_user'),
            timestamp: DateTime.now());

        final isValid = await guard.validateMessage(message);
        expect(isValid, isTrue);
      });
    });
  });
}
