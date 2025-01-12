import '../interfaces/logger_service_interface.dart';
import 'security_types.dart';

/// Monitor za praćenje performansi security modula
class SecurityPerformanceMonitor {
  final ILoggerService _logger;
  final List<PerformanceAlert> _alerts = [];
  bool _isInitialized = false;

  SecurityPerformanceMonitor(this._logger);

  /// Da li je monitor inicijalizovan
  bool get isInitialized => _isInitialized;

  /// Inicijalizuje monitor
  Future<void> initialize() async {
    _isInitialized = true;
    _logger.info('Security performance monitor initialized');
  }

  /// Oslobađa resurse
  Future<void> dispose() async {
    _alerts.clear();
    _isInitialized = false;
    _logger.info('Security performance monitor disposed');
  }

  /// Dodaje alert
  void addAlert(PerformanceAlert alert) {
    _alerts.add(alert);
    _logger.warning('Performance alert: ${alert.message} [${alert.severity}]');
  }

  /// Vraća sve alerte
  List<PerformanceAlert> getAlerts() {
    return List.unmodifiable(_alerts);
  }

  /// Vraća alerte po severity-u
  List<PerformanceAlert> getAlertsBySeverity(AlertSeverity severity) {
    return _alerts.where((alert) => alert.severity == severity).toList();
  }

  /// Briše sve alerte
  void clearAlerts() {
    _alerts.clear();
    _logger.info('Cleared all performance alerts');
  }

  /// Vraća broj alertova
  int get alertCount => _alerts.length;
}
