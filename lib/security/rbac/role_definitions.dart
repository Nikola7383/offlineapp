enum SystemRole {
  superAdmin, // Najviši nivo pristupa
  admin, // Administrativni pristup
  moderator, // Moderatorski pristup
  operator, // Operativni pristup
  user, // Standardni korisnički pristup
  guest, // Ograničeni pristup
  system, // Sistemske operacije
  emergency, // Emergency pristup
  audit, // Audit pristup
  readonly // Read-only pristup
}

enum Permission {
  // Sistemske dozvole
  manageSystem,
  configureSystem,
  monitorSystem,

  // Security dozvole
  manageSecuritySettings,
  viewSecurityLogs,
  manageEncryption,

  // User management
  manageUsers,
  createUser,
  deleteUser,
  modifyUser,

  // Role management
  manageRoles,
  assignRoles,
  viewRoles,

  // Emergency operacije
  triggerEmergency,
  manageEmergency,
  viewEmergencyStatus,

  // Audit
  performAudit,
  viewAuditLogs,
  exportAuditData,

  // Data management
  readData,
  writeData,
  deleteData,
  modifyData,

  // Communication
  sendMessages,
  receiveMessages,
  manageChannels,

  // Backup
  createBackup,
  restoreBackup,
  manageBackups
}

class RoleDefinition {
  final SystemRole role;
  final Set<Permission> permissions;
  final Set<SystemRole> inheritedRoles;
  final RoleMetadata metadata;

  const RoleDefinition(
      {required this.role,
      required this.permissions,
      this.inheritedRoles = const {},
      required this.metadata});
}

class RoleMetadata {
  final String description;
  final RoleLevel level;
  final bool isSystem;
  final bool requiresMFA;
  final Set<String> restrictions;
  final DateTime created;
  final DateTime? lastModified;

  const RoleMetadata(
      {required this.description,
      required this.level,
      this.isSystem = false,
      this.requiresMFA = false,
      this.restrictions = const {},
      required this.created,
      this.lastModified});
}

enum RoleLevel {
  system, // Nivo 0 - Sistemski
  critical, // Nivo 1 - Kritični
  high, // Nivo 2 - Visoki
  medium, // Nivo 3 - Srednji
  low, // Nivo 4 - Niski
  minimal // Nivo 5 - Minimalni
}

// Predefinisane role definicije
class PredefinedRoles {
  static final superAdmin = RoleDefinition(
      role: SystemRole.superAdmin,
      permissions: {
        Permission.manageSystem,
        Permission.configureSystem,
        Permission.monitorSystem,
        Permission.manageSecuritySettings,
        Permission.viewSecurityLogs,
        Permission.manageEncryption,
        Permission.manageUsers,
        Permission.manageRoles,
        Permission.triggerEmergency,
        Permission.manageEmergency,
        Permission.performAudit,
        // ... sve ostale dozvole
      },
      metadata: RoleMetadata(
          description: 'Potpuni sistemski pristup',
          level: RoleLevel.system,
          isSystem: true,
          requiresMFA: true,
          created: DateTime.now()));

  static final admin = RoleDefinition(
      role: SystemRole.admin,
      permissions: {
        Permission.configureSystem,
        Permission.monitorSystem,
        Permission.manageUsers,
        Permission.manageRoles,
        Permission.viewSecurityLogs,
        // ... administrativne dozvole
      },
      metadata: RoleMetadata(
          description: 'Administrativni pristup',
          level: RoleLevel.critical,
          requiresMFA: true,
          created: DateTime.now()));

  // ... ostale predefinisane role
}
