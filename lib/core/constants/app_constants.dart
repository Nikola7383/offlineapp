class AppConstants {
  // Security
  static const int KEY_LENGTH = 32;
  static const int MAX_RETRY_ATTEMPTS = 3;
  static const Duration KEY_ROTATION_INTERVAL = Duration(hours: 24);

  // Network
  static const int MAX_NODES = 1000;
  static const int MESSAGE_QUEUE_SIZE = 10000;
  static const Duration NODE_TIMEOUT = Duration(seconds: 30);

  // Sound Protocol
  static const int MIN_FREQUENCY = 18000; // 18kHz
  static const int MAX_FREQUENCY = 22000; // 22kHz

  // Storage
  static const int MAX_STORAGE_SIZE = 1024 * 1024 * 1024; // 1GB

  // Monitoring
  static const Duration HEALTH_CHECK_INTERVAL = Duration(seconds: 30);
  static const Duration METRICS_COLLECTION_INTERVAL = Duration(minutes: 1);
  static const Duration AUDIT_INTERVAL = Duration(minutes: 5);
}
