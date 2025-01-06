enum AlertType {
  highMemory,
  queueOverload,
  slowResponse,
  securityAudit,
  systemFailure
}

class AlertService {
  final LoggerService _logger;
  final NotificationService _notifications;

  AlertService({
    required LoggerService logger,
    required NotificationService notifications,
  })  : _logger = logger,
        _notifications = notifications;

  Future<void> sendAlert(AlertType type, String message) async {
    try {
      await _logger.alert(message, {'type': type});

      // Slanje notifikacija relevantnim korisnicima
      final users = await _getUsersForAlertType(type);
      for (final user in users) {
        await _notifications.sendToUser(
          userId: user.id,
          title: 'System Alert',
          message: message,
          priority: _getPriorityForAlertType(type),
        );
      }
    } catch (e) {
      _logger.error('Failed to send alert', {'error': e, 'type': type});
    }
  }

  Priority _getPriorityForAlertType(AlertType type) {
    switch (type) {
      case AlertType.systemFailure:
        return Priority.critical;
      case AlertType.securityAudit:
        return Priority.high;
      default:
        return Priority.medium;
    }
  }

  Future<List<User>> _getUsersForAlertType(AlertType type) async {
    // Implementacija logike ko treba da primi koji tip alerta
    return [];
  }
}
