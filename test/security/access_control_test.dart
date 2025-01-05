void main() {
  group('Access Control System Tests', () {
    late AccessControlSystem accessControl;
    late MockPermissionManager mockPermissionManager;
    late MockRoleHierarchy mockRoleHierarchy;
    late MockACLRegistry mockRegistry;
    late MockACLValidator mockValidator;
    late MockACLCache mockCache;

    setUp(() {
      mockPermissionManager = MockPermissionManager();
      mockRoleHierarchy = MockRoleHierarchy();
      mockRegistry = MockACLRegistry();
      mockValidator = MockACLValidator();
      mockCache = MockACLCache();

      accessControl = AccessControlSystem(
          permissionManager: mockPermissionManager,
          roleHierarchy: mockRoleHierarchy);
    });

    test('Access Check Test', () async {
      const userId = 'test_user';
      const role = SystemRole.admin;
      const resource = ResourceType.data;
      const operation = AccessOperation.read;

      when(mockCache.getAccessDecision(userId, role, resource, operation))
          .thenAnswer((_) async => null);

      when(mockRegistry.hasDirectAccess(userId, role, resource, operation))
          .thenAnswer((_) async => true);

      final hasAccess =
          await accessControl.checkAccess(userId, role, resource, operation);

      expect(hasAccess, isTrue);
      verify(mockCache.cacheAccessDecision(
              userId, role, resource, operation, true))
          .called(1);
    });

    test('Access Grant Test', () async {
      const userId = 'test_user';
      const role = SystemRole.moderator;
      const resource = ResourceType.communication;
      final operations = {AccessOperation.read, AccessOperation.write};

      when(mockValidator.validateAccessGrant(
              userId, role, resource, operations))
          .thenAnswer((_) async => true);

      await accessControl.grantAccess(userId, role, resource, operations);

      verify(mockRegistry.addACL(any)).called(1);
      verify(mockCache.invalidateForResource(resource)).called(1);
    });

    test('Access Revoke Test', () async {
      const userId = 'test_user';
      const role = SystemRole.user;
      const resource = ResourceType.data;
      final operations = {AccessOperation.read};

      when(mockValidator.validateAccessRevoke(
              userId, role, resource, operations))
          .thenAnswer((_) async => true);

      await accessControl.revokeAccess(userId, role, resource, operations);

      verify(mockRegistry.removeAccess(userId, role, resource, operations))
          .called(1);
      verify(mockCache.invalidateForResource(resource)).called(1);
    });

    test('Resource Access Status Test', () async {
      const userId = 'test_user';
      const role = SystemRole.operator;
      const resource = ResourceType.system;

      final acls = [
        AccessControlEntry(
            userId: userId,
            role: role,
            resource: resource,
            operations: {AccessOperation.read, AccessOperation.execute},
            policy: AccessPolicy())
      ];

      when(mockRegistry.getACLsForResource(resource))
          .thenAnswer((_) async => acls);

      final status =
          await accessControl.getResourceAccess(userId, role, resource);

      expect(status.allowedOperations, contains(AccessOperation.read));
      expect(status.allowedOperations, contains(AccessOperation.execute));
    });

    test('Access Change Monitoring Test', () async {
      final event = ACLChangeEvent(
          userId: 'test_user',
          role: SystemRole.admin,
          resource: ResourceType.security,
          operations: {AccessOperation.manage},
          type: ACLChangeType.granted);

      when(mockValidator.validateACLChange(event))
          .thenAnswer((_) async => true);

      final changes = accessControl.monitorAccessChanges();

      await expectLater(changes, emitsThrough(equals(event)));
    });
  });
}
