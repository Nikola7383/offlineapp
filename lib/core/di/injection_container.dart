@InjectableInit(
  initializerName: 'initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() async {
  final getIt = GetIt.instance;

  // Registrujemo module
  $initGetIt(getIt);

  // Inicijalizacija servisa
  await Future.wait([
    getIt<LoggerService>().initialize(),
    getIt<DatabaseService>().initialize(),
    getIt<CacheManager>().initialize(),
    getIt<MeshNetwork>().initialize(),
    getIt<EncryptionService>().initialize(),
    getIt<SessionService>().initialize(),
    getIt<KeyRotationManager>().initialize(),
  ]);

  // Validacija zavisnosti
  await DependencyValidator.validateDependencies();
}

class DependencyException implements Exception {
  final String message;
  DependencyException(this.message);

  @override
  String toString() => 'DependencyException: $message';
}
