// Centralizovane konstante i konfiguracija
class AppConfig {
  // Mesh Network Config
  static const int meshTimeout = 30000; // 30 seconds
  static const int maxRetries = 3;
  static const int maxConnections = 50;
  static const int messageRateLimit = 20; // messages per minute
  static const double meshRange = 15.0; // meters

  // Security Config
  static const int keyLength = 256;
  static const int ivLength = 16;
  static const int saltLength = 32;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = [
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'doc',
    'docx'
  ];

  // Storage Config
  static const int defaultMessageRetention = 30; // days
  static const int maxStorageSize = 500 * 1024 * 1024; // 500MB
  static const int messageBatchSize = 50;

  // Performance Config
  static const int lazyLoadThreshold = 100;
  static const double maxMemoryUsage = 100 * 1024 * 1024; // 100MB
  static const int imageCompressionQuality = 80;

  // Rate Limiting
  static const Map<String, int> rateLimits = {
    'message': 20, // per minute
    'file': 5, // per minute
    'connection': 10 // per minute
  };
}
