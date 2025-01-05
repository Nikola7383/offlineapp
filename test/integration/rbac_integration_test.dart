void main() {
  group('RBAC Integration Tests', () {
    late RBACSystem rbacSystem;
    late SecurityContext testContext;

    setUpAll(() async {
      // Inicijalizacija kompletnog RBAC sistema
      rbacSystem = await RBACSystem.initialize(
          config: SecurityConfig(
              enforceStrictValidation: true,
              enableAuditLogging: true,
              cacheEnabled: true,
              emergencyModeEnabled: true));

      testContext = SecurityContext(
          deviceId: 'test_device_001',
          timestamp: DateTime.now(),
          location: 'test_location',
          securityLevel: SecurityLevel.high,
          attributes: {
            'environment': 'test',
            'session_type': 'integration_test'
          });
    });

    test('Complete User Role Lifecycle Test', () async {
      const userId = 'test_user_001';
      const initialRole = SystemRole.user;

      // 1. Kreiranje korisnika sa osnovnom ulogom
      await rbacSystem.createUser(
          userId: userId, initialRole: initialRole, context: testContext);

      // 2. Provera osnovnih permisija
      final basePermissions = await rbacSystem.permissionManager
          .getUserPermissions(userId, initialRole);
      expect(basePermissions, isNotEmpty);

      // 3. Dodela privremene admin uloge
      await rbacSystem.softRbac.assignTemporaryRole(
          userId, SystemRole.admin, Duration(hours: 1),
          context: testContext);

      // 4. Provera kombinovanih permisija
      final enhancedPermissions = await rbacSystem.permissionManager
          .getUserPermissions(userId, SystemRole.admin);
      expect(enhancedPermissions.length, greaterThan(basePermissions.length));

      // 5. Validacija pristupa resursu
      final hasAccess = await rbacSystem.accessControl.checkAccess(userId,
          SystemRole.admin, ResourceType.system, AccessOperation.configure);
      expect(hasAccess, isTrue);
    });

    test('Dynamic Permission Enforcement Test', () async {
      const userId = 'test_user_002';
      const role = SystemRole.operator;

      // 1. Setup kontekstualnih permisija
      await rbacSystem.softRbac.grantContextualPermission(
          userId, Permission.manageSystem, testContext, conditions: {
        Condition('time_window', '9:00-17:00'),
        Condition('location', 'test_location')
      });

      // 2. Provera enforcement-a u različitim kontekstima
      final normalContext = testContext;
      final afterHoursContext = SecurityContext(
          deviceId: testContext.deviceId,
          timestamp: DateTime.now().add(Duration(hours: 12)),
          location: testContext.location,
          securityLevel: testContext.securityLevel);

      final normalAccess = await rbacSystem.enforcement.enforcePermission(
          userId, role, Permission.manageSystem, ResourceType.system,
          context: normalContext);
      expect(normalAccess.isAllowed, isTrue);

      final afterHoursAccess = await rbacSystem.enforcement.enforcePermission(
          userId, role, Permission.manageSystem, ResourceType.system,
          context: afterHoursContext);
      expect(afterHoursAccess.isAllowed, isFalse);
    });

    test('Role Hierarchy and Inheritance Test', () async {
      const userId = 'test_user_003';

      // 1. Testiranje hijerarhije uloga
      final hierarchy = await rbacSystem.roleHierarchy
          .getAllSubordinateRoles(SystemRole.superAdmin);
      expect(hierarchy, contains(SystemRole.admin));
      expect(hierarchy, contains(SystemRole.user));

      // 2. Provera nasleđenih permisija
      await rbacSystem.createUser(
          userId: userId, initialRole: SystemRole.admin, context: testContext);

      final permissions = await rbacSystem.permissionManager
          .getUserPermissions(userId, SystemRole.admin);

      final hasUserPermissions = permissions.containsAll(await rbacSystem
          .permissionManager
          .getRolePermissions(SystemRole.user));
      expect(hasUserPermissions, isTrue);
    });

    test('Emergency Access and Override Test', () async {
      const userId = 'test_user_004';
      const role = SystemRole.operator;

      // 1. Setup emergency situacije
      await rbacSystem.emergencyManager.declareEmergency(
          level: EmergencyLevel.critical,
          reason: 'Integration Test Emergency',
          declaredBy: 'test_admin');

      // 2. Provera emergency override-a
      final emergencyAccess = await rbacSystem.enforcement.enforcePermission(
          userId, role, Permission.triggerEmergency, ResourceType.emergency,
          emergencyLevel: EmergencyLevel.critical);
      expect(emergencyAccess.isAllowed, isTrue);

      // 3. Provera logging-a emergency pristupa
      final auditLogs = await rbacSystem.auditor.getEmergencyAccessLogs(userId);
      expect(auditLogs, isNotEmpty);
    });

    test('Delegation and Transfer of Authority Test', () async {
      const fromUserId = 'test_admin_001';
      const toUserId = 'test_user_005';

      // 1. Setup delegacije
      final delegatedPermissions = {
        Permission.manageUsers,
        Permission.viewAuditLogs
      };

      await rbacSystem.softRbac.delegateAuthority(
          fromUserId, toUserId, delegatedPermissions,
          duration: Duration(hours: 4), context: testContext);

      // 2. Provera delegiranih permisija
      final hasAccess = await rbacSystem.enforcement.enforcePermission(
          toUserId, SystemRole.user, Permission.manageUsers, ResourceType.user);
      expect(hasAccess.isAllowed, isTrue);

      // 3. Provera originalne autorizacije
      final originalAccess = await rbacSystem.enforcement.enforcePermission(
          fromUserId,
          SystemRole.admin,
          Permission.manageUsers,
          ResourceType.user);
      expect(originalAccess.isAllowed, isTrue);
    });

    test('Audit and Monitoring Integration Test', () async {
      const userId = 'test_user_006';

      // 1. Setup monitoring-a
      final events = rbacSystem.monitorAllEvents();
      final recordedEvents = <SecurityEvent>[];

      final subscription = events.listen((event) {
        recordedEvents.add(event);
      });

      // 2. Izvršavanje akcija
      await rbacSystem.createUser(
          userId: userId, initialRole: SystemRole.user, context: testContext);

      await rbacSystem.softRbac.assignTemporaryRole(
          userId, SystemRole.moderator, Duration(hours: 1));

      await rbacSystem.permissionManager.grantPermission(
          userId, SystemRole.moderator, Permission.manageChannels);

      // 3. Provera audit logova
      await Future.delayed(Duration(seconds: 1));
      expect(recordedEvents.length, greaterThanOrEqual(3));

      final auditLogs = await rbacSystem.auditor.getUserActivityLogs(userId);
      expect(auditLogs, isNotEmpty);

      await subscription.cancel();
    });
  });
}
