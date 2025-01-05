class TestServiceLocator extends ServiceLocator {
  TestServiceLocator() : super._();

  Future<void> initializeWithMocks({
    required IMeshService meshService,
    required IStorageService storageService,
    required IDatabaseService databaseService,
    required ILoggerService loggerService,
  }) async {
    if (isInitialized) return;

    // Register services with provided mocks
    _getIt.registerSingleton<ILoggerService>(loggerService);
    _getIt.registerSingleton<IDatabaseService>(databaseService);
    _getIt.registerSingleton<IMeshService>(meshService);
    _getIt.registerSingleton<IStorageService>(storageService);
    _getIt.registerSingleton<ISyncService>(
      SyncService(meshService, storageService),
    );

    // Initialize all services
    await get<IDatabaseService>().initialize();
    await get<IMeshService>().initialize();
    await get<IStorageService>().initialize();
    await get<ISyncService>().initialize();

    _isInitialized = true;
  }
}
