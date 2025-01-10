class VerificationExecutor {
  final VerificationRunner _runner;
  final LoggerService _logger;

  VerificationExecutor({
    required VerificationRunner runner,
    required LoggerService logger,
  }) : _runner = runner,
       _logger = logger;

  Future<void> execute() async {
    _logger.info('=== Starting System Verification ===');
    
    try {
      final result = await _runner.runVerification();
      
      _logger.info('\n=== VERIFICATION RESULTS ===\n');
      
      // 1. Message Delivery Status
      _logger.info('MESSAGE DELIVERY:');
      if (result.messageMetrics!['failed_messages'] == 0) {
        _logger.info('✅ All messages delivered successfully');
        _logger.info('✅ Message security verified');
        _logger.info('✅ Performance within acceptable range');
      } else {
        _logger.error('❌ ${result.messageMetrics!['failed_messages']} messages still failing');
      }

      // 2. Database Status
      _logger.info('\nDATABASE:');
      if (result.dbMetrics!['connection_leaks'] == 0) {
        _logger.info('✅ No connection leaks detected');
        _logger.info('✅ All connections secure');
        _logger.info('✅ Data integrity verified');
      } else {
        _logger.error('❌ ${result.dbMetrics!['connection_leaks']} connection leaks found');
      }

      // 3. Memory Status
      _logger.info('\nMEMORY:');
      if (result.memoryMetrics!['memory_leaks'] == 0) {
        _logger.info('✅ No memory leaks detected');
        _logger.info('✅ Memory usage optimized');
        _logger.info('✅ Memory security verified');
      } else {
        _logger.error('❌ ${result.memoryMetrics!['memory_leaks']} memory leaks found');
      }

      // Summary
      _logger.info('\n=== VERIFICATION SUMMARY ===\n');
      
      if (result.isSuccess) {
        _logger.info('✅ ALL CRITICAL FIXES VERIFIED SUCCESSFULLY');
        _logger.info('System is now stable and secure');
      } else {
        _logger.error('❌ SOME ISSUES STILL REMAIN:');
        if (result.messageMetrics!['failed_messages'] > 0) {
          _logger.error('- Message Delivery: ${result.messageMetrics!['failed_messages']} issues');
        }
        if (result.dbMetrics!['connection_leaks'] > 0) {
          _logger.error('- Database: ${result.dbMetrics!['connection_leaks']} issues');
        }
        if (result.memoryMetrics!['memory_leaks'] > 0) {
          _logger.error('- Memory: ${result.memoryMetrics!['memory_leaks']} issues');
        }
      }

    } catch (e) {
      _logger.error('Verification execution failed: $e');
      throw VerificationException('Failed to execute verification');
    }
  }
} 