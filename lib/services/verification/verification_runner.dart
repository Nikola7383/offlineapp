class VerificationRunner {
  final CriticalFixVerification _verification;
  final LoggerService _logger;
  final NotificationService _notifications;

  VerificationRunner({
    required CriticalFixVerification verification,
    required LoggerService logger,
    required NotificationService notifications,
  }) : _verification = verification,
       _logger = logger,
       _notifications = notifications;

  Future<void> runVerification() async {
    try {
      _logger.info('Starting verification of all critical fixes...');

      final result = await _verification.verifyAllFixes();
      
      if (result.isSuccess) {
        _logger.info('All critical fixes verified successfully!');
        await _logSuccessMetrics(result);
      } else {
        _logger.error('Verification failed: ${result.error}');
        await _handleFailedVerification(result);
      }

      // Detaljni izveštaj o stanju sistema
      await _generateDetailedReport(result);

    } catch (e) {
      _logger.error('Verification runner failed: $e');
      await _notifications.sendUrgentAlert(
        'Verification Runner Failed',
        e.toString()
      );
    }
  }

  Future<void> _logSuccessMetrics(VerificationResult result) async {
    _logger.info('=== Verification Success Metrics ===');
    
    // 1. Message Delivery Metrics
    if (result.messageMetrics != null) {
      _logger.info('Message Delivery Status:');
      _logger.info('- Failed Messages: ${result.messageMetrics!['failed_messages']}');
      _logger.info('- Security Status: ${result.messageMetrics!['security_status']}');
      _logger.info('- Performance: ${result.messageMetrics!['delivery_performance']}');
    }

    // 2. Database Metrics
    if (result.dbMetrics != null) {
      _logger.info('Database Status:');
      _logger.info('- Active Connections: ${result.dbMetrics!['active_connections']}');
      _logger.info('- Connection Leaks: ${result.dbMetrics!['connection_leaks']}');
      _logger.info('- Data Integrity: ${result.dbMetrics!['data_integrity']}');
    }

    // 3. Memory Metrics
    if (result.memoryMetrics != null) {
      _logger.info('Memory Status:');
      _logger.info('- Current Usage: ${result.memoryMetrics!['memory_usage']}');
      _logger.info('- Memory Leaks: ${result.memoryMetrics!['memory_leaks']}');
      _logger.info('- Security Check: ${result.memoryMetrics!['memory_security']}');
    }
  }

  Future<void> _handleFailedVerification(VerificationResult result) async {
    _logger.error('=== Failed Verification Details ===');
    
    if (result.messageMetrics != null && result.messageMetrics!['failed_messages'] > 0) {
      await _handleMessageFailures(result.messageMetrics!);
    }
    
    if (result.dbMetrics != null && result.dbMetrics!['connection_leaks'] > 0) {
      await _handleDatabaseIssues(result.dbMetrics!);
    }
    
    if (result.memoryMetrics != null && result.memoryMetrics!['memory_leaks'] > 0) {
      await _handleMemoryIssues(result.memoryMetrics!);
    }

    // Notify about failures
    await _notifications.sendFailureReport(result);
  }

  Future<void> _generateDetailedReport(VerificationResult result) async {
    final report = SystemHealthReport(
      timestamp: DateTime.now(),
      verificationResult: result,
      systemMetrics: await _collectSystemMetrics(),
      recommendations: _generateRecommendations(result),
    );

    await report.save();
    
    if (report.hasCriticalIssues) {
      await _notifications.sendCriticalReport(report);
    }
  }
} 