class EmergencySystemConfiguration {
  // Security Configuration
  static const SecurityConfig security = SecurityConfig(
      // Encryption
      encryptionKeySize: 4096, // Maksimalna dužina ključa
      keyRotationInterval: Duration(hours: 1), // Često rotiranje ključeva
      saltLength: 32, // Duži salt za dodatnu sigurnost

      // Authentication
      maxAuthAttempts: 3, // Ograničen broj pokušaja
      lockoutDuration: Duration(minutes: 30),
      sessionTimeout: Duration(minutes: 15),

      // Validation
      strictInputValidation: true,
      validateChecksums: true,
      enforceSignatures: true,

      // Protection
      enableIntrustionDetection: true,
      blockSuspiciousActivity: true,
      enforceRateLimiting: true);

  // Offline Configuration
  static const OfflineConfig offline = OfflineConfig(
      // Storage
      maxStorageSize: 1024 * 1024 * 1024, // 1GB max storage
      autoCleanupThreshold: 0.9, // Čisti kad je 90% puno
      retentionPeriod: Duration(days: 30),

      // Sync
      syncInterval: Duration(minutes: 5),
      maxSyncAttempts: 3,
      syncTimeout: Duration(minutes: 1),

      // Cache
      maxCacheSize: 100 * 1024 * 1024, // 100MB cache
      cacheExpiryTime: Duration(hours: 24),
      prioritizeCriticalData: true);

  // Resource Configuration
  static const ResourceConfig resources = ResourceConfig(
      // Memory
      maxMemoryUsage: 512 * 1024 * 1024, // 512MB max
      memoryThreshold: 0.8, // Upozorenje na 80%
      enableMemoryOptimization: true,

      // CPU
      maxCpuUsage: 0.7, // Max 70% CPU
      backgroundTaskPriority: Priority.low,
      enableLoadBalancing: true,

      // Battery
      minBatteryLevel: 0.2, // Min 20% baterije
      enablePowerSaving: true,
      criticalBatteryAction: BatteryAction.saveAndShutdown);

  // Recovery Configuration
  static const RecoveryConfig recovery = RecoveryConfig(
      // Backup
      backupInterval: Duration(hours: 1),
      keepBackupVersions: 5,
      encryptBackups: true,

      // Restore
      autoRestoreEnabled: true,
      maxRestoreAttempts: 3,
      restoreTimeout: Duration(minutes: 5),

      // Failsafe
      enableFailsafe: true,
      failsafeTimeout: Duration(minutes: 1),
      preserveCriticalData: true);

  // System Limits
  static const SystemLimits limits = SystemLimits(
      // Messages
      maxMessageSize: 1024 * 1024, // 1MB po poruci
      maxMessagesPerMinute: 60,
      maxPendingMessages: 1000,

      // Connections
      maxConnections: 100,
      connectionTimeout: Duration(seconds: 30),
      maxReconnectAttempts: 5,

      // Operations
      maxConcurrentOperations: 10,
      operationTimeout: Duration(seconds: 30),
      maxQueueSize: 1000);

  // Monitoring Configuration
  static const MonitoringConfig monitoring = MonitoringConfig(
      // Health Checks
      healthCheckInterval: Duration(seconds: 30),
      criticalHealthMetrics: true,
      detailedHealthLogs: true,

      // Performance
      performanceMonitoring: true,
      metricsSamplingRate: Duration(seconds: 1),
      keepMetricsHistory: Duration(hours: 24),

      // Alerts
      enableAlerts: true,
      alertPriority: Priority.high,
      alertRetentionPeriod: Duration(days: 7));

  // Validation Rules
  static const ValidationRules validation = ValidationRules(
      // Input
      requireMessageSignature: true,
      validateMessageFormat: true,
      checkMessageIntegrity: true,

      // State
      validateStateTransitions: true,
      enforceStateConstraints: true,
      checkStatePreconditions: true,

      // Security
      validateSecurityTokens: true,
      checkPermissions: true,
      validateOperations: true);

  // Emergency Protocols
  static const EmergencyProtocols emergency = EmergencyProtocols(
      // Triggers
      lowStorageThreshold: 0.1, // 10% storage
      criticalBatteryThreshold: 0.1, // 10% battery
      highLoadThreshold: 0.9, // 90% load

      // Actions
      enableEmergencyMode: true,
      preserveEssentialFunctions: true,
      notifyAdministrators: true,

      // Recovery
      autoRecoveryEnabled: true,
      maxRecoveryTime: Duration(minutes: 5),
      requireManualOverride: false);
}

// Supporting Classes
class SecurityConfig {
  final int encryptionKeySize;
  final Duration keyRotationInterval;
  final int saltLength;
  final int maxAuthAttempts;
  final Duration lockoutDuration;
  final Duration sessionTimeout;
  final bool strictInputValidation;
  final bool validateChecksums;
  final bool enforceSignatures;
  final bool enableIntrustionDetection;
  final bool blockSuspiciousActivity;
  final bool enforceRateLimiting;

  const SecurityConfig(
      {required this.encryptionKeySize,
      required this.keyRotationInterval,
      required this.saltLength,
      required this.maxAuthAttempts,
      required this.lockoutDuration,
      required this.sessionTimeout,
      required this.strictInputValidation,
      required this.validateChecksums,
      required this.enforceSignatures,
      required this.enableIntrustionDetection,
      required this.blockSuspiciousActivity,
      required this.enforceRateLimiting});
}

// ... (ostale pomoćne klase sa istom strukturom) 