void main() {
  group('Permission Manager Tests', () {
    late PermissionManager permissionManager;
    late MockRoleHierarchy mockRoleHierarchy;
    late MockPermissionRegistry mockRegistry;
    late MockPermissionCache mockCache;
    late MockPermissionValidator mockValidator;

    setUp(() {
      mockRoleHierarchy = MockRoleHierarchy();
      mockRegistry = MockPermissionRegistry();
      mockCache = MockPermissionCache();
      mockValidator = MockPermissionValidator();

      permissionManager = PermissionManager(roleHierarchy: mockRoleHierarchy);
    });

    test('Permission Check Test', () async {
      const userId = 'test_user';
      const role = SystemRole.admin;
      const permission = Permission.manageUsers;

      when(mockCache.getPermission(userId, role, permission))
          .thenAnswer((_) async => null);

      when(mockRegistry.hasDirectPermission(userId, role, permission))
          .thenAnswer((_) async => true);

      final hasPermission =
          await permissionManager.hasPermission(userId, role, permission);

      expect(hasPermission, isTrue);
      verify(mockCache.cachePermission(userId, role, permission, true))
          .called(1);
    });

    test('Permission Grant Test', () async {
      const userId = 'test_user';
      const role = SystemRole.moderator;
      const permission = Permission.manageChannels;

      when(mockValidator.validatePermissionGrant(userId, role, permission))
          .thenAnswer((_) async => true);

      await permissionManager.grantPermission(userId, role, permission);

      verify(mockRegistry.addPermission(userId, role, permission,
              expiration: null))
          .called(1);
      verify(mockCache.invalidateUserCache(userId)).called(1);
    });

    test('Permission Revoke Test', () async {
      const userId = 'test_user';
      const role = SystemRole.user;
      const permission = Permission.readData;

      when(mockValidator.validatePermissionRevoke(userId, role, permission))
          .thenAnswer((_) async => true);

      await permissionManager.revokePermission(userId, role, permission);

      verify(mockRegistry.removePermission(userId, role, permission)).called(1);
      verify(mockCache.invalidateUserCache(userId)).called(1);
    });

    test('Get User Permissions Test', () async {
      const userId = 'test_user';
      const role = SystemRole.operator;
      final expectedPermissions = {
        Permission.readData,
        Permission.writeData,
        Permission.viewAuditLogs
      };

      when(mockCache.getUserPermissions(userId, role))
          .thenAnswer((_) async => null);

      when(mockRegistry.getDirectPermissions(userId, role))
          .thenAnswer((_) async => expectedPermissions);

      final permissions =
          await permissionManager.getUserPermissions(userId, role);

      expect(permissions, equals(expectedPermissions));
      verify(mockCache.cacheUserPermissions(userId, role, expectedPermissions))
          .called(1);
    });

    test('Permission Change Monitoring Test', () async {
      final event = PermissionChangeEvent(
          userId: 'test_user',
          role: SystemRole.admin,
          permission: Permission.manageUsers,
          type: PermissionChangeType.granted);

      when(mockValidator.validatePermissionChange(event))
          .thenAnswer((_) async => true);

      final changes = permissionManager.monitorPermissionChanges();

      await expectLater(changes, emitsThrough(equals(event)));
    });

    test('Permission Status Check Test', () async {
      const userId = 'test_user';
      const role = SystemRole.moderator;
      const permission = Permission.manageChannels;

      when(mockRegistry.getPermissionExpiration(userId, role, permission))
          .thenAnswer((_) async => DateTime.now().add(Duration(days: 1)));

      final status = await permissionManager.checkPermissionStatus(
          userId, role, permission);

      expect(status.isValid, isTrue);
    });
  });
}
