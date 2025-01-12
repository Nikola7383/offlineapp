import 'package:injectable/injectable.dart';

@injectable
class AlertSystem {
  Future<void> initialize() async {}
  Future<void> dispose() async {}

  Future<void> sendAlert(String message, AlertPriority priority) async {
    // TODO: Implementirati slanje upozorenja
    throw UnimplementedError();
  }

  Future<void> clearAlert(String alertId) async {
    // TODO: Implementirati brisanje upozorenja
    throw UnimplementedError();
  }

  Future<List<Alert>> getActiveAlerts() async {
    // TODO: Implementirati dobavljanje aktivnih upozorenja
    throw UnimplementedError();
  }

  Future<void> acknowledgeAlert(String alertId) async {
    // TODO: Implementirati potvrdu upozorenja
    throw UnimplementedError();
  }

  Future<bool> hasActiveAlerts() async {
    // TODO: Implementirati proveru da li ima aktivnih upozorenja
    throw UnimplementedError();
  }
}

enum AlertPriority { low, medium, high, critical }

class Alert {
  final String id;
  final String message;
  final AlertPriority priority;
  final DateTime timestamp;
  final bool isAcknowledged;

  Alert({
    required this.id,
    required this.message,
    required this.priority,
    required this.timestamp,
    this.isAcknowledged = false,
  });
}
