import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/interfaces/logger_service_interface.dart';
import 'package:secure_event_app/security/access_control_manager.dart';
import 'package:secure_event_app/models/access_control_types.dart';
import '../mocks/security_mocks.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late AccessControlManager manager;

  setUp(() {
    mockLogger = MockILoggerService();
    manager = AccessControlManager(mockLogger);
  });

  test('initialize() postavlja isInitialized na true', () async {
    expect(manager.isInitialized, false);
    await manager.initialize();
    expect(manager.isInitialized, true);
    verify(mockLogger.info(any)).called(1);
  });

  test('initialize() ne inicijalizuje već inicijalizovan menadžer', () async {
    await manager.initialize();
    await manager.initialize();
    verify(mockLogger.warning(any)).called(1);
  });

  test('dispose() čisti resurse i postavlja isInitialized na false', () async {
    await manager.initialize();
    await manager.dispose();
    expect(manager.isInitialized, false);
    verify(mockLogger.info(any)).called(2);
  });

  test('dispose() ne gasi neinicijalizovan menadžer', () async {
    await manager.dispose();
    verify(mockLogger.warning(any)).called(1);
  });

  group('checkAccess()', () {
    const userId = 'user1';
    const resourceType = ResourceType.file;
    const operation = AccessOperation.read;

    setUp(() async {
      await manager.initialize();
    });

    test('baca grešku ako nije inicijalizovan', () async {
      await manager.dispose();
      expect(
        () => manager.checkAccess(
          userId: userId,
          resourceType: resourceType,
          operation: operation,
        ),
        throwsStateError,
      );
    });

    test('admin ima pristup svim resursima', () async {
      await manager.assignRole(userId: userId, role: UserRole.admin);

      final result = await manager.checkAccess(
        userId: userId,
        resourceType: resourceType,
        operation: operation,
      );

      expect(result.isAllowed, true);
      expect(result.reason, contains('Admin'));
    });

    test('korisnik bez dozvole nema pristup', () async {
      final result = await manager.checkAccess(
        userId: userId,
        resourceType: resourceType,
        operation: operation,
      );

      expect(result.isAllowed, false);
      expect(result.reason, contains('Nedostatak'));
    });

    test('korisnik sa dozvolom ima pristup', () async {
      await manager.grantPermission(
        userId: userId,
        resourceType: resourceType,
        operations: {operation},
      );

      final result = await manager.checkAccess(
        userId: userId,
        resourceType: resourceType,
        operation: operation,
      );

      expect(result.isAllowed, true);
      expect(result.reason, contains('odobrena'));
    });
  });

  group('Role management', () {
    const userId = 'user1';
    const role = UserRole.security;

    setUp(() async {
      await manager.initialize();
    });

    test('assignRole() dodeljuje rolu korisniku', () async {
      await manager.assignRole(userId: userId, role: role);

      final roles = await manager.getUserRoles(userId);
      expect(roles, contains(role));
    });

    test('revokeRole() uklanja rolu od korisnika', () async {
      await manager.assignRole(userId: userId, role: role);
      await manager.revokeRole(userId: userId, role: role);

      final roles = await manager.getUserRoles(userId);
      expect(roles, isEmpty);
    });

    test('isInRole() vraća tačno ako korisnik ima rolu', () async {
      await manager.assignRole(userId: userId, role: role);
      expect(await manager.isInRole(userId: userId, role: role), true);
    });

    test('isInRole() vraća netačno ako korisnik nema rolu', () async {
      expect(await manager.isInRole(userId: userId, role: role), false);
    });
  });

  group('Permission management', () {
    const userId = 'user1';
    const resourceType = ResourceType.file;
    const operations = {AccessOperation.read, AccessOperation.write};

    setUp(() async {
      await manager.initialize();
    });

    test('grantPermission() dodaje dozvolu korisniku', () async {
      await manager.grantPermission(
        userId: userId,
        resourceType: resourceType,
        operations: operations,
      );

      final permissions = await manager.getUserPermissions(userId);
      expect(permissions, hasLength(1));
      expect(permissions.first.resourceType, resourceType);
      expect(permissions.first.operations, operations);
    });

    test('revokePermission() uklanja dozvolu od korisnika', () async {
      await manager.grantPermission(
        userId: userId,
        resourceType: resourceType,
        operations: operations,
      );

      await manager.revokePermission(
        userId: userId,
        resourceType: resourceType,
        operations: operations,
      );

      final permissions = await manager.getUserPermissions(userId);
      expect(permissions, isEmpty);
    });
  });

  group('Access history', () {
    const userId = 'user1';
    const resourceType = ResourceType.file;
    const operation = AccessOperation.read;

    setUp(() async {
      await manager.initialize();
    });

    test('getAccessHistory() vraća istoriju pristupa', () async {
      await manager.checkAccess(
        userId: userId,
        resourceType: resourceType,
        operation: operation,
      );

      final history = await manager.getAccessHistory(userId: userId);
      expect(history, hasLength(1));
      expect(history.first.userId, userId);
      expect(history.first.resourceType, resourceType);
      expect(history.first.operation, operation);
    });

    test('getAccessHistory() filtrira po vremenu', () async {
      await manager.checkAccess(
        userId: userId,
        resourceType: resourceType,
        operation: operation,
      );

      final now = DateTime.now();
      final history = await manager.getAccessHistory(
        userId: userId,
        from: now.subtract(Duration(minutes: 1)),
        to: now.add(Duration(minutes: 1)),
      );

      expect(history, hasLength(1));
    });

    test('getAccessHistory() poštuje limit', () async {
      for (var i = 0; i < 5; i++) {
        await manager.checkAccess(
          userId: userId,
          resourceType: resourceType,
          operation: operation,
        );
      }

      final history = await manager.getAccessHistory(
        userId: userId,
        limit: 3,
      );

      expect(history, hasLength(3));
    });
  });

  group('Access tokens', () {
    const userId = 'user1';
    final resources = {ResourceType.file};
    final operations = {AccessOperation.read};

    setUp(() async {
      await manager.initialize();
    });

    test('generateAccessToken() kreira validan token', () async {
      final token = await manager.generateAccessToken(
        userId: userId,
        resources: resources,
        operations: operations,
      );

      expect(await manager.validateAccessToken(token), true);
    });

    test('validateAccessToken() vraća false za nepostojeći token', () async {
      expect(await manager.validateAccessToken('invalid'), false);
    });

    test('validateAccessToken() vraća false za istekli token', () async {
      final token = await manager.generateAccessToken(
        userId: userId,
        resources: resources,
        operations: operations,
        expiration: Duration(microseconds: 1),
      );

      await Future.delayed(Duration(milliseconds: 1));
      expect(await manager.validateAccessToken(token), false);
    });
  });

  group('Events', () {
    const userId = 'user1';
    const role = UserRole.security;
    const resourceType = ResourceType.file;
    const operations = {AccessOperation.read};

    setUp(() async {
      await manager.initialize();
    });

    test('emituje AccessAttempted event', () async {
      expectLater(
        manager.accessEvents,
        emits(isA<AccessAttempted>()),
      );

      await manager.checkAccess(
        userId: userId,
        resourceType: resourceType,
        operation: AccessOperation.read,
      );
    });

    test('emituje RoleAssigned event', () async {
      expectLater(
        manager.accessEvents,
        emits(isA<RoleAssigned>()),
      );

      await manager.assignRole(userId: userId, role: role);
    });

    test('emituje RoleRevoked event', () async {
      await manager.assignRole(userId: userId, role: role);

      expectLater(
        manager.accessEvents,
        emits(isA<RoleRevoked>()),
      );

      await manager.revokeRole(userId: userId, role: role);
    });

    test('emituje PermissionGranted event', () async {
      expectLater(
        manager.accessEvents,
        emits(isA<PermissionGranted>()),
      );

      await manager.grantPermission(
        userId: userId,
        resourceType: resourceType,
        operations: operations,
      );
    });

    test('emituje PermissionRevoked event', () async {
      await manager.grantPermission(
        userId: userId,
        resourceType: resourceType,
        operations: operations,
      );

      expectLater(
        manager.accessEvents,
        emits(isA<PermissionRevoked>()),
      );

      await manager.revokePermission(
        userId: userId,
        resourceType: resourceType,
        operations: operations,
      );
    });
  });
}
