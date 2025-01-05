class PermissionManager extends SecurityBaseComponent {
  // Core komponente
  final RoleHierarchy _roleHierarchy;
  final PermissionRegistry _permissionRegistry;
  final PermissionCache _permissionCache;

  // Validacione komponente
  final PermissionValidator _validator;
  final AccessController _accessController;
  final PermissionAuditor _auditor;

  // Security komponente
  final PermissionEncryption _encryption;
  final PermissionBackup _backup;
  final ConflictResolver _conflictResolver;

  PermissionManager({required RoleHierarchy roleHierarchy})
      : _roleHierarchy = roleHierarchy,
        _permissionRegistry = PermissionRegistry(),
        _permissionCache = PermissionCache(),
        _validator = PermissionValidator(),
        _accessController = AccessController(),
        _auditor = PermissionAuditor(),
        _encryption = PermissionEncryption(),
        _backup = PermissionBackup(),
        _conflictResolver = ConflictResolver() {
    _initializeManager();
  }

  Future<void> _initializeManager() async {
    await safeOperation(() async {
      // 1. Učitavanje permisija
      await _loadPermissions();

      // 2. Validacija konfiguracije
      await _validateConfiguration();

      // 3. Inicijalizacija cache-a
      await _initializeCache();

      // 4. Priprema backup-a
      await _prepareBackup();
    });
  }

  Future<bool> hasPermission(
      String userId, SystemRole role, Permission permission) async {
    return await safeOperation(() async {
      // 1. Provera cache-a
      final cached =
          await _permissionCache.getPermission(userId, role, permission);

      if (cached != null) return cached;

      // 2. Provera osnovnih permisija
      final hasDirectPermission =
          await _checkDirectPermission(userId, role, permission);

      if (hasDirectPermission) {
        await _permissionCache.cachePermission(userId, role, permission, true);
        return true;
      }

      // 3. Provera nasleđenih permisija
      final hasInheritedPermission =
          await _checkInheritedPermissions(userId, role, permission);

      await _permissionCache.cachePermission(
          userId, role, permission, hasInheritedPermission);

      return hasInheritedPermission;
    });
  }

  Future<void> grantPermission(
      String userId, SystemRole role, Permission permission,
      {Duration? expiration}) async {
    await safeOperation(() async {
      // 1. Validacija
      if (!await _validator.validatePermissionGrant(userId, role, permission)) {
        throw SecurityException('Nevažeća dodela permisije');
      }

      // 2. Provera konflikta
      final conflicts =
          await _conflictResolver.checkConflicts(userId, role, permission);

      if (conflicts.hasConflicts) {
        await _handlePermissionConflicts(conflicts);
      }

      // 3. Dodela permisije
      await _permissionRegistry.addPermission(userId, role, permission,
          expiration: expiration);

      // 4. Ažuriranje cache-a
      await _permissionCache.invalidateUserCache(userId);

      // 5. Audit log
      await _auditor.logPermissionGrant(userId, role, permission);

      // 6. Backup
      await _backup.backupPermissions();
    });
  }

  Future<void> revokePermission(
      String userId, SystemRole role, Permission permission) async {
    await safeOperation(() async {
      // 1. Validacija
      if (!await _validator.validatePermissionRevoke(
          userId, role, permission)) {
        throw SecurityException('Nevažeće oduzimanje permisije');
      }

      // 2. Oduzimanje permisije
      await _permissionRegistry.removePermission(userId, role, permission);

      // 3. Ažuriranje cache-a
      await _permissionCache.invalidateUserCache(userId);

      // 4. Audit log
      await _auditor.logPermissionRevoke(userId, role, permission);

      // 5. Backup
      await _backup.backupPermissions();
    });
  }

  Future<Set<Permission>> getUserPermissions(
      String userId, SystemRole role) async {
    return await safeOperation(() async {
      // 1. Provera cache-a
      final cached = await _permissionCache.getUserPermissions(userId, role);
      if (cached != null) return cached;

      // 2. Dobavljanje direktnih permisija
      final directPermissions =
          await _permissionRegistry.getDirectPermissions(userId, role);

      // 3. Dobavljanje nasleđenih permisija
      final inheritedPermissions = await _getInheritedPermissions(userId, role);

      // 4. Kombinovanje permisija
      final allPermissions = {...directPermissions, ...inheritedPermissions};

      // 5. Cache-iranje rezultata
      await _permissionCache.cacheUserPermissions(userId, role, allPermissions);

      return allPermissions;
    });
  }

  Stream<PermissionChangeEvent> monitorPermissionChanges() async* {
    await for (final event in _permissionRegistry.changes) {
      // 1. Validacija promene
      if (!await _validator.validatePermissionChange(event)) {
        continue;
      }

      // 2. Ažuriranje cache-a
      await _permissionCache.handlePermissionChange(event);

      // 3. Audit log
      await _auditor.logPermissionChange(event);

      yield event;
    }
  }

  Future<PermissionStatus> checkPermissionStatus(
      String userId, SystemRole role, Permission permission) async {
    return await safeOperation(() async {
      final status = PermissionStatus(
          hasPermission: await hasPermission(userId, role, permission),
          directlyGranted:
              await _checkDirectPermission(userId, role, permission),
          inherited: await _checkInheritedPermissions(userId, role, permission),
          expiration: await _permissionRegistry.getPermissionExpiration(
              userId, role, permission),
          lastModified: await _permissionRegistry.getLastModified(
              userId, role, permission));

      return status;
    });
  }
}

class PermissionStatus {
  final bool hasPermission;
  final bool directlyGranted;
  final bool inherited;
  final DateTime? expiration;
  final DateTime? lastModified;
  final DateTime timestamp;

  bool get isValid =>
      hasPermission &&
      (expiration == null || expiration!.isAfter(DateTime.now()));

  PermissionStatus(
      {required this.hasPermission,
      required this.directlyGranted,
      required this.inherited,
      this.expiration,
      this.lastModified,
      DateTime? timestamp})
      : this.timestamp = timestamp ?? DateTime.now();
}

class PermissionChangeEvent {
  final String userId;
  final SystemRole role;
  final Permission permission;
  final PermissionChangeType type;
  final DateTime timestamp;

  PermissionChangeEvent(
      {required this.userId,
      required this.role,
      required this.permission,
      required this.type,
      DateTime? timestamp})
      : this.timestamp = timestamp ?? DateTime.now();
}

enum PermissionChangeType { granted, revoked, modified, expired }
