@module
abstract class ServiceModule {
  @singleton
  LoggerService get logger => LoggerService();

  @singleton
  DatabaseService get database => DatabaseService();

  @singleton
  CacheManager get cache => CacheManager();

  @singleton
  MeshNetwork get meshNetwork => MeshNetwork();

  @singleton
  EncryptionService get encryption => EncryptionService();

  // Testing Utils
  @singleton
  SystemMetrics get systemMetrics => SystemMetrics();

  @singleton
  CacheMetrics get cacheMetrics => CacheMetrics();

  @singleton
  NetworkMetrics get networkMetrics => NetworkMetrics();

  // Performance
  @singleton
  PerformanceOptimizer get performanceOptimizer => PerformanceOptimizer();

  @singleton
  QueryOptimizer get queryOptimizer => QueryOptimizer();

  // Security
  @singleton
  SessionService get sessionService => SessionService();

  @singleton
  KeyRotationManager get keyRotation => KeyRotationManager();

  // Testing
  @singleton
  TestFramework get testFramework => TestFramework();

  @singleton
  TestReporter get testReporter => TestReporter();
}
