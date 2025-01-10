class NetworkTimeoutFix {
  final ResilientNetworkService _network;
  final LoggerService _logger;

  // Timeout konfiguracija
  static const Duration DEFAULT_TIMEOUT = Duration(seconds: 30);
  static const Duration EXTENDED_TIMEOUT = Duration(seconds: 60);
  static const int MAX_RETRIES = 3;

  // Tracking timeouts
  final Map<String, TimeoutMetrics> _timeoutMetrics = {};

  NetworkTimeoutFix({
    required ResilientNetworkService network,
    required LoggerService logger,
  })  : _network = network,
        _logger = logger;

  Future<void> fixTimeoutIssues() async {
    try {
      _logger.info('Starting network timeout fix...');

      // 1. Identify timeout patterns
      final patterns = await _analyzeTimeoutPatterns();

      // 2. Adjust timeout settings
      await _adjustTimeoutSettings(patterns);

      // 3. Retry failed operations
      await _retryFailedOperations();

      // 4. Verify improvements
      await _verifyTimeoutFixes();
    } catch (e) {
      _logger.error('Timeout fix failed: $e');
      throw FixException('Network timeout fix failed');
    }
  }

  Future<void> _retryFailedOperations() async {
    final failedOps = await _network.getFailedOperations();

    for (final op in failedOps) {
      if (op.failureReason == FailureReason.timeout) {
        await _retryWithAdjustedTimeout(op);
      }
    }
  }

  Future<void> _retryWithAdjustedTimeout(FailedOperation op) async {
    var attempt = 0;
    var timeout = DEFAULT_TIMEOUT;

    while (attempt < MAX_RETRIES) {
      try {
        await _network.executeWithTimeout(operation: op, timeout: timeout);
        return;
      } catch (e) {
        attempt++;
        timeout *= 2; // Double timeout for next attempt

        if (attempt < MAX_RETRIES) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }
  }
}
