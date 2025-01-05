void main() {
  group('Hardened Security Tests', () {
    late HardenedSecurity security;
    late MockSecureEventBus mockEventBus;
    late MockMemoryStorage mockMemoryStorage;
    late MockAnonymousIdentityManager mockIdentityManager;

    setUp(() {
      mockEventBus = MockSecureEventBus();
      mockMemoryStorage = MockMemoryStorage();
      mockIdentityManager = MockAnonymousIdentityManager();

      security = HardenedSecurity();
    });

    test('Secure Session Creation Test', () async {
      final identity = await security.createSecureSession();

      expect(identity, isNotNull);
      expect(identity.isValid(), isTrue);
    });

    test('Event Publishing Test', () async {
      final identity = await security.createSecureSession();

      final event = SecureEvent(
          eventId: 'test_event',
          type: EventType.standard,
          data: Uint8List.fromList([1, 2, 3]));

      await security.publishSecureEvent(identity, event);

      verify(mockEventBus.publish(any, any)).called(1);
    });

    test('Event Subscription Test', () async {
      final identity = await security.createSecureSession();

      final events =
          security.subscribeToSecureEvents(identity, EventType.standard);

      final testEvent = SecureEvent(
          eventId: 'test_event',
          type: EventType.standard,
          data: Uint8List.fromList([1, 2, 3]));

      await security.publishSecureEvent(identity, testEvent);

      await expectLater(events,
          emits(predicate<SecureEvent>((e) => e.type == EventType.standard)));
    });

    test('Session Termination Test', () async {
      final identity = await security.createSecureSession();

      await security.terminateSecureSession(identity);

      verify(mockMemoryStorage.secureErase(identity)).called(1);
      verify(mockIdentityManager.revokeIdentity(identity)).called(1);
    });

    test('Security Cleanup Test', () async {
      await security.performSecureCleanup();

      verify(mockMemoryStorage.secureWipe()).called(1);
      verify(mockEventBus.reset()).called(1);
      verify(mockIdentityManager.revokeAllIdentities()).called(1);
    });

    test('Invalid Identity Test', () async {
      final invalidIdentity = await security.createSecureSession();
      await Future.delayed(Duration(hours: 25)); // Simulacija isteka

      expect(
          () => security.publishSecureEvent(
              invalidIdentity,
              SecureEvent(
                  eventId: 'test',
                  type: EventType.standard,
                  data: Uint8List.fromList([]))),
          throwsA(isA<SecurityException>()));
    });

    test('Environment Validation Test', () async {
      when(mockEnvironmentValidator.isSecureEnvironment())
          .thenAnswer((_) async => true);

      final identity = await security.createSecureSession();
      expect(identity, isNotNull);
    });

    test('Memory Protection Test', () async {
      final identity = await security.createSecureSession();

      final event = SecureEvent(
          eventId: 'test_event',
          type: EventType.security,
          data: Uint8List.fromList([1, 2, 3]));

      await security.publishSecureEvent(identity, event);

      verify(mockMemoryGuard.protectMemoryRegion(any)).called(1);
    });

    test('Anti-Debug Protection Test', () async {
      when(mockAntiDebugger.isDebugging()).thenAnswer((_) async => false);

      final identity = await security.createSecureSession();
      expect(identity, isNotNull);
    });

    test('Threat Detection Test', () async {
      when(mockThreatDetector.detectThreats()).thenAnswer((_) async => false);

      final identity = await security.createSecureSession();
      expect(identity, isNotNull);
    });
  });
}
