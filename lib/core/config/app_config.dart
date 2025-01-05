class AppConfig {
  // Network settings
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const Duration connectionTimeout = Duration(seconds: 5);

  // Batch processing
  static const int messageBatchSize = 50;
  static const Duration batchProcessInterval = Duration(seconds: 2);

  // Rate limiting
  static const Map<String, int> rateLimits = {
    'message': 20, // per minute
    'file': 5, // per minute
    'connection': 10 // per minute
  };

  // Database
  static const int maxDatabaseConnections = 5;
  static const Duration databaseTimeout = Duration(seconds: 10);

  // Logging
  static const bool enableDebugLogs = true;
  static const String logPrefix = 'SecureEventApp';

  // Feature flags
  static const bool enableOfflineMode = true;
  static const bool enableEncryption = true;
  static const bool enableCompression = true;
}
