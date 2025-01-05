class DependencyValidator {
  static void validateDependencies(SecurityDependencyContainer container) {
    final dependencies = <String, Set<String>>{};

    // Mapiranje zavisnosti
    dependencies['SecurityController'] = {
      'EncryptionManager',
      'AuditManager',
      'SecurityVault'
    };

    dependencies['EncryptionManager'] = {'SecurityVault', 'AuditManager'};

    dependencies['AuditManager'] = {'SecurityVault', 'EventCoordinator'};

    // Provera cirkularnih zavisnosti
    for (var component in dependencies.keys) {
      _checkCircularDependency(component, dependencies, Set());
    }
  }

  static void _checkCircularDependency(String component,
      Map<String, Set<String>> dependencies, Set<String> visited) {
    if (visited.contains(component)) {
      throw DependencyException(
          'Circular dependency detected: ${visited.join(' -> ')} -> $component');
    }

    visited.add(component);
    for (var dependency in dependencies[component] ?? {}) {
      _checkCircularDependency(dependency, dependencies, Set.from(visited));
    }
  }
}

class DependencyException implements Exception {
  final String message;
  DependencyException(this.message);
}
