class MessageDeliveryFix {
  final ResilientNetworkService _network;
  final OptimizedMessageQueue _queue;
  final LoggerService _logger;

  // Tracking failed deliveries
  final Map<String, DeliveryAttempt> _failedDeliveries = {};

  MessageDeliveryFix({
    required ResilientNetworkService network,
    required OptimizedMessageQueue queue,
    required LoggerService logger,
  })  : _network = network,
        _queue = queue,
        _logger = logger;

  Future<void> fixDeliveryIssues() async {
    try {
      _logger.info('Starting message delivery fix...');

      // 1. Identify failed messages
      final failedMessages = await _identifyFailedMessages();

      // 2. Attempt redelivery with new system
      await _redeliverMessages(failedMessages);

      // 3. Verify fixes
      await _verifyDeliveryFixes();
    } catch (e) {
      _logger.error('Delivery fix failed: $e');
      throw FixException('Message delivery fix failed');
    }
  }

  Future<List<FailedMessage>> _identifyFailedMessages() async {
    try {
      final failedMessages = <FailedMessage>[];

      // 1. Proveri queue za failed messages
      final queueFailed = await _queue.getFailedMessages();
      failedMessages.addAll(queueFailed);

      // 2. Proveri network service za failed deliveries
      final networkFailed = await _network.getFailedDeliveries();
      failedMessages.addAll(networkFailed);

      // 3. Dedupliciraj i sortiraj po prioritetu
      return _deduplicateAndSort(failedMessages);
    } catch (e) {
      _logger.error('Failed to identify failed messages: $e');
      throw FixException('Message identification failed');
    }
  }

  Future<void> _redeliverMessages(List<FailedMessage> messages) async {
    int fixed = 0;
    int failed = 0;

    for (final message in messages) {
      try {
        // 1. Pripremi poruku za redelivery
        final preparedMessage = await _prepareForRedelivery(message);

        // 2. Pokušaj redelivery sa novim retry sistemom
        await _network.sendWithResilience(preparedMessage);

        // 3. Update tracking
        await _updateDeliveryStatus(message.id, DeliveryStatus.delivered);

        fixed++;
      } catch (e) {
        failed++;
        _logger.error('Redelivery failed for message ${message.id}: $e');
        await _handleRedeliveryFailure(message, e);
      }

      // Log progress
      _logProgress(fixed, failed, messages.length);
    }
  }

  Future<Message> _prepareForRedelivery(FailedMessage failed) async {
    // 1. Verifikuj integritet poruke
    if (!await _verifyMessageIntegrity(failed)) {
      throw FixException('Message integrity check failed');
    }

    // 2. Update metadata
    final updatedMessage = failed.message.copyWith(
      retryCount: failed.retryCount + 1,
      lastAttempt: DateTime.now(),
      priority: _calculateNewPriority(failed),
    );

    // 3. Pripremi za slanje
    return await _network.prepareForSending(updatedMessage);
  }

  Future<void> _verifyDeliveryFixes() async {
    // 1. Proveri sve redelivered poruke
    final redelivered = await _getRedeliveredMessages();

    // 2. Verifikuj status svake poruke
    final verificationResults =
        await Future.wait(redelivered.map((m) => _verifyMessageDelivery(m)));

    // 3. Analiziraj rezultate
    final success = verificationResults.every((r) => r.isSuccess);

    if (!success) {
      final failed = verificationResults.where((r) => !r.isSuccess).length;
      throw FixException('Verification failed for $failed messages');
    }
  }

  MessagePriority _calculateNewPriority(FailedMessage message) {
    // Povećaj priority za stare poruke
    if (message.age > Duration(hours: 1)) {
      return MessagePriority.high;
    }

    // Povećaj priority za poruke sa više failed attempts
    if (message.retryCount > 3) {
      return MessagePriority.high;
    }

    return message.originalPriority;
  }

  void _logProgress(int fixed, int failed, int total) {
    final progress = ((fixed + failed) / total * 100).toStringAsFixed(2);
    _logger.info('Fix progress: $progress% (Fixed: $fixed, Failed: $failed)');
  }

  Future<void> _handleRedeliveryFailure(
      FailedMessage message, dynamic error) async {
    // 1. Update failure metrics
    _failedDeliveries[message.id] = DeliveryAttempt(
      message: message,
      error: error,
      timestamp: DateTime.now(),
    );

    // 2. Odluči o sledećem koraku
    if (message.retryCount >= 5) {
      await _moveToDeadLetter(message);
    } else {
      await _scheduleRetry(message);
    }
  }
}
