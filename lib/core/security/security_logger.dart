import '../interfaces/logger_service_interface.dart';

/// Logger za security module
class SecurityLogger {
  final ILoggerService _logger;
  bool _isInitialized = false;

  SecurityLogger(this._logger);

  /// Da li je logger inicijalizovan
  bool get isInitialized => _isInitialized;

  /// Inicijalizuje logger
  Future<void> initialize() async {
    _isInitialized = true;
    _logger.info('Security logger initialized');
  }

  /// Oslobađa resurse
  Future<void> dispose() async {
    _isInitialized = false;
    _logger.info('Security logger disposed');
  }

  /// Loguje informaciju
  void info(String message) {
    _logger.info('[SECURITY] $message');
  }

  /// Loguje upozorenje
  void warning(String message) {
    _logger.warning('[SECURITY] $message');
  }

  /// Loguje grešku
  void error(String message) {
    _logger.error('[SECURITY] $message');
  }

  /// Loguje kritičnu grešku
  void critical(String message) {
    _logger.critical('[SECURITY] $message');
  }

  /// Vraća sve logove
  Future<List<String>> getLogs() async {
    return _logger.getLogs();
  }

  /// Briše sve logove
  Future<void> clearLogs() async {
    await _logger.clearLogs();
  }
}
