class DependencyValidator {
  static void validateDependencies() {
    final dependencies = <String, Set<String>>{};

    // Gradimo graf zavisnosti
    ServiceLocator.instance.allReady().forEach((service) {
      dependencies[service.runtimeType.toString()] = _getDependencies(service);
    });

    // Proveravamo cikluse
    final cycles = _findCycles(dependencies);
    if (cycles.isNotEmpty) {
      throw DependencyError('Detektovani ciklusi: $cycles');
    }
  }

  static Set<String> _getDependencies(dynamic service) {
    final mirror = reflect(service);
    return mirror.type.declarations.values
        .whereType<VariableMirror>()
        .where((v) => v.isPrivate)
        .map((v) => v.type.reflectedType.toString())
        .toSet();
  }
}
