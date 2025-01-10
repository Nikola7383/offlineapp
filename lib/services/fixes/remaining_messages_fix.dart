class RemainingMessagesFix {
  final MessageDeliveryService _delivery;
  final NetworkService _network;
  final LoggerService _logger;

  // Specijalni retry parametri za preostale poruke
  static const int MAX_PRIORITY_RETRIES = 5;
  static const Duration RETRY_INTERVAL = Duration(seconds: 30);

  RemainingMessagesFix({
    required MessageDeliveryService delivery,
    required NetworkService network,
    required LoggerService logger,
  })  : _delivery = delivery,
        _network = network,
        _logger = logger;

  Future<void> fixRemainingMessages() async {
    try {
      _logger.info('Počinjem fix za preostalih 42 poruke...');

      // 1. Uzmi sve preostale poruke
      final remainingMessages = await _delivery.getUndeliveredMessages();

      // 2. Grupiši po razlogu neuspeha
      final groupedMessages = _groupMessagesByFailure(remainingMessages);

      // 3. Primeni specifične fixeve za svaku grupu
      for (final group in groupedMessages.entries) {
        await _handleMessageGroup(group.key, group.value);
      }

      // 4. Verifikuj rezultate
      await _verifyDelivery(remainingMessages);
    } catch (e) {
      _logger.error('Fix za preostale poruke nije uspeo: $e');
      throw FixException('Remaining messages fix failed');
    }
  }

  Future<void> _handleMessageGroup(
      FailureReason reason, List<Message> messages) async {
    switch (reason) {
      case FailureReason.networkLatency:
        await _handleLatencyIssues(messages);
        break;
      case FailureReason.timeout:
        await _handleTimeoutIssues(messages);
        break;
      case FailureReason.routingError:
        await _handleRoutingIssues(messages);
        break;
      default:
        await _handleGenericIssues(messages);
    }
  }

  Future<void> _handleLatencyIssues(List<Message> messages) async {
    // Koristi najbržu dostupnu rutu
    final fastestRoute = await _network.getFastestRoute();

    for (final message in messages) {
      try {
        // 1. Postavi high priority
        message.setPriority(MessagePriority.critical);

        // 2. Koristi najbržu rutu
        await _delivery.sendViaRoute(message, fastestRoute);

        // 3. Prati status
        await _monitorDelivery(message);
      } catch (e) {
        _logger.error('Greška pri slanju poruke ${message.id}: $e');
        await _handleDeliveryFailure(message, e);
      }
    }
  }

  Future<void> _monitorDelivery(Message message) async {
    var attempts = 0;

    while (attempts < MAX_PRIORITY_RETRIES) {
      final status = await _delivery.checkStatus(message);

      if (status.isDelivered) {
        _logger.info('Poruka ${message.id} uspešno isporučena');
        return;
      }

      attempts++;
      if (attempts < MAX_PRIORITY_RETRIES) {
        await Future.delayed(RETRY_INTERVAL);
        await _delivery.retry(message);
      }
    }
  }

  Future<void> _verifyDelivery(List<Message> originalMessages) async {
    final remainingUndelivered = await _delivery.getUndeliveredMessages();

    if (remainingUndelivered.isEmpty) {
      _logger.info('✅ Sve poruke uspešno isporučene!');
    } else {
      _logger.warning(
          '⚠️ ${remainingUndelivered.length} poruke još uvek nisu isporučene');
      // Detaljni log za preostale probleme
      for (final msg in remainingUndelivered) {
        _logger.error('Poruka ${msg.id} nije isporučena: ${msg.lastError}');
      }
    }
  }
}
