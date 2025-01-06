class NotificationService {
  final LoggerService _logger;

  NotificationService({
    required LoggerService logger,
  }) : _logger = logger;

  Future<void> sendToUser({
    required String userId,
    required String title,
    required String message,
    required Priority priority,
  }) async {
    try {
      // Implementation
      _logger.info('Notification sent', {
        'userId': userId,
        'title': title,
        'priority': priority,
      });
    } catch (e) {
      _logger.error('Failed to send notification', {'error': e});
      rethrow;
    }
  }
}
