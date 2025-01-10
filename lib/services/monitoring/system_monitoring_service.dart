class SystemMonitoringService {
  final MetricsCollector _metrics;
  final AlertSystem _alerts;
  final LoggerService _logger;
  
  // Monitoring intervals
  static const Duration METRICS_INTERVAL = Duration(seconds: 30);
  static const Duration ALERT_CHECK_INTERVAL = Duration(minutes: 1);

  SystemMonitoringService({
    required MetricsCollector metrics,
    required AlertSystem alerts,
    required LoggerService logger,
  }) : _metrics = metrics,
       _alerts = alerts,
       _logger = logger;

  Future<void> initializeMonitoring() async {
    try {
      // 1. Start metrics collection
      await _startMetricsCollection();
      
      // 2. Configure alert system
      await _configureAlerts();
      
      // 3. Setup automated responses
      await _setupAutomatedResponses();
      
    } catch (e) {
      _logger.error('Monitoring initialization failed: $e');
      throw MonitoringException('Failed to initialize monitoring');
    }
  }

  Future<void> _startMetricsCollection() async {
    await _metrics.startCollecting(
      interval: METRICS_INTERVAL,
      metrics: [
        MetricType.security,
        MetricType.performance,
        MetricType.stability,
        MetricType.resources
      ],
      onMetricsCollected: (metrics) async {
        await _processMetrics(metrics);
      }
    );
  }

  Future<void> _configureAlerts() async {
    await _alerts.configure(
      conditions: [
        AlertCondition(
          type: AlertType.security,
          threshold: 90,
          priority: AlertPriority.critical
        ),
        AlertCondition(
          type: AlertType.performance,
          threshold: 85,
          priority: AlertPriority.high
        ),
        AlertCondition(
          type: AlertType.stability,
          threshold: 95,
          priority: AlertPriority.medium
        )
      ],
      onAlert: (alert) async {
        await _handleAlert(alert);
      }
    );
  }
} 