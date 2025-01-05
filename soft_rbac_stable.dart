class SoftRBAC {
  final Map<String, Set<String>> _userRoles = {};
  final Map<String, Set<String>> _rolePermissions = {};

  void assignRole(String userId, String role) {
    _userRoles.putIfAbsent(userId, () => {}).add(role);
  }

  void grantPermission(String role, String permission) {
    _rolePermissions.putIfAbsent(role, () => {}).add(permission);
  }

  bool hasPermission(String userId, String permission) {
    final userRoles = _userRoles[userId] ?? {};
    return userRoles
        .any((role) => _rolePermissions[role]?.contains(permission) ?? false);
  }
}
