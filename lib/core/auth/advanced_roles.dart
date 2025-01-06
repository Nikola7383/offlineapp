enum AdvancedRole {
  secretMaster, // Najviši nivo - potpuna kontrola
  masterAdmin, // Master administrator
  herald, // Glasnik
  seed, // Seed node
  regular, // Običan korisnik
  guest, // Gost
}

class AdvancedPermissions {
  static const Map<AdvancedRole, SecurityLevel> securityLevels = {
    AdvancedRole.secretMaster: SecurityLevel(
      level: 100,
      canManageSecrets: true,
      canManageMasters: true,
      canWipeSystem: true,
      canOverrideProtocols: true,
    ),
    AdvancedRole.masterAdmin: SecurityLevel(
      level: 90,
      canManageSecrets: false,
      canManageMasters: true,
      canWipeSystem: true,
      canOverrideProtocols: false,
    ),
    AdvancedRole.herald: SecurityLevel(
      level: 80,
      canManageSecrets: false,
      canManageMasters: false,
      canWipeSystem: false,
      canOverrideProtocols: true,
    ),
    AdvancedRole.seed: SecurityLevel(
      level: 70,
      canManageSecrets: false,
      canManageMasters: false,
      canWipeSystem: false,
      canOverrideProtocols: false,
    )
  };

  static bool canAuthorize(AdvancedRole authorizer, AdvancedRole target) {
    final authorizerLevel = securityLevels[authorizer]?.level ?? 0;
    final targetLevel = securityLevels[target]?.level ?? 0;
    return authorizerLevel > targetLevel;
  }
}

class SecurityLevel {
  final int level;
  final bool canManageSecrets;
  final bool canManageMasters;
  final bool canWipeSystem;
  final bool canOverrideProtocols;

  const SecurityLevel({
    required this.level,
    required this.canManageSecrets,
    required this.canManageMasters,
    required this.canWipeSystem,
    required this.canOverrideProtocols,
  });
}
