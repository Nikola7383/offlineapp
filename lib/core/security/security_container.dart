import 'package:injectable/injectable.dart';
import '../interfaces/logger_service_interface.dart';
import 'security_logger.dart';
import 'security_memory_manager.dart';
import 'security_performance_monitor.dart';

/// Container za security module koji upravlja svim security komponentama
@singleton
class SecurityContainer {
  final ILoggerService _logger;
  late final SecurityLogger _securityLogger;
  late final SecurityMemoryManager _memoryManager;
  late final SecurityPerformanceMonitor _performanceMonitor;
  bool _isInitialized = false;

  SecurityContainer(this._logger) {
    _securityLogger = SecurityLogger(_logger);
    _memoryManager = SecurityMemoryManager(_logger);
    _performanceMonitor = SecurityPerformanceMonitor(_logger);
  }

  /// Da li je container inicijalizovan
  bool get isInitialized => _isInitialized;

  /// Vraća security logger
  SecurityLogger get logger => _securityLogger;

  /// Vraća memory manager
  SecurityMemoryManager get memoryManager => _memoryManager;

  /// Vraća performance monitor
  SecurityPerformanceMonitor get performanceMonitor => _performanceMonitor;

  /// Inicijalizuje container i sve komponente
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.warning('Security container already initialized');
      return;
    }

    await _securityLogger.initialize();
    await _memoryManager.initialize();
    await _performanceMonitor.initialize();

    _isInitialized = true;
    _logger.info('Security container initialized');
  }

  /// Oslobađa resurse
  Future<void> dispose() async {
    if (!_isInitialized) {
      _logger.warning('Security container not initialized');
      return;
    }

    await _securityLogger.dispose();
    await _memoryManager.dispose();
    await _performanceMonitor.dispose();

    _isInitialized = false;
    _logger.info('Security container disposed');
  }

  /// Validira stanje containera
  bool validate() {
    if (!_isInitialized) {
      _logger.error('Security container not initialized');
      return false;
    }

    if (!_securityLogger.isInitialized ||
        !_memoryManager.isInitialized ||
        !_performanceMonitor.isInitialized) {
      _logger.error('One or more security components not initialized');
      return false;
    }

    return true;
  }
}
