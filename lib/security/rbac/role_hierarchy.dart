class RoleHierarchy {
  final Map<SystemRole, Set<SystemRole>> _hierarchy;
  final Map<SystemRole, int> _levels;

  RoleHierarchy()
      : _hierarchy = {},
        _levels = {} {
    _initializeHierarchy();
  }

  void _initializeHierarchy() {
    // Definisanje hijerarhije
    _hierarchy[SystemRole.superAdmin] = {
      SystemRole.admin,
      SystemRole.emergency,
      SystemRole.audit
    };

    _hierarchy[SystemRole.admin] = {SystemRole.moderator, SystemRole.operator};

    _hierarchy[SystemRole.moderator] = {SystemRole.user};

    _hierarchy[SystemRole.user] = {SystemRole.guest};

    // Definisanje nivoa
    _levels[SystemRole.superAdmin] = 0;
    _levels[SystemRole.admin] = 1;
    _levels[SystemRole.moderator] = 2;
    _levels[SystemRole.operator] = 2;
    _levels[SystemRole.user] = 3;
    _levels[SystemRole.guest] = 4;
    _levels[SystemRole.readonly] = 5;
  }

  bool hasAccess(SystemRole role, SystemRole requiredRole) {
    if (role == requiredRole) return true;

    final subordinates = getAllSubordinateRoles(role);
    return subordinates.contains(requiredRole);
  }

  Set<SystemRole> getAllSubordinateRoles(SystemRole role) {
    final result = <SystemRole>{};
    final toProcess = <SystemRole>{role};

    while (toProcess.isNotEmpty) {
      final current = toProcess.first;
      toProcess.remove(current);

      final subordinates = _hierarchy[current] ?? {};
      for (final subordinate in subordinates) {
        if (result.add(subordinate)) {
          toProcess.add(subordinate);
        }
      }
    }

    return result;
  }

  bool isHigherLevel(SystemRole role1, SystemRole role2) {
    final level1 = _levels[role1] ?? -1;
    final level2 = _levels[role2] ?? -1;
    return level1 < level2; // Niži broj = viši nivo
  }

  List<SystemRole> getDirectSubordinates(SystemRole role) {
    return (_hierarchy[role] ?? {}).toList();
  }

  SystemRole? getDirectSuperior(SystemRole role) {
    for (final entry in _hierarchy.entries) {
      if (entry.value.contains(role)) {
        return entry.key;
      }
    }
    return null;
  }
}
