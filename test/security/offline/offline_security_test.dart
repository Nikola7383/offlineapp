void main() {
  group('Offline Security Tests', () {
    late OfflineSecurityManager offlineSecurity;
    late MockRBACSystem mockRbacSystem;
    late MockLocalStorage mockStorage;
    late MockOfflineCache mockCache;
    late MockStateManager mockStateManager;

    setUp(() {
      mockRbacSystem = MockRBACSystem();
      mockStorage = MockLocalStorage();
      mockCache = MockOfflineCache();
      mockStateManager = MockStateManager();

      offlineSecurity = OfflineSecurityManager(rbacSystem: mockRbacSystem);
    });

    test('Offline Enforcement Test', () async {
      const userId = 'test_user';
      const role = SystemRole.user;
      const permission = Permission.readData;
      const resource = ResourceType.data;

      when(mockStateManager.isOffline()).thenAnswer((_) async => true);

      when(mockCache.getEnforcementDecision(userId, role, permission, resource))
          .thenAnswer((_) async => null);

      final hasAccess = await offlineSecurity.enforceOfflineSecurity(
          userId, role, permission, resource);

      expect(hasAccess, isTrue);
      verify(mockCache.cacheEnforcementDecision(any)).called(1);
    });

    test('Cache Preparation Test', () async {
      when(mockRbacSystem.roleHierarchy.exportHierarchy())
          .thenAnswer((_) async => {});

      when(mockRbacSystem.permissionManager.exportPermissions())
          .thenAnswer((_) async => {});

      await offlineSecurity._prepareOfflineCache();

      verify(mockCache.cacheRoleHierarchy(any)).called(1);
      verify(mockCache.cachePermissions(any)).called(1);
    });

    test('Sync on Reconnect Test', () async {
      when(mockStateManager.isOffline()).thenAnswer((_) async => false);

      when(mockCache.getOfflineDecisions()).thenAnswer((_) async => []);

      when(mockCache.getOfflineLogs()).thenAnswer((_) async => []);

      await offlineSecurity.syncOnReconnect();

      verify(mockCache.clearOfflineData()).called(1);
    });

    test('Offline Status Check Test', () async {
      when(mockStateManager.isOffline()).thenAnswer((_) async => true);

      when(mockCache.getStatus()).thenAnswer((_) async => CacheStatus());

      when(mockIntegrityChecker.checkIntegrity())
          .thenAnswer((_) async => IntegrityStatus());

      final status = await offlineSecurity.checkOfflineStatus();

      expect(status.isOffline, isTrue);
      expect(status.isSecure, isTrue);
    });

    test('Cached Decision Test', () async {
      const userId = 'test_user';
      const role = SystemRole.operator;
      const permission = Permission.writeData;
      const resource = ResourceType.data;

      final cachedDecision = OfflineEnforcementDecision(
          userId: userId,
          role: role,
          permission: permission,
          resource: resource,
          isAllowed: true,
          context: SecurityContext.empty(),
          timestamp: DateTime.now());

      when(mockStateManager.isOffline()).thenAnswer((_) async => true);

      when(mockCache.getEnforcementDecision(userId, role, permission, resource))
          .thenAnswer((_) async => cachedDecision);

      final hasAccess = await offlineSecurity.enforceOfflineSecurity(
          userId, role, permission, resource);

      expect(hasAccess, isTrue);
      verify(mockAuditor.logOfflineDecision(cachedDecision)).called(1);
    });

    test('Integrity Check Test', () async {
      when(mockIntegrityChecker.checkIntegrity())
          .thenAnswer((_) async => IntegrityStatus(isValid: true));

      final status = await offlineSecurity.checkOfflineStatus();

      expect(status.integrityStatus.isValid, isTrue);
    });

    test('Offline Event Monitoring Test', () async {
      final event = OfflineSecurityEvent(
          type: OfflineEventType.stateChange, timestamp: DateTime.now());

      final events = offlineSecurity.monitorOfflineSecurity();

      await expectLater(
          events,
          emitsThrough(
              predicate<OfflineSecurityEvent>((e) => e.type == event.type)));
    });
  });
}
